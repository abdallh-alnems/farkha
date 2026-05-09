<?php

require_once __DIR__ . '/../../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
$content = $input['content'] ?? null;

Validator::required($cycleId, 'cycle_id');
Validator::required($content, 'content');

if (trim($content) === '') {
    Response::fail('content must not be empty', 400);
}

$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);

$con = db();
CycleModel::requireWriteAccess($con, $cycleId, $userId);

try {
    CycleModel::insertNote($con, $cycleId, $content);

    Response::success([
        'note_id' => (int) Database::lastInsertId(),
        'message' => 'Note added successfully',
    ]);
} catch (PDOException $e) {
    error_log("add_note error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
