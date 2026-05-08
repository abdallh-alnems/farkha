<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::requirePost();
Auth::checkAppCheck();

$input = Validator::getJsonBody();
$token = $input['token'] ?? null;
$verifiedToken = $input['verified_token'] ?? null;

$firebaseToken = Auth::verifyFirebaseToken($token);
$uid = $firebaseToken->claims()->get('sub');

if ($verifiedToken) {
    try {
        $con = db();
        $con->beginTransaction();

        $stmt = $con->prepare(
            "SELECT pv.*, u.firebase_uid FROM phone_verifications pv JOIN users u ON pv.user_id = u.id
             WHERE pv.verified_token = :token AND pv.verified_token_expires_at > NOW() LIMIT 1"
        );
        $stmt->execute([':token' => $verifiedToken]);
        $verification = $stmt->fetch();

        if (!$verification) {
            $con->rollBack();
            Response::errorWithData([
                'error' => ['code' => 'verified_session_not_found', 'message' => 'رمز التحقق غير موجود أو منتهي الصلاحية'],
            ], 404);
        }

        if ($verification['firebase_uid'] !== $uid) {
            $con->rollBack();
            Response::errorWithData([
                'error' => ['code' => 'verified_token_mismatch', 'message' => 'رمز التحقق لا ينتمي لهذا الحساب'],
            ], 403);
        }

        $user = UserModel::findByFirebaseUid($uid);
        if (!$user) {
            $con->rollBack();
            Response::fail('User not found', 404);
        }

        $phoneToSet = $verification['phone'];

        $phoneOwner = UserModel::findByPhone($phoneToSet);
        if ($phoneOwner && (int) $phoneOwner['id'] !== (int) $user['id']) {
            $con->rollBack();
            Response::errorWithData([
                'error' => ['code' => 'phone_already_linked', 'message' => 'هذا الرقم مستخدم بالفعل'],
            ], 409);
        }

        UserModel::clearPhoneForOtherUsers($phoneToSet, (int) $user['id']);
        UserModel::updatePhoneVerified((int) $user['id'], $phoneToSet);

        $con->prepare("UPDATE phone_verifications SET verified_token = NULL WHERE id = :id")
            ->execute([':id' => $verification['id']]);

        $con->commit();
        Response::success(['phone' => $phoneToSet, 'message' => 'تم توثيق رقم الهاتف بنجاح']);
    } catch (PDOException $e) {
        if (isset($con) && $con->inTransaction()) $con->rollBack();
        error_log('update_phone error: ' . $e->getMessage());
        Response::error('Database error', 500);
    }
} else {
    Response::fail('verified_token is required. Phone must be verified via OTP.', 400);
}
