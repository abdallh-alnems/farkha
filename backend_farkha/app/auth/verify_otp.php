<?php

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
require_once __DIR__ . '/../../core/otp_utils.php';
require_once __DIR__ . '/../../core/queries/queries.php';

checkAuthenticate();
requirePostMethod();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$sessionToken = $input['session_token'] ?? null;
$otpCode = $input['otp_code'] ?? null;

$firebaseToken = requireValidToken($token);
$uid = $firebaseToken->claims()->get('sub');

if (!$sessionToken || !$otpCode) {
    ApiResponse::fail('session_token and otp_code are required', 400);
}

if (!preg_match('/^\d{6}$/', $otpCode)) {
    http_response_code(400);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'success' => false,
        'error' => [
            'code' => 'invalid_otp_format',
            'message' => 'يجب أن يكون الرمز 6 أرقام',
        ],
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $con->beginTransaction();

    $stmt = $con->prepare(Queries::findActivePhoneVerificationBySession());
    $stmt->execute([':session_token' => $sessionToken]);
    $session = $stmt->fetch();

    if (!$session) {
        $con->rollBack();
        http_response_code(404);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'success' => false,
            'error' => [
                'code' => 'session_not_found',
                'message' => 'الجلسة غير موجودة أو منتهية',
            ],
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    if ($session['firebase_uid'] !== $uid) {
        $con->rollBack();
        http_response_code(404);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'success' => false,
            'error' => [
                'code' => 'session_not_found',
                'message' => 'الجلسة غير موجودة أو منتهية',
            ],
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    if ($session['status'] === 'locked') {
        $remaining = (int)($session['seconds_until_lock_expiry'] ?? 0);
        if ($remaining > 0) {
            $con->rollBack();
            http_response_code(423);
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode([
                'success' => false,
                'error' => [
                    'code' => 'session_locked',
                    'message' => 'تم قفل الإدخال مؤقتاً بسبب محاولات خاطئة متكرّرة. حاول بعد 15 دقيقة.',
                    'retry_after_seconds' => $remaining,
                ],
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
    }

    if ((int)$session['seconds_until_expiry'] <= 0) {
        $stmt = $con->prepare("UPDATE phone_verifications SET status = 'expired' WHERE id = :id");
        $stmt->execute([':id' => $session['id']]);
        $con->commit();

        http_response_code(410);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'success' => false,
            'error' => [
                'code' => 'session_expired',
                'message' => 'انتهت صلاحية الرمز. أعد المحاولة من البداية',
            ],
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    if (!verify_otp_hash($otpCode, $session['otp_hash'])) {
        $newAttempts = (int)$session['attempts_remaining'] - 1;

        if ($newAttempts <= 0) {
            $lockoutMinutes = (int)(getenv('OTP_LOCKOUT_MINUTES') ?: $_ENV['OTP_LOCKOUT_MINUTES'] ?? 15);
            $stmt = $con->prepare(Queries::updatePhoneVerificationAttempts());
            $stmt->execute([
                ':attempts_remaining' => 0,
                ':status' => 'locked',
                ':locked_until' => date('Y-m-d H:i:s', time() + ($lockoutMinutes * 60)),
                ':id' => $session['id'],
            ]);
            $con->commit();

            http_response_code(422);
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode([
                'success' => false,
                'error' => [
                    'code' => 'session_locked',
                    'message' => 'تم قفل الإدخال مؤقتاً بسبب محاولات خاطئة متكرّرة. حاول بعد ' . $lockoutMinutes . ' دقيقة.',
                    'retry_after_seconds' => $lockoutMinutes * 60,
                ],
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }

        $stmt = $con->prepare(Queries::updatePhoneVerificationAttempts());
        $stmt->execute([
            ':attempts_remaining' => $newAttempts,
            ':status' => 'pending',
            ':locked_until' => null,
            ':id' => $session['id'],
        ]);
        $con->commit();

        http_response_code(422);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'success' => false,
            'error' => [
                'code' => 'wrong_otp',
                'message' => "الرمز غير صحيح. المحاولات المتبقية: $newAttempts",
                'attempts_remaining' => $newAttempts,
            ],
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    $verifiedTokenUuid = bin2hex(random_bytes(16));
    $stmt = $con->prepare(Queries::updatePhoneVerificationStatus());
    $stmt->execute([
        ':status' => 'verified',
        ':verified_token' => $verifiedTokenUuid,
        ':id' => $session['id'],
    ]);
    $con->commit();

    ApiResponse::success([
        'verified_token' => $verifiedTokenUuid,
        'verified_token_expires_at' => date('Y-m-d\TH:i:sP', time() + 300),
        'phone' => $session['phone'],
    ]);

} catch (PDOException $e) {
    if (isset($con) && $con->inTransaction()) $con->rollBack();
    error_log("verify_otp DB error: " . $e->getMessage());
    ApiResponse::fail('Database error', 500);
}
