<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();
Auth::requirePost();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
$label = $input['label'] ?? null;
$value = $input['value'] ?? null;
$metricType = $input['metric_type'] ?? null;

Validator::required($cycleId, 'cycle_id');
Validator::required($label, 'label');
Validator::required($value, 'value');

$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);

if ($metricType !== null) {
    $metricType = Validator::enum($metricType, ['weight', 'mortality', 'feed', 'water', 'temperature', 'humidity', 'medicine', 'other'], 'metric_type');
} else {
    $metricType = 'other';
}

$con = db();
CycleModel::requireWriteAccess($con, $cycleId, $userId);

try {
    CycleModel::insertData($con, $cycleId, $label, $value, $metricType);

    Response::success([
        'data_id' => (int) Database::lastInsertId(),
        'message' => 'Cycle data added successfully',
    ]);
} catch (PDOException $e) {
    error_log("add_data error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
