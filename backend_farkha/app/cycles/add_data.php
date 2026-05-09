<?php

require_once __DIR__ . '/../../config/bootstrap.php';

RateLimiter::enforceIpLimit();
Auth::requirePost();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
$metricType = $input['metric_type'] ?? null;
$numericValue = $input['numeric_value'] ?? null;
$textValue = $input['text_value'] ?? null;

Validator::required($cycleId, 'cycle_id');
Validator::required($metricType, 'metric_type');

$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);
$metricType = Validator::enum($metricType, ['weight', 'mortality', 'feed', 'vaccination', 'water', 'temperature', 'humidity', 'medicine', 'other'], 'metric_type');

$numericVal = ($numericValue !== null) ? (float) $numericValue : null;
$textVal = ($textValue !== null) ? (string) $textValue : null;

if ($numericVal === null && $textVal === null) {
    Response::fail('Either numeric_value or text_value is required', 400);
}

$con = db();
CycleModel::requireWriteAccess($con, $cycleId, $userId);

try {
    CycleModel::insertData($con, $cycleId, $metricType, $numericVal, $textVal);

    Response::success([
        'data_id' => (int) Database::lastInsertId(),
        'message' => 'Cycle data added successfully',
    ]);
} catch (PDOException $e) {
    error_log("add_data error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
