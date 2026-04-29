<?php
/**
 * Delete Cycle Item API
 * حذف سجل واحد أو جميع السجلات بنفس label من cycle_data أو cycle_expenses
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
include __DIR__ . '/../../core/queries/queries.php';

// 🔒 حماية الـ API endpoint
checkAuthenticate();
requirePostMethod();

// قراءة البيانات المرسلة
$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$cycleId = $input['cycle_id'] ?? null;
$type = $input['type'] ?? null; // "data" أو "expense"
$deleteType = $input['delete_type'] ?? null; // "single" أو "by_label"
$itemId = $input['item_id'] ?? null; // مطلوب عند delete_type = "single"
$label = $input['label'] ?? null; // مطلوب عند delete_type = "by_label"

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

// التحقق من type
if (!$type || !in_array($type, ['data', 'expense', 'sale', 'inventory'])) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'type must be "data", "expense", "sale" or "inventory"'
    ]);
    exit;
}

// التحقق من delete_type
if (!$deleteType || !in_array($deleteType, ['single', 'by_label'])) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'delete_type must be "single" or "by_label"'
    ]);
    exit;
}

// التحقق من البيانات المطلوبة حسب delete_type
if ($deleteType === 'single' && (!$itemId || !is_numeric($itemId))) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'item_id is required and must be a number when delete_type is "single"'
    ]);
    exit;
}

if ($deleteType === 'by_label' && !$label) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'label is required when delete_type is "by_label"'
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

    // تحديد الاستعلام المناسب
    $query = null;
    $params = [':cycle_id' => (int)$cycleId];

    if ($type === 'data') {
        if ($deleteType === 'single') {
            $query = Queries::deleteCycleDataByIdQuery();
            $params[':id'] = (int)$itemId;
        } else {
            $query = Queries::deleteCycleDataByLabelQuery();
            $params[':label'] = $label;
        }
    } elseif ($type === 'expense') {
        if ($deleteType === 'single') {
            $query = Queries::deleteCycleExpenseByIdQuery();
            $params[':id'] = (int)$itemId;
        } else {
            $query = Queries::deleteCycleExpenseByLabelQuery();
            $params[':label'] = $label;
        }
    } elseif ($type === 'sale') {
        if ($deleteType === 'single') {
            $query = Queries::deleteCycleSaleByIdQuery();
            $params[':id'] = (int)$itemId;
        } else {
            // No support for deleting sales by label
            http_response_code(400);
            echo json_encode([
                'status' => 'fail',
                'message' => 'delete_type "by_label" is not supported for sales'
            ]);
            exit;
        }
    } elseif ($type === 'inventory') {
        if ($deleteType === 'single') {
            $query = Queries::deleteCycleInventoryByIdQuery();
            $params[':id'] = (int)$itemId;
        } else {
            $query = Queries::deleteCycleInventoryByItemNameQuery();
            $params[':item_name'] = $label;
        }
    }

    // تنفيذ الحذف
    $stmt = $con->prepare($query);
    $stmt->execute($params);
    $deletedCount = $stmt->rowCount();

    if ($deletedCount === 0) {
        http_response_code(404);
        echo json_encode([
            'status' => 'fail',
            'message' => 'No items found to delete'
        ]);
        exit;
    }

    // ✅ إرسال الرد
    echo json_encode([
        'status' => 'success',
        'message' => $deleteType === 'single' 
            ? 'Item deleted successfully' 
            : 'All items with this label deleted successfully',
        'deleted_count' => $deletedCount
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

