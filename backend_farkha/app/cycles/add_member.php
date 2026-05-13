<?php

require_once __DIR__ . '/../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
$phone = $input['phone'] ?? null;
$roleInput = $input['role'] ?? 'admin';

Validator::required($cycleId, 'cycle_id');
Validator::required($phone, 'phone');

$roleInput = Validator::enum($roleInput, ['admin', 'viewer'], 'role');

$con = db();

try {
    $access = CycleModel::checkReadAccess((int) $cycleId, $userId);
    if (!$access || $access['role'] !== 'owner') {
        Response::forbidden('غير مصرح لك بإضافة أعضاء');
    }

    $requester = UserModel::findById($userId);
    $cycleData = Database::fetchOne("SELECT name FROM cycles WHERE id = ? AND deleted_at IS NULL", [(int) $cycleId]);
    $cycleName = $cycleData ? $cycleData['name'] : 'دورة الدواجن';

    $targetUser = UserModel::findByPhone($phone);
    if (!$targetUser) {
        Response::notFound('لم يتم العثور على مستخدم بهذا الرقم');
    }

    $existing = Database::fetchOne(
        "SELECT id FROM cycle_users WHERE cycle_id = :cid AND user_id = :uid",
        [':cid' => (int) $cycleId, ':uid' => $targetUser['id']]
    );
    if ($existing) {
        Response::fail('المستخدم عضو بالفعل في هذه الدورة', 409);
    }

    CycleModel::addMember($con, (int) $cycleId, (int) $targetUser['id'], $roleInput, 'pending');

    $title = I18n::get('notif.cycle_invitation.title', [], I18n::userLocale($con, (int) $targetUser['id']));
    $requesterName = !empty($requester['name']) ? $requester['name'] : 'أحد أصحاب المزارع';
    $roleLabel = $roleInput === 'admin' ? 'مدير' : 'مشاهد';
    $body = I18n::get('notif.cycle_invitation.body', [
        'requester' => $requesterName,
        'cycle' => $cycleName,
        'role' => $roleLabel,
    ], I18n::userLocale($con, (int) $targetUser['id']));
    try {
        NotificationService::sendToUser($con, (int) $targetUser['id'], $title, $body, [
            'type' => 'cycle_invitation',
            'cycle_id' => (string) $cycleId,
        ]);
    } catch (Exception $ex) {}

    Response::success([
        'message' => 'تم إرسال طلب الإضافة، في انتظار موافقة العضو',
        'user' => ['id' => $targetUser['id'], 'name' => $targetUser['name']],
    ]);
} catch (PDOException $e) {
    error_log("add_member error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
