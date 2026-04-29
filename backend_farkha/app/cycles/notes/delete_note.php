<?php
/**
 * Delete Cycle Note API
 * حذف ملاحظة من الدورة
 */

require_once __DIR__ . '/../../../core/connect.php';
require_once __DIR__ . '/../../../core/firebase_verifier.php';
include __DIR__ . '/../../../core/queries/queries.php';

// 🔒 حماية الـ API endpoint
checkAuthenticate();

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

    // 📦 استخراج البيانات المطلوبة
    $cycleId = $input['cycle_id'] ?? null;
    $noteId = $input['note_id'] ?? null;

    // التحقق من البيانات المطلوبة
    if (!$cycleId || !$noteId) {
        http_response_code(400);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Missing required fields: cycle_id, note_id'
        ]);
        exit;
    }

    // التحقق من صلاحيات المستخدم على الدورة
    $stmt = $con->prepare(Queries::checkUserWriteAccessQuery());
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

    // حذف الملاحظة
    $stmt = $con->prepare(Queries::deleteCycleNoteByIdQuery());
    $stmt->execute([
        ':id' => (int)$noteId,
        ':cycle_id' => (int)$cycleId
    ]);

    $deletedRows = $stmt->rowCount();

    if ($deletedRows === 0) {
        http_response_code(404);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Note not found'
        ]);
        exit;
    }

    // ✅ إرسال الرد
    echo json_encode([
        'status' => 'success',
        'data' => [
            'message' => 'Note deleted successfully'
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
