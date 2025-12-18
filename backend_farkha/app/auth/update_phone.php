<?php
/**
 * Update User Phone Number
 * تحديث رقم هاتف المستخدم
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
require_once __DIR__ . '/../../core/queries/queries.php';

// 🔒 حماية الـ API endpoint
checkAuthenticate();

// قراءة البيانات المرسلة
$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$phone = $input['phone'] ?? null;

// التحقق من وجود البيانات المطلوبة
if (!$phone) {
    ApiResponse::fail('Phone number is required', 400);
}

// 🔐 التحقق من Firebase Token
$verifiedToken = requireValidToken($token);
$uid = $verifiedToken->claims()->get('sub');

try {
    // 🔎 التحقق من وجود المستخدم
    $stmt = $con->prepare(Queries::findUserByFirebaseUidQuery());
    $stmt->execute([':firebase_uid' => $uid]);
    $user = $stmt->fetch();
    
    if (!$user) {
        ApiResponse::fail('User not found', 404);
    }
    
    // 📝 تحديث رقم الهاتف
    $stmt = $con->prepare(Queries::updateUserPhoneQuery());
    $stmt->execute([
        ':phone' => $phone,
        ':firebase_uid' => $uid
    ]);
    
    // ✅ إرسال الرد
    ApiResponse::success(['message' => 'Phone number updated successfully']);
    
} catch (PDOException $e) {
    ApiResponse::fail('Database error: ' . $e->getMessage(), 500);
}
