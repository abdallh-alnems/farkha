<?php
/**
 * Get Cycle History API
 * جلب سجل الدورات المنتهية للمستخدم مع صفحات
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

    // إعدادات البحث والفلترة
    $search = isset($input['search']) ? trim($input['search']) : '';
    $hasSearch = !empty($search);

    $dateFrom = isset($input['date_from']) ? trim($input['date_from']) : '';
    $hasDateFrom = !empty($dateFrom);

    $dateTo = isset($input['date_to']) ? trim($input['date_to']) : '';
    $hasDateTo = !empty($dateTo);

    // إعدادات الصفحات
    $page = isset($input['page']) ? (int)$input['page'] : 1;
    $limit = isset($input['limit']) ? (int)$input['limit'] : 5;
    $offset = ($page - 1) * $limit;

    // جلب الدورات المنتهية للمستخدم
    $stmt = $con->prepare(Queries::fetchUserHistoryCyclesQuery($hasSearch, $hasDateFrom, $hasDateTo));
    $stmt->bindParam(':user_id', $userId, PDO::PARAM_INT);
    $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
    
    if ($hasSearch) {
        $searchTerm = "%$search%";
        $stmt->bindParam(':search', $searchTerm, PDO::PARAM_STR);
    }

    if ($hasDateFrom) {
        $stmt->bindParam(':date_from', $dateFrom, PDO::PARAM_STR);
    }

    if ($hasDateTo) {
        $stmt->bindParam(':date_to', $dateTo, PDO::PARAM_STR);
    }

    $stmt->execute();
    $cycles = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // تحويل القيم إلى الأرقام المناسبة
    foreach ($cycles as &$cycle) {
        $cycle['id'] = (int)$cycle['id'];
        $cycle['chick_count'] = (int)$cycle['chick_count'];
        $cycle['mortality'] = (int)$cycle['mortality'];
        $cycle['total_expenses'] = (int)$cycle['total_expenses'];
    }
    unset($cycle);

    // حساب العدد الإجمالي
    $countQuery = "SELECT COUNT(*) as total FROM cycles c INNER JOIN cycle_users cu ON c.id = cu.cycle_id WHERE cu.user_id = :user_id AND c.end_date_raw IS NOT NULL";
    if ($hasSearch) $countQuery .= " AND c.name LIKE :search";
    if ($hasDateFrom) $countQuery .= " AND DATE(c.start_date_raw) >= :date_from";
    if ($hasDateTo) $countQuery .= " AND DATE(c.start_date_raw) <= :date_to";

    $countStmt = $con->prepare($countQuery);
    $countStmt->bindParam(':user_id', $userId, PDO::PARAM_INT);
    if ($hasSearch) {
        $countStmt->bindParam(':search', $searchTerm, PDO::PARAM_STR);
    }
    if ($hasDateFrom) {
        $countStmt->bindParam(':date_from', $dateFrom, PDO::PARAM_STR);
    }
    if ($hasDateTo) {
        $countStmt->bindParam(':date_to', $dateTo, PDO::PARAM_STR);
    }
    $countStmt->execute();
    $totalCount = (int)$countStmt->fetchColumn();

    // ✅ إرسال الرد
    echo json_encode([
        'status' => 'success',
        'data' => [
            'cycles' => $cycles,
            'count' => count($cycles),
            'total_count' => $totalCount,
            'page' => $page,
            'limit' => $limit
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
