<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::requirePost();
Auth::checkAppCheck();

$input = Validator::getJsonBody();
$token = $input['token'] ?? null;
$phone = $input['phone'] ?? null;

$firebaseToken = Auth::verifyFirebaseToken($token);
$uid = $firebaseToken->claims()->get('sub');

Validator::required($phone, 'Phone number');

$normalizedPhone = Validator::phone($phone);
if ($normalizedPhone === null) {
    Response::fail('Invalid phone format', 400);
}

$expiryMinutes = (int) (getenv('OTP_EXPIRY_MINUTES') ?: 10);
$maxResend = (int) (getenv('OTP_RESEND_MAX') ?: 3);

try {
    $con = db();
    $con->beginTransaction();

    $user = UserModel::findByFirebaseUid($uid);
    if (!$user) {
        $con->rollBack();
        Response::fail('User not found', 404);
    }

    $userId = (int) $user['id'];

    $phoneOwner = UserModel::findByPhone($normalizedPhone);
    if ($phoneOwner && (int) $phoneOwner['id'] !== $userId) {
        $con->rollBack();
        Response::errorWithData([
            'error' => ['code' => 'phone_already_linked', 'message' => 'هذا الرقم مستخدم بالفعل'],
        ], 409);
    }

    $stmt = $con->prepare(
        "SELECT pv.id, pv.session_token, pv.resend_count, pv.expires_at,
                TIMESTAMPDIFF(SECOND, pv.updated_at, NOW()) AS seconds_since_update,
                TIMESTAMPDIFF(SECOND, NOW(), pv.expires_at) AS seconds_until_expiry
         FROM phone_verifications pv
         WHERE pv.user_id = :uid AND pv.phone = :phone AND pv.status = 'pending'
         ORDER BY pv.id DESC LIMIT 1 FOR UPDATE"
    );
    $stmt->execute([':uid' => $userId, ':phone' => $normalizedPhone]);
    $existing = $stmt->fetch();

    $reuseSessionId = null;
    $sessionToken = null;
    $nextResendCount = 0;

    if ($existing && (int) $existing['seconds_until_expiry'] > 0) {
        $currentCount = (int) $existing['resend_count'];

        if ($currentCount >= $maxResend) {
            $con->rollBack();
            Response::errorWithData([
                'error' => ['code' => 'resend_limit_exceeded', 'message' => 'تم تجاوز عدد مرّات إعادة الإرسال المسموح', 'retry_after_seconds' => 900],
            ], 429);
        }

        $cooldownSeconds = ($currentCount >= 1) ? 1800 : 30;
        $elapsed = (int) $existing['seconds_since_update'];
        if ($elapsed < $cooldownSeconds) {
            $con->rollBack();
            $retryAfter = $cooldownSeconds - $elapsed;
            Response::errorWithData([
                'error' => ['code' => 'resend_cooldown', 'message' => "انتظر {$retryAfter} ثانية قبل إعادة الإرسال", 'retry_after_seconds' => $retryAfter, 'session_token' => $existing['session_token']],
            ], 429);
        }

        $reuseSessionId = (int) $existing['id'];
        $sessionToken = $existing['session_token'];
        $nextResendCount = $currentCount + 1;
    }

    $otp = OtpService::generate();
    $otpHash = OtpService::hash($otp);

    if ($reuseSessionId === null) {
        $sessionToken = OtpService::generateSessionToken();

        $con->prepare("UPDATE phone_verifications SET status = 'expired' WHERE user_id = :uid AND phone = :phone AND status = 'pending' AND id != :exclude")
            ->execute([':uid' => $userId, ':phone' => $normalizedPhone, ':exclude' => 0]);

        $con->prepare(
            "INSERT INTO phone_verifications (user_id, phone, otp_hash, session_token, expires_at, attempts_remaining, resend_count, status)
             VALUES (:uid, :phone, :hash, :token, DATE_ADD(NOW(), INTERVAL :exp MINUTE), 5, 0, 'pending')"
        )->execute([':uid' => $userId, ':phone' => $normalizedPhone, ':hash' => $otpHash, ':token' => $sessionToken, ':exp' => $expiryMinutes]);
    } else {
        $con->prepare(
            "UPDATE phone_verifications SET otp_hash = :hash, expires_at = DATE_ADD(NOW(), INTERVAL :exp MINUTE), attempts_remaining = 5, resend_count = resend_count + 1, updated_at = NOW() WHERE id = :id"
        )->execute([':hash' => $otpHash, ':exp' => $expiryMinutes, ':id' => $reuseSessionId]);
    }

    $message = "رمز التحقق الخاص بك في تطبيق فرخة: {$otp}\nينتهي خلال {$expiryMinutes} دقيقة. لا تشارك الرمز مع أحد.";
    $result = WhatsAppService::send($normalizedPhone, $message);

    if (!$result['ok']) {
        $con->rollBack();
        error_log("WhatsApp send failed for user_id={$userId}: " . ($result['error'] ?? 'unknown'));
        Response::errorWithData([
            'error' => ['code' => 'whatsapp_send_failed', 'message' => 'فشل إرسال الرسالة عبر WhatsApp'],
        ], 502);
    }

    $con->commit();

    $nextCooldown = ($nextResendCount >= 1) ? 1800 : 30;
    Response::success([
        'session_token' => $sessionToken,
        'expires_at' => date('Y-m-d\TH:i:sP', time() + ($expiryMinutes * 60)),
        'resend_allowed_at' => date('Y-m-d\TH:i:sP', time() + $nextCooldown),
        'resend_count' => $nextResendCount,
    ]);
} catch (PDOException $e) {
    if (isset($con) && $con->inTransaction()) $con->rollBack();
    error_log('send_otp error: ' . $e->getMessage());
    Response::error('Database error', 500);
}
