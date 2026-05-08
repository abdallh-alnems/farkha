<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();
Auth::requirePost();

$input = Validator::getJsonBody();
$token = $input['token'] ?? null;
$sessionToken = $input['session_token'] ?? null;

Validator::required($token, 'token');
Validator::required($sessionToken, 'session_token');

$verifiedToken = Auth::verifyFirebaseToken($token);
$uid = $verifiedToken->claims()->get('sub');

$con = db();

try {
    $con->beginTransaction();

    $session = Database::fetchOne(
        "SELECT id, firebase_uid, phone, resend_count, seconds_until_expiry, seconds_since_update
         FROM phone_verifications
         WHERE session_token = :st AND verified_at IS NULL LIMIT 1",
        [':st' => $sessionToken]
    );

    if (!$session) {
        $con->rollBack();
        Response::fail('الجلسة غير موجودة', 404);
    }

    if ($session['firebase_uid'] !== $uid) {
        $con->rollBack();
        Response::fail('الجلسة غير موجودة', 403);
    }

    if ((int) $session['seconds_until_expiry'] <= 0) {
        $con->rollBack();
        Response::errorWithData([
            'error' => ['code' => 'session_expired', 'message' => 'انتهت صلاحية الجلسة. ابدأ تحققاً جديداً.'],
        ], 410);
    }

    $maxResend = (int) (getenv('OTP_RESEND_MAX') ?: 3);
    if ((int) $session['resend_count'] >= $maxResend) {
        $con->rollBack();
        Response::errorWithData([
            'error' => ['code' => 'resend_limit_exceeded', 'message' => 'تم تجاوز عدد مرّات إعادة الإرسال المسموح. حاول بعد 15 دقيقة.', 'retry_after_seconds' => 900],
        ], 429);
    }

    $cooldownSeconds = ((int) $session['resend_count'] >= 1) ? 1800 : 30;
    $elapsed = (int) $session['seconds_since_update'];
    if ($elapsed < $cooldownSeconds) {
        $con->rollBack();
        $retryAfter = $cooldownSeconds - $elapsed;
        $mins = intdiv($retryAfter, 60);
        $msg = $mins > 0 ? "انتظر $mins دقيقة قبل إعادة الإرسال" : "انتظر $retryAfter ثانية قبل إعادة الإرسال";
        Response::errorWithData([
            'error' => ['code' => 'resend_cooldown', 'message' => $msg, 'retry_after_seconds' => $retryAfter],
        ], 429);
    }

    $otp = OtpService::generate();
    $otpHash = OtpService::hash($otp);
    $expiryMinutes = (int) (getenv('OTP_EXPIRY_MINUTES') ?: 10);

    $message = "رمز التحقق الخاص بك في تطبيق فرخة: $otp\nينتهي خلال $expiryMinutes دقيقة. لا تشارك الرمز مع أحد.";
    $whatsappResult = WhatsAppService::send($session['phone'], $message);

    if (!$whatsappResult['ok']) {
        $con->rollBack();
        error_log("WhatsApp resend failed: " . ($whatsappResult['error'] ?? 'unknown'));
        Response::errorWithData([
            'error' => ['code' => 'whatsapp_send_failed', 'message' => 'فشل إرسال الرسالة عبر WhatsApp'],
        ], 502);
    }

    Database::query(
        "UPDATE phone_verifications SET otp_hash = :hash, expires_at = DATE_ADD(NOW(), INTERVAL :mins MINUTE), updated_at = NOW() WHERE id = :id",
        [':hash' => $otpHash, ':mins' => $expiryMinutes, ':id' => $session['id']]
    );

    $con->commit();

    $newResendCount = (int) $session['resend_count'] + 1;
    $nextCooldown = ($newResendCount >= 1) ? 1800 : 30;

    Response::success([
        'expires_at' => date('Y-m-d\TH:i:sP', time() + ($expiryMinutes * 60)),
        'resend_allowed_at' => date('Y-m-d\TH:i:sP', time() + $nextCooldown),
        'resend_count' => $newResendCount,
    ]);
} catch (PDOException $e) {
    if ($con->inTransaction()) $con->rollBack();
    error_log("resend_otp DB error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
