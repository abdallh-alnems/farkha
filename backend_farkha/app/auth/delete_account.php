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
requirePostMethod();

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
    
    // 🔄 بدء Transaction لضمان تناسق البيانات
    $con->beginTransaction();
    
    try {
        // 📋 البحث عن جميع دورات المستخدم
        $stmt = $con->prepare("SELECT cycle_id FROM cycle_users WHERE user_id = :user_id");
        $stmt->execute([':user_id' => $user['id']]);
        $userCycles = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        // 🗑️ حذف جميع بيانات الدورات
        foreach ($userCycles as $cycleId) {
            // حذف بيانات الدورة (cycle_data)
            $stmt = $con->prepare(Queries::deleteCycleDataQuery());
            $stmt->execute([':cycle_id' => $cycleId]);
            
            // حذف مصاريف الدورة (cycle_expenses)
            $stmt = $con->prepare(Queries::deleteCycleExpensesQuery());
            $stmt->execute([':cycle_id' => $cycleId]);

            // حذف ملاحظات الدورة (cycle_notes)
            $stmt = $con->prepare(Queries::deleteCycleNotesQuery());
            $stmt->execute([':cycle_id' => $cycleId]);

            // حذف المستخدمين من الدورة (cycle_users)
            $stmt = $con->prepare(Queries::deleteCycleUsersQuery());
            $stmt->execute([':cycle_id' => $cycleId]);
            
            // حذف الدورة نفسها (cycles)
            $stmt = $con->prepare(Queries::deleteCycleQuery());
            $stmt->execute([':cycle_id' => $cycleId]);
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
        
        // ✅ تأكيد التغييرات
        $con->commit();
        
        // 📊 تسجيل عملية الحذف
        error_log("User deleted successfully: {$uid}, Cycles deleted: " . count($userCycles));
        
        // ✅ إرسال الرد
        echo json_encode([
            'status' => 'success'
        ]);
        
    } catch (Exception $e) {
        // ↩️ التراجع عن جميع التغييرات في حالة الخطأ
        $con->rollBack();
        throw $e;
    }
    
} catch (PDOException $e) {
    error_log('Delete account error: ' . $e->getMessage());
    echo json_encode([
        'status' => 'fail',
        'message' => 'Database error'
    ]);
    http_response_code(500);
} catch (Exception $e) {
    error_log('Delete account error: ' . $e->getMessage());
    echo json_encode([
        'status' => 'fail',
        'message' => 'Server error'
    ]);
    http_response_code(500);
}

