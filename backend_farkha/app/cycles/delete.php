<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();
Auth::requirePost();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
Validator::required($cycleId, 'cycle_id');
$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);

$access = CycleModel::checkReadAccess($cycleId, $userId);
if (!$access) {
    Response::forbidden('Access denied to this cycle');
}
if ($access['role'] !== 'owner') {
    Response::forbidden('Only the cycle owner can delete the cycle');
}

$con = db();

try {
    $con->beginTransaction();

    CycleModel::deleteFull($con, $cycleId);

    $con->commit();

    Response::success(['message' => 'Cycle and all related data deleted successfully']);
} catch (PDOException $e) {
    if ($con->inTransaction()) $con->rollBack();
    error_log("delete cycle error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
