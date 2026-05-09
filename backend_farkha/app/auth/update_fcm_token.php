<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::requirePost();
RateLimiter::enforceIpLimit();

$input = Validator::getJsonBody();
$token = $input['token'] ?? null;
$fcmToken = $input['fcm_token'] ?? null;
$platform = $input['platform'] ?? 'android';
$deviceId = $input['device_id'] ?? null;

$firebaseToken = Auth::verifyFirebaseToken($token);
$uid = $firebaseToken->claims()->get('sub');

Validator::required($fcmToken, 'FCM Token');

$platform = Validator::enum($platform, ['android', 'ios'], 'platform');

try {
    $user = UserModel::findByFirebaseUid($uid);
    if (!$user) {
        Response::fail('User not found', 404);
    }

    $userId = (int) $user['id'];

    Database::execute(
        "INSERT INTO user_devices (user_id, fcm_token, platform, device_id)
         VALUES (:uid, :token, :platform, :device_id)
         ON DUPLICATE KEY UPDATE user_id = :uid2, platform = :platform2, device_id = :device_id2, last_active = NOW()",
        [
            ':uid' => $userId,
            ':token' => $fcmToken,
            ':platform' => $platform,
            ':device_id' => $deviceId,
            ':uid2' => $userId,
            ':platform2' => $platform,
            ':device_id2' => $deviceId,
        ]
    );

    Response::success(['message' => 'FCM token updated']);
} catch (PDOException $e) {
    error_log('update_fcm error: ' . $e->getMessage());
    Response::error('Database error', 500);
}
