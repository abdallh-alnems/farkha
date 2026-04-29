<?php

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
require_once __DIR__ . '/../../core/otp_utils.php';
require_once __DIR__ . '/../../core/wasender_client.php';
require_once __DIR__ . '/../../core/queries/queries.php';

checkAuthenticate();
requirePostMethod();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$sessionToken = $input['session_token'] ?? null;

$firebaseToken = requireValidToken($token);
$uid = $firebaseToken->claims()->get('sub');

if (!$sessionToken) {
    ApiResponse::fail('session_token is required', 400);
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
                'message' => 'الجلسة غير موجودة',
            ],
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    if ($session['firebase_uid'] !== $uid) {
        $con->rollBack();
        http_response_code(403);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'success' => false,
            'error' => [
                'code' => 'session_not_found',
                'message' => 'الجلسة غير موجودة',
            ],
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    if ((int)$session['seconds_until_expiry'] <= 0) {
        $con->rollBack();
        http_response_code(410);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'success' => false,
            'error' => [
                'code' => 'session_expired',
                'message' => 'انتهت صلاحية الجلسة. ابدأ تحققاً جديداً.',
            ],
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    $maxResend = (int)(getenv('OTP_RESEND_MAX') ?: $_ENV['OTP_RESEND_MAX'] ?? 3);
    if ((int)$session['resend_count'] >= $maxResend) {
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

    $cooldownSeconds = ((int)$session['resend_count'] >= 1) ? 1800 : 30;
    $elapsed = (int)$session['seconds_since_update'];
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
            ],
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    $otp = generate_otp();
    $otpHash = hash_otp($otp);
    $expiryMinutes = (int)(getenv('OTP_EXPIRY_MINUTES') ?: $_ENV['OTP_EXPIRY_MINUTES'] ?? 10);

    $message = "رمز التحقق الخاص بك في تطبيق فرخة: $otp\nينتهي خلال $expiryMinutes دقيقة. لا تشارك الرمز مع أحد.";
    $whatsappResult = send_whatsapp($session['phone'], $message);

    if (!$whatsappResult['ok']) {
        $con->rollBack();
        error_log("WhatsApp resend failed: " . ($whatsappResult['error'] ?? 'unknown'));
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

    $stmt = $con->prepare(Queries::updatePhoneVerificationResend());
    $stmt->execute([
        ':otp_hash' => $otpHash,
        ':expiry_minutes' => $expiryMinutes,
        ':id' => $session['id'],
    ]);

    $con->commit();

    $newResendCount = (int)$session['resend_count'] + 1;
    $nextCooldown = ($newResendCount >= 1) ? 1800 : 30;

    ApiResponse::success([
        'expires_at' => date('Y-m-d\TH:i:sP', time() + ($expiryMinutes * 60)),
        'resend_allowed_at' => date('Y-m-d\TH:i:sP', time() + $nextCooldown),
        'resend_count' => $newResendCount,
    ]);

} catch (PDOException $e) {
    if ($con->inTransaction()) $con->rollBack();
    error_log("resend_otp DB error: " . $e->getMessage());
    ApiResponse::fail('Database error', 500);
}
