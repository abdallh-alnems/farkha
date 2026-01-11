<?php
/**
 * Update Cycle Status API
 * تحديث حالة الدورة (active/finished)
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
include __DIR__ . '/../../core/queries/queries.php';

// 🔒 حماية الـ API endpoint
checkAuthenticate();

// قراءة البيانات المرسلة
$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$cycleId = $input['cycle_id'] ?? null;
$status = $input['status'] ?? null;

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

// التحقق من وجود status
if (!$status || !in_array($status, ['active', 'finished'])) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'status is required and must be "active" or "finished"'
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
    $stmt = $con->prepare(Queries::checkUserAccessQuery());
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
            'message' => 'Only the cycle owner can update the cycle status'
        ]);
        exit;
    }

    // تحديث حالة الدورة
    $stmt = $con->prepare(Queries::updateCycleStatusQuery());
    $stmt->execute([
        ':cycle_id' => (int)$cycleId,
        ':status' => $status
    ]);

    if ($stmt->rowCount() === 0) {
        http_response_code(404);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Cycle not found'
        ]);
        exit;
    }

    // ✅ إرسال الرد
    echo json_encode([
        'status' => 'success',
        'data' => [
            'cycle_id' => (int)$cycleId,
            'new_status' => $status,
            'message' => 'Cycle status updated successfully'
        ]
    ]);

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

