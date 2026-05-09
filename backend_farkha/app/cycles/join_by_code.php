<?php

require_once __DIR__ . '/../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$code = $input['code'] ?? null;
Validator::required($code, 'code');

$con = db();

try {
    $invitation = Database::fetchOne("SELECT * FROM cycle_invitations WHERE code = :code LIMIT 1", [':code' => $code]);
    if (!$invitation) {
        Response::fail('كود الدعوة غير صالح', 404);
    }

    if ($invitation['status'] !== 'active') {
        Response::fail('كود الدعوة غير صالح أو تم استخدامه بالفعل', 410);
    }

    if ($invitation['expires_at'] && strtotime($invitation['expires_at']) < time()) {
        $con->prepare("UPDATE cycle_invitations SET status = 'expired' WHERE id = :id")->execute([':id' => $invitation['id']]);
        Response::fail('كود الدعوة منتهي الصلاحية', 410);
    }

    $existing = Database::fetchOne(
        "SELECT id FROM cycle_users WHERE cycle_id = :cid AND user_id = :uid",
        [':cid' => $invitation['cycle_id'], ':uid' => $userId]
    );
    if ($existing) {
        Response::fail('أنت عضو بالفعل في هذه الدورة', 409);
    }

    CycleModel::addMember($con, (int) $invitation['cycle_id'], $userId, 'member', 'accepted');

    $con->prepare("UPDATE cycle_invitations SET status = 'used', used_by_user_id = :uid, used_at = NOW() WHERE id = :id")
        ->execute([':uid' => $userId, ':id' => $invitation['id']]);

    $cycle = Database::fetchOne("SELECT name FROM cycles WHERE id = ? AND deleted_at IS NULL", [$invitation['cycle_id']]);

    Response::success([
        'message' => 'تم الانضمام للدورة بنجاح',
        'cycle_name' => $cycle['name'] ?? '',
    ]);
} catch (PDOException $e) {
    error_log("join_by_code error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
