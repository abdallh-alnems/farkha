<?php
/**
 * Firebase Authentication Login
 * تسجيل دخول المستخدم عبر Firebase Token
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';

// 🔒 حماية الـ API endpoint
checkAuthenticate();
requirePostMethod();

// قراءة البيانات المرسلة
$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;

// التحقق من وجود Token
if (!$token) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Token is required'
    ]);
    exit;
}

try {
    // 🔐 التحقق من Firebase Token
    $verifiedToken = verifyToken($token);
    
    // 📦 استخراج البيانات المطلوبة
    $uid = $verifiedToken->claims()->get('sub');
    $name = $verifiedToken->claims()->get('name') ?? 'مستخدم';
    $phone = $verifiedToken->claims()->get('phone_number');
    
    // 🔎 البحث عن المستخدم في MySQL
    $stmt = $con->prepare("SELECT * FROM users WHERE firebase_uid = ?");
    $stmt->execute([$uid]);
    $user = $stmt->fetch();
    
    if (!$user) {
        // 🆕 إنشاء مستخدم جديد
        $stmt = $con->prepare("INSERT INTO users (firebase_uid, name, phone) VALUES (?, ?, ?)");
        $stmt->execute([$uid, $name, $phone]);
        $user = ['name' => $name, 'phone' => $phone];
    } else {
        // 📝 تحديث اسم المستخدم
        $stmt = $con->prepare("UPDATE users SET name = ? WHERE firebase_uid = ?");
        $stmt->execute([$name, $uid]);
        $user['name'] = $name;
    }
    
    // ✅ إرسال الرد
    echo json_encode([
        'status' => 'success',
        'user' => [
            'name' => $user['name'],
            'phone' => $user['phone'] ?? null
        ]
    ]);
    
} catch (\Kreait\Firebase\Exception\Auth\FailedToVerifyToken $e) {
    http_response_code(401);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Invalid or expired token'
    ]);
} catch (PDOException $e) {
    error_log('Login DB error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Database error'
    ]);
} catch (Exception $e) {
    error_log('Login error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Server error'
    ]);
}
