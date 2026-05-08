<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
Validator::required($cycleId, 'cycle_id');
$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);

try {
    $cycleDetails = CycleModel::fetchDetails($cycleId, $userId);
    if (!$cycleDetails) {
        Response::fail('Cycle not found or access denied', 404);
    }

    $cycleData = CycleModel::fetchDataChronological($cycleId);
    $cycleExpenses = CycleModel::fetchExpensesChronological($cycleId);
    $cycleNotes = CycleModel::fetchNotes($cycleId);
    $cycleMembers = CycleModel::fetchMembers($cycleId);
    $cycleSales = CycleModel::fetchSales($cycleId);
    try {
        $inventorySummary = CycleModel::fetchInventorySummary($cycleId);
    } catch (PDOException $e) {
        $inventorySummary = [];
    }

    Response::success([
        'cycle' => $cycleDetails,
        'data' => $cycleData,
        'expenses' => $cycleExpenses,
        'notes' => $cycleNotes,
        'members' => $cycleMembers,
        'sales' => $cycleSales,
        'inventory' => $inventorySummary,
        'data_count' => count($cycleData),
        'expenses_count' => count($cycleExpenses),
        'notes_count' => count($cycleNotes),
        'members_count' => count($cycleMembers),
        'sales_count' => count($cycleSales),
        'inventory_count' => count($inventorySummary),
    ]);
} catch (PDOException $e) {
    error_log("get_cycle_details error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
