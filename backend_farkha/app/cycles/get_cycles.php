<?php
/**
 * Get User Cycles API
 * جلب جميع الدورات المرتبطة بالمستخدم
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

    // جلب جميع الدورات المرتبطة بالمستخدم مع الوفيات والمصاريف
    $stmt = $con->prepare(Queries::fetchUserCyclesQuery());
    $stmt->execute([':user_id' => $userId]);
    $cycles = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // تحويل القيم إلى الأرقام المناسبة
    foreach ($cycles as &$cycle) {
        $cycle['id'] = (int)$cycle['id'];
        $cycle['chick_count'] = (int)$cycle['chick_count'];
        $cycle['mortality'] = (int)$cycle['mortality'];
        $cycle['total_expenses'] = (int)$cycle['total_expenses'];
    }
    unset($cycle); // إزالة المرجع

    // ✅ إرسال الرد
    echo json_encode([
        'status' => 'success',
        'data' => [
            'cycles' => $cycles,
            'count' => count($cycles)
        ]
    ], JSON_UNESCAPED_UNICODE);

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

