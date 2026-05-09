<?php

require_once __DIR__ . '/../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];

try {
    $invitations = CycleModel::fetchUserInvitations($userId);
    Response::success($invitations);
} catch (PDOException $e) {
    error_log("get_my_invitations error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
