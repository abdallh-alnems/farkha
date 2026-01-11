<?php
/**
 * Get Cycle Details API
 * جلب تفاصيل دورة معينة مع بياناتها ومصاريفها
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

    // جلب تفاصيل الدورة مع التحقق من صلاحيات المستخدم
    $stmt = $con->prepare(Queries::fetchCycleDetailsQuery());
    $stmt->execute([
        ':cycle_id' => (int)$cycleId,
        ':user_id' => $userId
    ]);
    $cycleDetails = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$cycleDetails) {
        http_response_code(404);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Cycle not found or access denied'
        ]);
        exit;
    }

    // جلب بيانات الدورة
    $stmt = $con->prepare(Queries::fetchCycleDataQuery());
    $stmt->execute([':cycle_id' => (int)$cycleId]);
    $cycleData = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // جلب مصاريف الدورة
    $stmt = $con->prepare(Queries::fetchCycleExpensesQuery());
    $stmt->execute([':cycle_id' => (int)$cycleId]);
    $cycleExpenses = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // ✅ إرسال الرد
    echo json_encode([
        'status' => 'success',
        'data' => [
            'cycle' => $cycleDetails,
            'data' => $cycleData,
            'expenses' => $cycleExpenses,
            'data_count' => count($cycleData),
            'expenses_count' => count($cycleExpenses)
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

