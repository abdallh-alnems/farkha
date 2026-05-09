<?php

require_once __DIR__ . '/../../config/bootstrap.php';

RateLimiter::enforceIpLimit();
Auth::requirePost();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$name = $input['name'] ?? null;
$chickCount = $input['chick_count'] ?? null;
$space = $input['space'] ?? null;
$breed = $input['breed'] ?? null;
$systemType = $input['system_type'] ?? 'أرضي';
$startDateRaw = $input['start_date_raw'] ?? null;

Validator::required($name, 'name');
Validator::required($chickCount, 'chick_count');
Validator::required($space, 'space');
Validator::required($startDateRaw, 'start_date_raw');

$chickCount = Validator::numeric($chickCount, 'chick_count', 1);
$space = Validator::numeric($space, 'space', 1);

$date = DateTime::createFromFormat('Y-m-d', $startDateRaw);
if (!$date || $date->format('Y-m-d') !== $startDateRaw) {
    Response::fail('start_date_raw must be in Y-m-d format', 400);
}

$con = db();

try {
    $con->beginTransaction();

    $cycleId = CycleModel::create($con, [
        'name' => $name,
        'owner_user_id' => $userId,
        'chick_count' => (int) $chickCount,
        'space' => (float) $space,
        'breed' => $breed,
        'system_type' => $systemType,
        'start_date_raw' => $startDateRaw,
    ]);

    CycleModel::addMember($con, $cycleId, $userId, 'owner', 'accepted');

    $con->commit();

    Response::success([
        'cycle_id' => $cycleId,
        'message' => 'Cycle created successfully',
    ]);
} catch (PDOException $e) {
    if ($con->inTransaction()) $con->rollBack();
    error_log("create cycle error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
