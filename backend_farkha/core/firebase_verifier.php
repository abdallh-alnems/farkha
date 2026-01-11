<?php
/**
 * Firebase Token Verifier
 * ملف للتحقق من Firebase Token
 */

require_once __DIR__ . '/../vendor/autoload.php';

use Kreait\Firebase\Factory;
use Kreait\Firebase\Exception\Auth\FailedToVerifyToken;

/**
 * الحصول على Firebase Auth instance
 * 
 * @return \Kreait\Firebase\Auth
 */
function getFirebaseAuth() {
    $serviceAccountPath = __DIR__ . '/firebase_credentials.json';
    
    if (!file_exists($serviceAccountPath)) {
        throw new Exception('Firebase credentials not found');
    }
    
    return (new Factory)    
        ->withServiceAccount($serviceAccountPath)
        ->createAuth();
}

function verifyToken(string $token) {
    $auth = getFirebaseAuth();
    
    // استخدام leeway = 60 ثانية للسماح بفرق زمني بسيط
    // إذا لم يعمل، يمكن زيادة القيمة إلى 300
    return $auth->verifyIdToken($token, $checkIfRevoked = false, $leewayInSeconds = 60);
}

/**
 * التحقق من Token وإرجاع خطأ JSON إذا فشل
 * 
 * @param string|null $token
 * @return \Lcobucci\JWT\Token\Plain verified token object
 */
function requireValidToken(?string $token) {
    if (!$token) {
        http_response_code(400);
        echo json_encode(['error' => 'Token is required']);
        exit;
    }
    
    try {
        return verifyToken($token);
    } catch (FailedToVerifyToken $e) {
        http_response_code(401);
        echo json_encode([
            'error' => 'Invalid or expired token',
            'details' => $e->getMessage()
        ]);
        exit;
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            'error' => 'Authentication failed',
            'details' => $e->getMessage()
        ]);
        exit;
    }
}

/**
 * الحصول على user_id من Firebase token
 * 
 * @param string $token Firebase ID token
 * @param PDO $con Database connection
 * @return int|null User ID or null if not found
 */
function getUserIdFromToken(string $token, PDO $con): ?int {
    try {
        $verifiedToken = verifyToken($token);
        $firebaseUid = $verifiedToken->claims()->get('sub');
        
        $stmt = $con->prepare("SELECT id FROM users WHERE firebase_uid = ? LIMIT 1");
        $stmt->execute([$firebaseUid]);
        $user = $stmt->fetch();
        
        return $user ? (int)$user['id'] : null;
    } catch (Exception $e) {
        return null;
    }
}
