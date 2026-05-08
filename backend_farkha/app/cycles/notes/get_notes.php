<?php

require_once __DIR__ . '/../../../config/bootstrap.php';

Auth::checkAppCheck();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
Validator::required($cycleId, 'cycle_id');
$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);

$con = db();
CycleModel::requireReadAccess($con, $cycleId, $userId);

try {
    $notes = CycleModel::fetchNotes($cycleId);

    Response::success([
        'notes' => $notes,
        'notes_count' => count($notes),
    ]);
} catch (PDOException $e) {
    error_log("get_notes error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
