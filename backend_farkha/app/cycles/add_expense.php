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

Validator::required($cycleId, 'cycle_id');
Validator::required($label, 'label');
Validator::required($value, 'value');

$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);
$value = Validator::numeric($value, 'value', 1);

$con = db();
CycleModel::requireWriteAccess($con, $cycleId, $userId);

try {
    CycleModel::insertExpense($con, $cycleId, $label, $value);

    Response::success([
        'expense_id' => (int) Database::lastInsertId(),
        'message' => 'Expense added successfully',
    ]);
} catch (PDOException $e) {
    error_log("add_expense error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
