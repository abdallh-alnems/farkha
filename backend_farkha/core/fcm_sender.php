<?php
/**
 * إرسال إشعارات FCM
 * Send FCM Push Notifications Helper
 */

require_once __DIR__ . '/../vendor/autoload.php';

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

/**
 * الحصول على Firebase Messaging instance
 * 
 * @return \Kreait\Firebase\Contract\Messaging
 */
function getFirebaseMessaging() {
    $serviceAccountPath = __DIR__ . '/firebase_credentials.json';
    
    if (!file_exists($serviceAccountPath)) {
        throw new Exception('Firebase credentials not found');
    }
    
    $factory = (new Factory)->withServiceAccount($serviceAccountPath);
    return $factory->createMessaging();
}

/**
 * إرسال إشعار لمستخدم معين بناءً على ID
 * 
 * @param PDO $con
 * @param int $userId معرف المستخدم في قاعدة البيانات
 * @param string $title عنوان الإشعار
 * @param string $body نص الإشعار
 * @param array $data بيانات إضافية
 * @return bool نجاح أو فشل الإرسال
 */
function sendFCMToUser(PDO $con, int $userId, string $title, string $body, array $data = []): bool {
    try {
        // Fetch the user's FCM token
        $stmt = $con->prepare("SELECT fcm_token FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        $row = $stmt->fetch();

        if (!$row || empty($row['fcm_token'])) {
            // No token found for user
            return false;
        }

        $deviceToken = $row['fcm_token'];

        $messaging = getFirebaseMessaging();

        // Convert data values to strings explicitly (Firebase requirement)
        $stringData = [];
        foreach ($data as $key => $value) {
            $stringData[$key] = (string) $value;
        }

        $message = CloudMessage::withTarget('token', $deviceToken)
            ->withNotification(Notification::create($title, $body))
            ->withData($stringData);

        $messaging->send($message);
        
        return true;
    } catch (Exception $e) {
        // Log the error but don't crash the script since it's an accessory feature
        error_log("Failed to send FCM: " . $e->getMessage());
        return false;
    }
}
