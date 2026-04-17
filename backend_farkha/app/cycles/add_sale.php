<?php
/**
 * Add Cycle Sale API
 * إضافة عملية بيع للدورة
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
include __DIR__ . '/../../core/queries/queries.php';

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
    $quantity = $input['quantity'] ?? 0;
    $total_weight = $input['total_weight'] ?? 0;
    $price_per_kg = $input['price_per_kg'] ?? 0;
    $total_price = $input['total_price'] ?? null;
    $sale_date = $input['sale_date'] ?? date('Y-m-d');

    // التحقق من البيانات المطلوبة
    if (!$cycleId || !$total_price) {
        http_response_code(400);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Missing required fields: cycle_id, total_price'
        ]);
        exit;
    }

    // التحقق من صلاحيات المستخدم على الدورة
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

    // إضافة عملية البيع
    $stmt = $con->prepare(Queries::insertCycleSaleQuery());
    $stmt->execute([
        ':cycle_id' => (int)$cycleId,
        ':quantity' => (int)$quantity,
        ':total_weight' => (float)$total_weight,
        ':price_per_kg' => (float)$price_per_kg,
        ':total_price' => (float)$total_price,
        ':sale_date' => $sale_date
    ]);

    $saleId = $con->lastInsertId();

    // ✅ إرسال الرد
    echo json_encode([
        'status' => 'success',
        'data' => [
            'sale_id' => (int)$saleId,
            'message' => 'Sale added successfully'
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
        'message' => 'Database error: ' . $e->getMessage()
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Server error'
    ]);
}
?>
