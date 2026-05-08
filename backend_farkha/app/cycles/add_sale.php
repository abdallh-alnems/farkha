<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();
Auth::requirePost();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
$totalPrice = $input['total_price'] ?? null;

Validator::required($cycleId, 'cycle_id');
Validator::required($totalPrice, 'total_price');

$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);

$con = db();
CycleModel::requireWriteAccess($con, $cycleId, $userId);

try {
    CycleModel::insertSale($con, $cycleId, [
        'quantity' => (int) ($input['quantity'] ?? 0),
        'total_weight' => (float) ($input['total_weight'] ?? 0),
        'price_per_kg' => (float) ($input['price_per_kg'] ?? 0),
        'total_price' => (float) $totalPrice,
        'sale_date' => $input['sale_date'] ?? date('Y-m-d'),
    ]);

    Response::success([
        'sale_id' => (int) Database::lastInsertId(),
        'message' => 'Sale added successfully',
    ]);
} catch (PDOException $e) {
    error_log("add_sale error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
