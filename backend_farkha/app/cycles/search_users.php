<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();

$auth = Auth::authenticateUser(db());
$uid = $auth['uid'];
$input = $auth['input'];

$searchTerm = $input['search_term'] ?? null;
Validator::required($searchTerm, 'search_term');

if (strlen($searchTerm) < 8) {
    Response::success([]);
}

try {
    $results = UserModel::searchByPhone('%' . $searchTerm . '%', $uid);
    Response::success($results);
} catch (PDOException $e) {
    error_log("search_users error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
