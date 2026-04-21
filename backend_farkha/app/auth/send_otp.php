<?php

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
require_once __DIR__ . '/../../core/otp_utils.php';
require_once __DIR__ . '/../../core/wasender_client.php';
require_once __DIR__ . '/../../core/queries/queries.php';

checkAuthenticate();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$phone = $input['phone'] ?? null;

$firebaseToken = requireValidToken($token);
$uid = $firebaseToken->claims()->get('sub');

if (!$phone) {
    ApiResponse::fail('Phone number is required', 400);
}

$normalizedPhone = normalize_egypt_phone($phone);
if ($normalizedPhone === null) {
    ApiResponse::fail('Invalid phone format', 400);
}

$expiryMinutes = (int)(getenv('OTP_EXPIRY_MINUTES') ?: $_ENV['OTP_EXPIRY_MINUTES'] ?? 10);
$maxResend = (int)(getenv('OTP_RESEND_MAX') ?: $_ENV['OTP_RESEND_MAX'] ?? 3);

try {
    $con->beginTransaction();

    $stmt = $con->prepare(Queries::findUserByFirebaseUidQuery());
    $stmt->execute([':firebase_uid' => $uid]);
    $user = $stmt->fetch();

    if (!$user) {
        $con->rollBack();
        ApiResponse::fail('User not found', 404);
    }

    $userId = (int)$user['id'];

    $stmt = $con->prepare(Queries::findLatestPendingByUserPhone());
    $stmt->execute([':user_id' => $userId, ':phone' => $normalizedPhone]);
    $existing = $stmt->fetch();

    $reuseSessionId = null;
    $sessionToken = null;
    $nextResendCount = 0;

    if ($existing && (int)$existing['seconds_until_expiry'] > 0) {
        $currentCount = (int)$existing['resend_count'];

        if ($currentCount >= $maxResend) {
            $con->rollBack();
            http_response_code(429);
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode([
                'success' => false,
                'error' => [
                    'code' => 'resend_limit_exceeded',
                    'message' => 'تم تجاوز عدد مرّات إعادة الإرسال المسموح. حاول بعد 15 دقيقة.',
                    'retry_after_seconds' => 900,
                ],
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }

        $cooldownSeconds = ($currentCount >= 1) ? 1800 : 30;
        $elapsed = (int)$existing['seconds_since_update'];
        if ($elapsed < $cooldownSeconds) {
            $con->rollBack();
            $retryAfter = $cooldownSeconds - $elapsed;
            $mins = intdiv($retryAfter, 60);
            $msg = $mins > 0
                ? "انتظر $mins دقيقة قبل إعادة الإرسال"
                : "انتظر $retryAfter ثانية قبل إعادة الإرسال";
            http_response_code(429);
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode([
                'success' => false,
                'error' => [
                    'code' => 'resend_cooldown',
                    'message' => $msg,
                    'retry_after_seconds' => $retryAfter,
                    'session_token' => $existing['session_token'],
                ],
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }

        $reuseSessionId = (int)$existing['id'];
        $sessionToken = $existing['session_token'];
        $nextResendCount = $currentCount + 1;
    }

    $otp = generate_otp();
    $otpHash = hash_otp($otp);

    if ($reuseSessionId === null) {
        $sessionToken = bin2hex(random_bytes(16));

        $stmt = $con->prepare(Queries::expireStalePhoneVerifications());
        $stmt->execute([
            ':user_id' => $userId,
            ':phone' => $normalizedPhone,
            ':exclude_id' => 0,
        ]);

        $stmt = $con->prepare(Queries::insertPhoneVerification());
        $stmt->execute([
            ':user_id' => $userId,
            ':phone' => $normalizedPhone,
            ':otp_hash' => $otpHash,
            ':session_token' => $sessionToken,
            ':expiry_minutes' => $expiryMinutes,
        ]);
    } else {
        $stmt = $con->prepare(Queries::updatePhoneVerificationResend());
        $stmt->execute([
            ':otp_hash' => $otpHash,
            ':expiry_minutes' => $expiryMinutes,
            ':id' => $reuseSessionId,
        ]);
    }

    $message = "رمز التحقق الخاص بك في تطبيق فرخة: $otp\nينتهي خلال $expiryMinutes دقيقة. لا تشارك الرمز مع أحد.";
    $whatsappResult = send_whatsapp($normalizedPhone, $message);

    if (!$whatsappResult['ok']) {
        $con->rollBack();
        error_log("WhatsApp send failed for user_id=$userId: " . ($whatsappResult['error'] ?? 'unknown'));
        http_response_code(502);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'success' => false,
            'error' => [
                'code' => 'whatsapp_send_failed',
                'message' => 'فشل إرسال الرسالة عبر WhatsApp',
            ],
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    $con->commit();

    $nextCooldown = ($nextResendCount >= 1) ? 1800 : 30;
    $resendAllowedAt = date('Y-m-d\TH:i:sP', time() + $nextCooldown);
    $expiresAt = date('Y-m-d\TH:i:sP', time() + ($expiryMinutes * 60));

    ApiResponse::success([
        'session_token' => $sessionToken,
        'expires_at' => $expiresAt,
        'resend_allowed_at' => $resendAllowedAt,
        'resend_count' => $nextResendCount,
    ]);

} catch (PDOException $e) {
    if ($con->inTransaction()) $con->rollBack();
    error_log("send_otp DB error: " . $e->getMessage());
    ApiResponse::fail('Database error', 500);
} catch (RuntimeException $e) {
    if (isset($con) && $con->inTransaction()) $con->rollBack();
    error_log("send_otp config error: " . $e->getMessage());
    ApiResponse::fail('Server configuration error', 500);
}
