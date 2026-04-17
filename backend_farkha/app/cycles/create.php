<?php
/**
 * Create Cycle API
 * إنشاء دورة جديدة
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
    $name = $input['name'] ?? null;
    $chickCount = $input['chick_count'] ?? null;
    $space = $input['space'] ?? null;
    $breed = $input['breed'] ?? null;
    $systemType = $input['system_type'] ?? 'أرضي';
    $startDateRaw = $input['start_date_raw'] ?? null;

    // التحقق من البيانات المطلوبة
    if (!$name || !$chickCount || !$space || !$startDateRaw) {
        http_response_code(400);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Missing required fields: name, chick_count, space, start_date_raw'
        ]);
        exit;
    }

    // التحقق من صحة البيانات
    if (!is_numeric($chickCount) || $chickCount <= 0) {
        http_response_code(400);
        echo json_encode([
            'status' => 'fail',
            'message' => 'chick_count must be a positive number'
        ]);
        exit;
    }

    if (!is_numeric($space) || $space <= 0) {
        http_response_code(400);
        echo json_encode([
            'status' => 'fail',
            'message' => 'space must be a positive number'
        ]);
        exit;
    }

    // التحقق من صحة التاريخ
    $date = DateTime::createFromFormat('Y-m-d', $startDateRaw);
    if (!$date || $date->format('Y-m-d') !== $startDateRaw) {
        http_response_code(400);
        echo json_encode([
            'status' => 'fail',
            'message' => 'start_date_raw must be in Y-m-d format'
        ]);
        exit;
    }

    // بدء المعاملة
    $con->beginTransaction();

    try {
        // إنشاء الدورة
        $stmt = $con->prepare(Queries::insertCycleQuery());
        $stmt->execute([
            ':name' => $name,
            ':chick_count' => (int)$chickCount,
            ':space' => (float)$space,
            ':breed' => $breed,
            ':system_type' => $systemType,
            ':start_date_raw' => $startDateRaw
        ]);

        $cycleId = $con->lastInsertId();

        // إضافة المستخدم كـ owner
        $stmt = $con->prepare(Queries::insertCycleUserQuery());
        $stmt->execute([
            ':user_id' => $userId,
            ':cycle_id' => $cycleId,
            ':role' => 'owner'
        ]);

        // تأكيد المعاملة
        $con->commit();

        // ✅ إرسال الرد
        echo json_encode([
            'status' => 'success',
            'data' => [
                'cycle_id' => (int)$cycleId,
                'message' => 'Cycle created successfully'
            ]
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

