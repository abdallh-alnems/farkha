<?php
/**
 * Leave Cycle API
 * مغادرة دورة للمستخدم صاحب صلاحية admin أو viewer
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
include __DIR__ . '/../../core/queries/queries.php';

checkAuthenticate();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$cycleId = $input['cycle_id'] ?? null;

if (!$token) {
    http_response_code(400);
    echo json_encode(['status' => 'fail', 'message' => 'Token is required']);
    exit;
}

if (!$cycleId || !is_numeric($cycleId)) {
    http_response_code(400);
    echo json_encode(['status' => 'fail', 'message' => 'cycle_id is required and must be a number']);
    exit;
}

try {
    $userId = getUserIdFromToken($token, $con);
    
    if (!$userId) {
        http_response_code(401);
        echo json_encode(['status' => 'fail', 'message' => 'Invalid token or user not found']);
        exit;
    }

    $stmt = $con->prepare(Queries::checkUserReadAccessQuery());
    $stmt->execute([
        ':cycle_id' => (int)$cycleId,
        ':user_id' => $userId
    ]);
    $access = $stmt->fetch();

    if (!$access) {
        http_response_code(404);
        echo json_encode(['status' => 'fail', 'message' => 'You are not a member of this cycle']);
        exit;
    }

    if ($access['role'] === 'owner') {
        http_response_code(403);
        echo json_encode(['status' => 'fail', 'message' => 'لا يمكنك مغادرة الدورة لأنك المنشئ. يمكنك فقط حذف الدورة.']);
        exit;
    }

    $stmt = $con->prepare(Queries::leaveCycleQuery());
    $result = $stmt->execute([
        ':cycle_id' => (int)$cycleId,
        ':user_id' => $userId
    ]);

    $rowsAffected = $stmt->rowCount();

    if ($result && $rowsAffected > 0) {
        echo json_encode([
            'status' => 'success',
            'message' => 'تمت مغادرة الدورة بنجاح',
            'rows_deleted' => $rowsAffected
        ]);
    } else {
        http_response_code(400);
        echo json_encode([
            'status' => 'fail',
            'message' => 'لم يتم العثور على السجل للحذف',
            'rows_affected' => $rowsAffected
        ]);
    }

} catch (\Kreait\Firebase\Exception\Auth\FailedToVerifyToken $e) {
    http_response_code(401);
    error_log('Firebase Error: ' . $e->getMessage());
    echo json_encode(['status' => 'fail', 'message' => 'Invalid or expired token']);
} catch (PDOException $e) {
    http_response_code(500);
    error_log('Database Error in leave_cycle.php: ' . $e->getMessage());
    echo json_encode(['status' => 'fail', 'message' => 'Database error']);
} catch (Exception $e) {
    http_response_code(500);
    $errorMsg = 'Server Error in leave_cycle.php: ' . $e->getMessage() . ' | ' . $e->getFile() . ':' . $e->getLine();
    error_log($errorMsg);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Server error'
    ]);
}