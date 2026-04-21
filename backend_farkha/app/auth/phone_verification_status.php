<?php

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
require_once __DIR__ . '/../../core/queries/queries.php';

checkAuthenticate();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;

$firebaseToken = requireValidToken($token);
$uid = $firebaseToken->claims()->get('sub');

$maxResend = (int)(getenv('OTP_RESEND_MAX') ?: $_ENV['OTP_RESEND_MAX'] ?? 3);

try {
    $stmt = $con->prepare(Queries::findUserByFirebaseUidQuery());
    $stmt->execute([':firebase_uid' => $uid]);
    $user = $stmt->fetch();

    if (!$user) {
        ApiResponse::success(['has_cooldown' => false]);
    }

    $stmt = $con->prepare(Queries::findLatestPendingByUser());
    $stmt->execute([':user_id' => (int)$user['id']]);
    $session = $stmt->fetch();

    if (!$session || (int)$session['seconds_until_expiry'] <= 0) {
        ApiResponse::success(['has_cooldown' => false]);
    }

    $resendCount = (int)$session['resend_count'];

    if ($resendCount >= $maxResend) {
        ApiResponse::success([
            'has_cooldown' => true,
            'code' => 'resend_limit_exceeded',
            'retry_after_seconds' => 900,
            'phone' => $session['phone'],
            'resend_count' => $resendCount,
        ]);
    }

    $cooldownSeconds = ($resendCount >= 1) ? 1800 : 30;
    $elapsed = (int)$session['seconds_since_update'];

    if ($elapsed >= $cooldownSeconds) {
        ApiResponse::success(['has_cooldown' => false]);
    }

    $retryAfter = $cooldownSeconds - $elapsed;
    $mins = intdiv($retryAfter, 60);
    $msg = $mins > 0
        ? "انتظر $mins دقيقة قبل إعادة الإرسال"
        : "انتظر $retryAfter ثانية قبل إعادة الإرسال";

    ApiResponse::success([
        'has_cooldown' => true,
        'code' => 'resend_cooldown',
        'message' => $msg,
        'retry_after_seconds' => $retryAfter,
        'phone' => $session['phone'],
        'resend_count' => $resendCount,
    ]);

} catch (PDOException $e) {
    error_log("phone_verification_status DB error: " . $e->getMessage());
    ApiResponse::fail('Database error', 500);
}
