<?php

require_once __DIR__ . '/../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
Validator::required($cycleId, 'cycle_id');
$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);

$con = db();

try {
    $access = CycleModel::checkReadAccess($cycleId, $userId);
    if (!$access) {
        Response::notFound('You are not a member of this cycle');
    }

    if ($access['role'] === 'owner') {
        Response::forbidden('لا يمكنك مغادرة الدورة لأنك المنشئ. يمكنك فقط حذف الدورة.');
    }

    CycleModel::leave($con, $cycleId, $userId);

    Response::success([
        'message' => 'تمت مغادرة الدورة بنجاح',
    ]);
} catch (PDOException $e) {
    error_log("leave_cycle error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
