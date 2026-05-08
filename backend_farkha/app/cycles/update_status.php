<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();
Auth::requirePost();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
$status = $input['status'] ?? null;
$endDate = $input['end_date'] ?? null;

Validator::required($cycleId, 'cycle_id');
$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);

Validator::required($status, 'status');
$status = Validator::enum($status, ['active', 'finished'], 'status');

$con = db();

$access = CycleModel::checkReadAccess($cycleId, $userId);
if (!$access) {
    Response::forbidden('Access denied to this cycle');
}
if ($access['role'] !== 'owner') {
    Response::forbidden('Only the cycle owner can update the cycle status');
}

try {
    CycleModel::updateStatus($con, $cycleId, $status, $endDate);

    Response::success([
        'cycle_id' => $cycleId,
        'new_status' => $status,
        'message' => 'Cycle status updated successfully',
    ]);
} catch (PDOException $e) {
    error_log("update_status error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
