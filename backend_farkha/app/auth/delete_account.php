<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::requirePost();
RateLimiter::enforceIpLimit();

$input = Validator::getJsonBody();
$token = $input['token'] ?? null;
$verifiedToken = Auth::verifyFirebaseToken($token);
$uid = $verifiedToken->claims()->get('sub');

try {
    $user = UserModel::findByFirebaseUid($uid);
    if (!$user) {
        Response::fail('User not found', 404);
    }

    $con = db();
    $con->beginTransaction();

    $stmt = $con->prepare("SELECT cycle_id, role FROM cycle_users WHERE user_id = :uid");
    $stmt->execute([':uid' => $user['id']]);
    $userCycles = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($userCycles as $row) {
        if ($row['role'] === 'owner') {
            CycleModel::deleteFull($con, (int) $row['cycle_id']);
        }
    }

    $con->prepare("DELETE FROM cycle_users WHERE user_id = :uid")->execute([':uid' => $user['id']]);

    UserModel::deleteByFirebaseUid($uid);

    $con->commit();

    Auth::deleteFirebaseUser($uid);

    Response::success();
} catch (Exception $e) {
    if (isset($con) && $con->inTransaction()) $con->rollBack();
    error_log('Delete account error: ' . $e->getMessage());
    Response::error('Server error', 500);
}
