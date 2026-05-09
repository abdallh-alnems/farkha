<?php

require_once __DIR__ . '/../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$input = Validator::getJsonBody();
$token = $input['token'] ?? null;

Validator::required($token, 'token');

$verifiedToken = Auth::verifyFirebaseToken($token);
$uid = $verifiedToken->claims()->get('sub');

$maxResend = (int) (getenv('OTP_RESEND_MAX') ?: 3);

try {
    $user = UserModel::findByFirebaseUid($uid);

    if (!$user) {
        Response::success(['has_cooldown' => false]);
    }

    $session = Database::fetchOne(
        "SELECT phone, resend_count, seconds_until_expiry, seconds_since_update
         FROM phone_verifications
         WHERE user_id = :uid AND verified_at IS NULL ORDER BY created_at DESC LIMIT 1",
        [':uid' => $user['id']]
    );

    if (!$session || (int) $session['seconds_until_expiry'] <= 0) {
        Response::success(['has_cooldown' => false]);
    }

    $resendCount = (int) $session['resend_count'];

    if ($resendCount >= $maxResend) {
        Response::success([
            'has_cooldown' => true,
            'code' => 'resend_limit_exceeded',
            'retry_after_seconds' => 900,
            'phone' => $session['phone'],
            'resend_count' => $resendCount,
        ]);
    }

    $cooldownSeconds = ($resendCount >= 1) ? 1800 : 30;
    $elapsed = (int) $session['seconds_since_update'];

    if ($elapsed >= $cooldownSeconds) {
        Response::success(['has_cooldown' => false]);
    }

    $retryAfter = $cooldownSeconds - $elapsed;
    $mins = intdiv($retryAfter, 60);
    $msg = $mins > 0 ? "انتظر $mins دقيقة قبل إعادة الإرسال" : "انتظر $retryAfter ثانية قبل إعادة الإرسال";

    Response::success([
        'has_cooldown' => true,
        'code' => 'resend_cooldown',
        'message' => $msg,
        'retry_after_seconds' => $retryAfter,
        'phone' => $session['phone'],
        'resend_count' => $resendCount,
    ]);
} catch (PDOException $e) {
    error_log("phone_verification_status DB error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
