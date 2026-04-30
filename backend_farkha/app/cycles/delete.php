<?php
/**
 * Delete Cycle API
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
include __DIR__ . '/../../core/queries/queries.php';

checkAuthenticate();
requirePostMethod();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$cycleId = $input['cycle_id'] ?? null;

if (!$token) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Token is required'
    ]);
    exit;
}

if (!$cycleId || !is_numeric($cycleId)) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'cycle_id is required and must be a number'
    ]);
    exit;
}

try {
    $userId = getUserIdFromToken($token, $con);
    
    if (!$userId) {
        http_response_code(401);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Invalid token or user not found'
        ]);
        exit;
    }

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

    if ($access['role'] !== 'owner') {
        http_response_code(403);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Only the cycle owner can delete the cycle'
        ]);
        exit;
    }

    $con->beginTransaction();

    try {
        $stmt = $con->prepare(Queries::deleteCycleDataQuery());
        $stmt->execute([':cycle_id' => (int)$cycleId]);

        $stmt = $con->prepare(Queries::deleteCycleExpensesQuery());
        $stmt->execute([':cycle_id' => (int)$cycleId]);

        $stmt = $con->prepare(Queries::deleteCycleNotesQuery());
        $stmt->execute([':cycle_id' => (int)$cycleId]);

        $stmt = $con->prepare(Queries::deleteCycleUsersQuery());
        $stmt->execute([':cycle_id' => (int)$cycleId]);

        $stmt = $con->prepare(Queries::deleteCycleQuery());
        $stmt->execute([':cycle_id' => (int)$cycleId]);

        $con->commit();

        echo json_encode([
            'status' => 'success',
            'message' => 'Cycle and all related data deleted successfully'
        ]);

    } catch (PDOException $e) {
        $con->rollBack();
        error_log("[delete.php] PDO failed: " . $e->getMessage());
        http_response_code(500);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Database error'
        ]);
        exit;
    }

} catch (\Kreait\Firebase\Exception\Auth\FailedToVerifyToken $e) {
    http_response_code(401);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Invalid or expired token'
    ]);
} catch (PDOException $e) {
    error_log("[delete.php] PDO: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Database error'
    ]);
} catch (Exception $e) {
    error_log("[delete.php] Exception: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Server error'
    ]);
}
