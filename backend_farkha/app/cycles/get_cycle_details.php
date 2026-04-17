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

    // جلب بيانات الدورة (مرتبة تصاعدياً لعرض التايملاين)
    $stmtData = $con->prepare(Queries::fetchCycleDataChronologicalQuery());
    $stmtData->execute([':cycle_id' => (int)$cycleId]);
    $cycleData = $stmtData->fetchAll(PDO::FETCH_ASSOC);

    // جلب مصاريف الدورة (مرتبة تصاعدياً حسب التاريخ)
    $stmtExp = $con->prepare(Queries::fetchCycleExpensesChronologicalQuery());
    $stmtExp->execute([':cycle_id' => (int)$cycleId]);
    $cycleExpenses = $stmtExp->fetchAll(PDO::FETCH_ASSOC);

    // جلب ملاحظات الدورة
    $stmtNotes = $con->prepare(Queries::fetchCycleNotesQuery());
    $stmtNotes->execute([':cycle_id' => (int)$cycleId]);
    $cycleNotes = $stmtNotes->fetchAll(PDO::FETCH_ASSOC);

    // جلب أعضاء الدورة
    $stmtMembers = $con->prepare(Queries::fetchCycleMembersQuery());
    $stmtMembers->execute([':cycle_id' => (int)$cycleId]);
    $cycleMembers = $stmtMembers->fetchAll(PDO::FETCH_ASSOC);

    // جلب سجل المبيعات
    $stmtSales = $con->prepare(Queries::fetchCycleSalesQuery());
    $stmtSales->execute([':cycle_id' => (int)$cycleId]);
    $cycleSales = $stmtSales->fetchAll(PDO::FETCH_ASSOC);

    // جلب ملخص المخزون
    $stmtInventory = $con->prepare(Queries::fetchCycleInventorySummaryQuery());
    $stmtInventory->execute([':cycle_id' => (int)$cycleId]);
    $inventorySummary = $stmtInventory->fetchAll(PDO::FETCH_ASSOC);

    // ✅ إرسال الرد
    echo json_encode([
        'status' => 'success',
        'data' => [
            'cycle'            => $cycleDetails,
            'data'             => $cycleData,
            'expenses'         => $cycleExpenses,
            'notes'            => $cycleNotes,
            'members'          => $cycleMembers,
            'sales'            => $cycleSales,
            'inventory'        => $inventorySummary,
            'data_count'       => count($cycleData),
            'expenses_count'   => count($cycleExpenses),
            'notes_count'      => count($cycleNotes),
            'members_count'    => count($cycleMembers),
            'sales_count'      => count($cycleSales),
            'inventory_count'  => count($inventorySummary)
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

