<?php
/**
 * Update User Name
 * تحديث اسم المستخدم
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
require_once __DIR__ . '/../../core/queries/queries.php';

// 🔒 حماية الـ API endpoint
checkAuthenticate();
requirePostMethod();

// قراءة البيانات المرسلة
$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$name = $input['name'] ?? null;

// التحقق من وجود البيانات المطلوبة
if (!$name) {
    echo json_encode([
        'status' => 'fail',
        'message' => 'Name is required'
    ]);
    http_response_code(400);
    exit;
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
        echo json_encode([
            'status' => 'fail',
            'message' => 'User not found'
        ]);
        http_response_code(404);
        exit;
    }
    
    // 📝 تحديث الاسم
    $stmt = $con->prepare(Queries::updateUserNameQuery());
    $stmt->execute([
        ':name' => $name,
        ':firebase_uid' => $uid
    ]);
    
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

