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

$con = db();

$access = CycleModel::checkReadAccess($cycleId, $userId);
if (!$access) {
    Response::forbidden('Access denied to this cycle');
}
if ($access['role'] !== 'owner') {
    Response::forbidden('Only the cycle owner can update the cycle');
}

$updateData = [];

if (isset($input['name'])) {
    $updateData['name'] = trim($input['name']);
    if ($updateData['name'] === '') {
        Response::fail('name cannot be empty', 400);
    }
}

if (isset($input['chick_count'])) {
    $updateData['chick_count'] = (int) Validator::numeric($input['chick_count'], 'chick_count', 1);
}

if (isset($input['space'])) {
    $updateData['space'] = (float) Validator::numeric($input['space'], 'space', 0);
}

if (array_key_exists('breed', $input)) {
    $updateData['breed'] = $input['breed'];
}

if (array_key_exists('system_type', $input)) {
    $updateData['system_type'] = $input['system_type'];
}

if (isset($input['start_date_raw'])) {
    $date = DateTime::createFromFormat('Y-m-d', $input['start_date_raw']);
    if (!$date || $date->format('Y-m-d') !== $input['start_date_raw']) {
        Response::fail('start_date_raw must be in Y-m-d format', 400);
    }
    $updateData['start_date_raw'] = $input['start_date_raw'];
}

if (empty($updateData)) {
    Response::fail('No fields to update', 400);
}

try {
    CycleModel::update($con, $cycleId, $updateData);

    Response::success([
        'cycle_id' => $cycleId,
        'message' => 'Cycle updated successfully',
    ]);
} catch (PDOException $e) {
    error_log("update_cycle error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
