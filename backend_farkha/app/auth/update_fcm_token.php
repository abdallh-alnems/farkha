<?php
/**
 * تحديث FCM Token للمستخدم
 * Update User FCM Token
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';

checkAuthenticate();
requirePostMethod();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$fcm_token = $input['fcm_token'] ?? null;

if (!$token || !$fcm_token) {
    http_response_code(400);
    echo json_encode(['status' => 'fail', 'message' => 'Missing token or fcm_token']);
    exit;
}

try {
    $verifiedToken = verifyToken($token);
    $firebase_uid = $verifiedToken->claims()->get('sub');

    $stmt = $con->prepare("UPDATE users SET fcm_token = ? WHERE firebase_uid = ?");
    $stmt->execute([$fcm_token, $firebase_uid]);

    echo json_encode(['status' => 'success', 'message' => 'FCM Token updated successfully']);
} catch (\Kreait\Firebase\Exception\Auth\FailedToVerifyToken $e) {
    http_response_code(401);
    echo json_encode(['status' => 'fail', 'message' => 'Invalid or expired token']);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['status' => 'fail', 'message' => $e->getMessage()]);
}
