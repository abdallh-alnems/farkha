<?php
/**
 * Update User Name
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
require_once __DIR__ . '/../../core/queries/queries.php';

checkAuthenticate();
requirePostMethod();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$name = $input['name'] ?? null;

if (!$name) {
    echo json_encode([
        'status' => 'fail',
        'message' => 'Name is required'
    ]);
    http_response_code(400);
    exit;
}

$verifiedToken = requireValidToken($token);
$uid = $verifiedToken->claims()->get('sub');

try {
    $stmt = $con->prepare(Queries::findUserByFirebaseUidQuery());
    $stmt->execute([':firebase_uid' => $uid]);
    $user = $stmt->fetch();
    
    if (!$user) {
        echo json_encode([
            'status' => 'fail',
            'message' => 'User not found'
        ]);
        http_response_code(404);
        exit;
    }
    
    $stmt = $con->prepare(Queries::updateUserNameQuery());
    $stmt->execute([
        ':name' => $name,
        ':firebase_uid' => $uid
    ]);
    
    echo json_encode([
        'status' => 'success'
    ]);
    
} catch (PDOException $e) {
    error_log('Update name error: ' . $e->getMessage());
    echo json_encode([
        'status' => 'fail',
        'message' => 'Database error'
    ]);
    http_response_code(500);
}
