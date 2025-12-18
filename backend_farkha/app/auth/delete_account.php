<?php
/**
 * Delete User Account
 * حذف حساب المستخدم
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
require_once __DIR__ . '/../../core/queries/queries.php';

// 🔒 حماية الـ API endpoint
checkAuthenticate();

// قراءة البيانات المرسلة
$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;

// 🔐 التحقق من Firebase Token
$verifiedToken = requireValidToken($token);
$uid = $verifiedToken->claims()->get('sub');

try {
    // 🔎 التحقق من وجود المستخدم
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
    
    // 🗑️ حذف المستخدم من Firebase Authentication
    try {
        $auth = getFirebaseAuth();
        $auth->deleteUser($uid);
    } catch (Exception $e) {
        // إذا فشل حذف من Firebase، نتابع حذف من MySQL
        error_log('Firebase delete error: ' . $e->getMessage());
    }
    
    // 🗑️ حذف المستخدم من MySQL
    $stmt = $con->prepare(Queries::deleteUserByFirebaseUidQuery());
    $stmt->execute([':firebase_uid' => $uid]);
    
    // ✅ إرسال الرد
    echo json_encode([
        'status' => 'success'
    ]);
    
} catch (PDOException $e) {
    echo json_encode([
        'status' => 'fail',
        'message' => 'Database error: ' . $e->getMessage()
    ]);
    http_response_code(500);
}

