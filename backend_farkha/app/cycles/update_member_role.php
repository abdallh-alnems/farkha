<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
$targetUserId = $input['target_user_id'] ?? null;
$newRole = $input['new_role'] ?? null;

Validator::required($cycleId, 'cycle_id');
Validator::required($targetUserId, 'target_user_id');
Validator::required($newRole, 'new_role');

$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);
$targetUserId = (int) Validator::numeric($targetUserId, 'target_user_id', 1);
$newRole = Validator::enum($newRole, ['admin', 'viewer', 'member'], 'new_role');

$con = db();

try {
    $requesterAccess = CycleModel::checkReadAccess($cycleId, $userId);
    if (!$requesterAccess || $requesterAccess['role'] !== 'owner') {
        Response::forbidden('عذراً، صاحب الدورة فقط هو من يمكنه تغيير صلاحيات الأعضاء.');
    }

    if ($targetUserId === $userId) {
        Response::fail('لا يمكنك تغيير دورك الخاص.', 400);
    }

    $stmt = $con->prepare("UPDATE cycle_users SET role = :new_role WHERE cycle_id = :cycle_id AND user_id = :target_user_id AND role != 'owner'");
    $stmt->execute([':new_role' => $newRole, ':cycle_id' => $cycleId, ':target_user_id' => $targetUserId]);

    if ($stmt->rowCount() === 0) {
        Response::notFound('العضو غير موجود في هذه الدورة أو لا يمكن تغيير دوره.');
    }

    $cycleRow = Database::fetchOne("SELECT name FROM cycles WHERE id = ? AND deleted_at IS NULL", [$cycleId]);
    $cycleName = $cycleRow['name'] ?? 'الدورة';

    $ownerRow = UserModel::findById($userId);
    $ownerName = $ownerRow['name'] ?? 'صاحب الدورة';

    $roleLabel = $newRole === 'admin' ? 'مشرف' : 'متابع';

    NotificationService::sendToUser($con, $targetUserId, 'تنبيه', "تم تغيير دورك في دورة $cycleName إلى \"$roleLabel\" بواسطة $ownerName", [
        'type' => 'role_changed',
        'cycle_id' => (string) $cycleId,
        'new_role' => $newRole,
    ]);

    Response::success([
        'message' => 'تم تغيير صلاحية العضو بنجاح',
        'new_role' => $newRole,
    ]);
} catch (PDOException $e) {
    error_log("update_member_role error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
