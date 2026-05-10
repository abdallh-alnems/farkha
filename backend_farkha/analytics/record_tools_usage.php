<?php

require_once __DIR__ . '/../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$input = Validator::getJsonBody();
$toolId = $input['tool_id'] ?? 0;
$toolId = (int) Validator::numeric($toolId, 'tool_id', 1);

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];

$toolName = $input['tool_name'] ?? "tool_{$toolId}";

try {
    Database::query(
        "INSERT INTO tools_usage (usage_date, tool_id, usage_count) VALUES (CURDATE(), :tid, 1)
         ON DUPLICATE KEY UPDATE usage_count = usage_count + 1",
        [':tid' => $toolId]
    );

    Database::execute(
        "INSERT INTO tools_usage_events (user_id, tool_id) VALUES (:uid, :tid)",
        [':uid' => $userId, ':tid' => $toolId]
    );

    Response::success(null);
} catch (PDOException $e) {
    error_log("record_tools_usage error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
