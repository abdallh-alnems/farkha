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

    $cyclesOwned = 0;
    $cyclesMember = 0;
    foreach ($userCycles as $row) {
        if ($row['role'] === 'owner') {
            $cyclesOwned++;
            CycleModel::deleteFull($con, (int) $row['cycle_id']);
        } else {
            $cyclesMember++;
            $stmt = $con->prepare("DELETE FROM cycle_users WHERE cycle_id = :cid AND user_id = :uid");
            $stmt->execute([':cid' => $row['cycle_id'], ':uid' => $user['id']]);
        }
    }

    $stmt = $con->prepare(
        "INSERT INTO account_deletions
            (account_age_days, cycles_owned_count, cycles_member_count, last_platform)
         SELECT
            TIMESTAMPDIFF(DAY, u.created_at, NOW()),
            :owned,
            :member,
            (SELECT ud.platform FROM user_devices ud WHERE ud.user_id = u.id ORDER BY ud.last_active DESC LIMIT 1)
         FROM users u WHERE u.id = :uid"
    );
    $stmt->execute([
        ':owned' => $cyclesOwned,
        ':member' => $cyclesMember,
        ':uid' => $user['id'],
    ]);

    Auth::deleteFirebaseUser($uid);
    UserModel::deleteByFirebaseUid($uid);

    $con->commit();
    Response::success();
} catch (Exception $e) {
    if (isset($con) && $con->inTransaction()) $con->rollBack();
    error_log('Delete account error: ' . $e->getMessage());
    Response::error('Server error', 500);
}
