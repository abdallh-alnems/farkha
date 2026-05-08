<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::requirePost();
Auth::checkAppCheck();

$input = Validator::getJsonBody();
$token = $input['token'] ?? null;
$sessionToken = $input['session_token'] ?? null;
$otpCode = $input['otp_code'] ?? null;

$firebaseToken = Auth::verifyFirebaseToken($token);
$uid = $firebaseToken->claims()->get('sub');

if (!$sessionToken || !$otpCode) {
    Response::fail('session_token and otp_code are required', 400);
}

if (!preg_match('/^\d{6}$/', $otpCode)) {
    Response::errorWithData([
        'error' => ['code' => 'invalid_otp_format', 'message' => 'يجب أن يكون الرمز 6 أرقام'],
    ], 400);
}

try {
    $con = db();
    $con->beginTransaction();

    $stmt = $con->prepare(
        "SELECT pv.*, u.firebase_uid,
                TIMESTAMPDIFF(SECOND, pv.updated_at, NOW()) AS seconds_since_update,
                TIMESTAMPDIFF(SECOND, NOW(), pv.expires_at) AS seconds_until_expiry,
                TIMESTAMPDIFF(SECOND, NOW(), pv.locked_until) AS seconds_until_lock_expiry
         FROM phone_verifications pv JOIN users u ON pv.user_id = u.id
         WHERE pv.session_token = :token AND pv.status = 'pending' LIMIT 1 FOR UPDATE"
    );
    $stmt->execute([':token' => $sessionToken]);
    $session = $stmt->fetch();

    if (!$session || $session['firebase_uid'] !== $uid) {
        $con->rollBack();
        Response::errorWithData([
            'error' => ['code' => 'session_not_found', 'message' => 'الجلسة غير موجودة أو منتهية'],
        ], 404);
    }

    if ($session['status'] === 'locked') {
        $remaining = (int) ($session['seconds_until_lock_expiry'] ?? 0);
        if ($remaining > 0) {
            $con->rollBack();
            Response::errorWithData([
                'error' => ['code' => 'session_locked', 'message' => 'تم قفل الإدخال مؤقتاً', 'retry_after_seconds' => $remaining],
            ], 423);
        }
    }

    if ((int) $session['seconds_until_expiry'] <= 0) {
        $con->prepare("UPDATE phone_verifications SET status = 'expired' WHERE id = :id")->execute([':id' => $session['id']]);
        $con->commit();
        Response::errorWithData([
            'error' => ['code' => 'session_expired', 'message' => 'انتهت صلاحية الرمز'],
        ], 410);
    }

    if (!OtpService::verify($otpCode, $session['otp_hash'])) {
        $newAttempts = (int) $session['attempts_remaining'] - 1;
        $lockoutMinutes = (int) (getenv('OTP_LOCKOUT_MINUTES') ?: 15);

        if ($newAttempts <= 0) {
            $con->prepare("UPDATE phone_verifications SET attempts_remaining = 0, status = 'locked', locked_until = :locked WHERE id = :id")
                ->execute([':locked' => date('Y-m-d H:i:s', time() + ($lockoutMinutes * 60)), ':id' => $session['id']]);
            $con->commit();
            Response::errorWithData([
                'error' => ['code' => 'session_locked', 'message' => "تم قفل الإدخال مؤقتاً. حاول بعد {$lockoutMinutes} دقيقة.", 'retry_after_seconds' => $lockoutMinutes * 60],
            ], 422);
        }

        $con->prepare("UPDATE phone_verifications SET attempts_remaining = :att, status = 'pending', locked_until = NULL WHERE id = :id")
            ->execute([':att' => $newAttempts, ':id' => $session['id']]);
        $con->commit();
        Response::errorWithData([
            'error' => ['code' => 'wrong_otp', 'message' => "الرمز غير صحيح. المحاولات المتبقية: {$newAttempts}", 'attempts_remaining' => $newAttempts],
        ], 422);
    }

    $verifiedTokenUuid = OtpService::generateVerifiedToken();
    $con->prepare("UPDATE phone_verifications SET status = 'verified', verified_token = :vtoken, verified_token_expires_at = DATE_ADD(NOW(), INTERVAL 5 MINUTE) WHERE id = :id")
        ->execute([':vtoken' => $verifiedTokenUuid, ':id' => $session['id']]);
    $con->commit();

    Response::success([
        'verified_token' => $verifiedTokenUuid,
        'verified_token_expires_at' => date('Y-m-d\TH:i:sP', time() + 300),
        'phone' => $session['phone'],
    ]);
} catch (PDOException $e) {
    if (isset($con) && $con->inTransaction()) $con->rollBack();
    error_log('verify_otp error: ' . $e->getMessage());
    Response::error('Database error', 500);
}
