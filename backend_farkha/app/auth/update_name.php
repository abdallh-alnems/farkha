<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::requirePost();
Auth::checkAppCheck();

$input = Validator::getJsonBody();
$token = $input['token'] ?? null;
$name = $input['name'] ?? null;

$firebaseToken = Auth::verifyFirebaseToken($token);
$uid = $firebaseToken->claims()->get('sub');

Validator::required($name, 'Name');
$name = Validator::maxLength(trim($name), 100, 'Name');

try {
    UserModel::updateName($uid, $name);
    Response::success(['message' => 'Name updated successfully']);
} catch (PDOException $e) {
    error_log('update_name error: ' . $e->getMessage());
    Response::error('Database error', 500);
}
