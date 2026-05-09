<?php

require_once __DIR__ . '/../../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
$noteId = $input['note_id'] ?? null;
$content = $input['content'] ?? null;

Validator::required($cycleId, 'cycle_id');
Validator::required($noteId, 'note_id');
Validator::required($content, 'content');

if (trim($content) === '') {
    Response::fail('content must not be empty', 400);
}

$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);
$noteId = (int) Validator::numeric($noteId, 'note_id', 1);

$con = db();
CycleModel::requireWriteAccess($con, $cycleId, $userId);

try {
    CycleModel::updateNote($con, $noteId, $cycleId, $content);

    if ($con->query("SELECT ROW_COUNT()")->fetchColumn() == 0) {
        Response::notFound('Note');
    }

    Response::success(['message' => 'Note updated successfully']);
} catch (PDOException $e) {
    error_log("update_note error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
