<?php

require_once __DIR__ . '/../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
$targetUserId = $input['target_user_id'] ?? null;

Validator::required($cycleId, 'cycle_id');
Validator::required($targetUserId, 'target_user_id');
$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);
$targetUserId = (int) Validator::numeric($targetUserId, 'target_user_id', 1);

$con = db();

try {
    $requesterAccess = CycleModel::checkReadAccess($cycleId, $userId);
    if (!$requesterAccess || $requesterAccess['role'] !== 'owner') {
        Response::forbidden('عذراً، صاحب الدورة فقط هو من يمكنه حذف الأعضاء.');
    }

    if ($targetUserId === $userId) {
        Response::fail('لا يمكنك حذف نفسك. إذا كنت تريد مغادرة الدورة، يجب حذفها بالكامل لأنك المالك.', 400);
    }

    $cycleRow = Database::fetchOne("SELECT name FROM cycles WHERE id = ? AND deleted_at IS NULL", [$cycleId]);
    $cycleName = $cycleRow['name'] ?? 'الدورة';

    $ownerRow = UserModel::findById($userId);
    $ownerName = $ownerRow['name'] ?? 'صاحب الدورة';

    CycleModel::leave($con, $cycleId, $targetUserId);

    NotificationService::sendToUser($con, $targetUserId, 'تنبيه', "تم ازالتك من دورة $cycleName بواسطة $ownerName", [
        'type' => 'member_removed',
        'cycle_id' => (string) $cycleId,
    ]);

    Response::success(['message' => 'تم حذف العضو من الدورة بنجاح']);
} catch (PDOException $e) {
    error_log("remove_member error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
