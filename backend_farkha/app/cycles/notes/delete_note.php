<?php

require_once __DIR__ . '/../../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
$noteId = $input['note_id'] ?? null;

Validator::required($cycleId, 'cycle_id');
Validator::required($noteId, 'note_id');

$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);
$noteId = (int) Validator::numeric($noteId, 'note_id', 1);

$con = db();
CycleModel::requireWriteAccess($con, $cycleId, $userId);

try {
    $stmt = $con->prepare("DELETE FROM cycle_notes WHERE id = :id AND cycle_id = :cid");
    $stmt->execute([':id' => $noteId, ':cid' => $cycleId]);

    if ($stmt->rowCount() === 0) {
        Response::notFound('Note');
    }

    Response::success(['message' => 'Note deleted successfully']);
} catch (PDOException $e) {
    error_log("delete_note error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
