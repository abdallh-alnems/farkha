<?php

require_once __DIR__ . '/../../config/bootstrap.php';

$ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
if (!RateLimiter::checkLimit('admin_login_' . $ip, 10, 600)) {
    Response::fail('Too many login attempts. Try again later.', 429);
}

$input = json_decode(file_get_contents('php://input'), true) ?: [];
$username = trim($input['username'] ?? '');
$password = $input['password'] ?? '';

if (empty($username) || empty($password)) {
    Response::fail('Username and password are required', 400);
}

$ua = $_SERVER['HTTP_USER_AGENT'] ?? '';
$result = AdminAuth::login($username, $password, $ip, $ua);
Response::success($result);
