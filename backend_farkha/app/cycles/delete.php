<?php
/**
 * Delete Cycle API
 * حذف دورة والبيانات المرتبطة بها
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
include __DIR__ . '/../../core/queries/queries.php';

// 🔒 حماية الـ API endpoint
checkAuthenticate();
requirePostMethod();

// قراءة البيانات المرسلة
$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$cycleId = $input['cycle_id'] ?? null;

// التحقق من وجود Token
if (!$token) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Token is required'
    ]);
    exit;
}

// التحقق من وجود cycle_id
if (!$cycleId || !is_numeric($cycleId)) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'cycle_id is required and must be a number'
    ]);
    exit;
}

try {
    // 🔐 التحقق من Firebase Token والحصول على user_id
    $userId = getUserIdFromToken($token, $con);
    
    if (!$userId) {
        http_response_code(401);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Invalid token or user not found'
        ]);
        exit;
    }

    // التحقق من صلاحيات المستخدم - يجب أن يكون owner
    $stmt = $con->prepare(Queries::checkUserReadAccessQuery());
    $stmt->execute([
        ':cycle_id' => (int)$cycleId,
        ':user_id' => $userId
    ]);
    $access = $stmt->fetch();

    if (!$access) {
        http_response_code(403);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Access denied to this cycle'
        ]);
        exit;
    }

    // التحقق من أن المستخدم هو owner فقط
    if ($access['role'] !== 'owner') {
        http_response_code(403);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Only the cycle owner can delete the cycle'
        ]);
        exit;
    }

    // بدء المعاملة
    $con->beginTransaction();

    try {
        // 1. حذف بيانات الدورة
        $stmt = $con->prepare(Queries::deleteCycleDataQuery());
        $stmt->execute([':cycle_id' => (int)$cycleId]);

        // 2. حذف مصاريف الدورة
        $stmt = $con->prepare(Queries::deleteCycleExpensesQuery());
        $stmt->execute([':cycle_id' => (int)$cycleId]);

        // 3. حذف ملاحظات الدورة
        $stmt = $con->prepare(Queries::deleteCycleNotesQuery());
        $stmt->execute([':cycle_id' => (int)$cycleId]);

        // 3.5 حذف مخزون الدورة
        $stmt = $con->prepare(Queries::deleteCycleInventoryQuery());
        $stmt->execute([':cycle_id' => (int)$cycleId]);

        // 4. حذف مستخدمي الدورة
        $stmt = $con->prepare(Queries::deleteCycleUsersQuery());
        $stmt->execute([':cycle_id' => (int)$cycleId]);

        // 4. حذف الدورة نفسها
        $stmt = $con->prepare(Queries::deleteCycleQuery());
        $stmt->execute([':cycle_id' => (int)$cycleId]);

        // تأكيد المعاملة
        $con->commit();

        // ✅ إرسال الرد
        echo json_encode([
            'status' => 'success',
            'message' => 'Cycle and all related data deleted successfully'
        ]);

    } catch (PDOException $e) {
        $con->rollBack();
        throw $e;
    }

} catch (\Kreait\Firebase\Exception\Auth\FailedToVerifyToken $e) {
    http_response_code(401);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Invalid or expired token'
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Database error'
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Server error'
    ]);
}
?>

