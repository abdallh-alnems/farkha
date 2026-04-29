<?php
/**
 * Update Cycle Note API
 * تعديل ملاحظة في الدورة
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
    $content = $input['content'] ?? null;

    // التحقق من البيانات المطلوبة
    if (!$cycleId || !$noteId || !$content) {
        http_response_code(400);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Missing required fields: cycle_id, note_id, content'
        ]);
        exit;
    }

    // التحقق من صحة البيانات
    if (trim($content) === '') {
        http_response_code(400);
        echo json_encode([
            'status' => 'fail',
            'message' => 'content must not be empty'
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

    // تعديل الملاحظة
    $stmt = $con->prepare(Queries::updateCycleNoteQuery());
    $stmt->execute([
        ':id' => (int)$noteId,
        ':cycle_id' => (int)$cycleId,
        ':content' => $content
    ]);

    $updatedRows = $stmt->rowCount();

    if ($updatedRows === 0) {
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
            'message' => 'Note updated successfully'
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
