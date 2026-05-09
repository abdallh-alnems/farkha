<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();
Auth::requirePost();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
$type = $input['type'] ?? null;
$deleteType = $input['delete_type'] ?? null;
$itemId = $input['item_id'] ?? null;
$label = $input['label'] ?? null;
$metricType = $input['metric_type'] ?? null;

Validator::required($cycleId, 'cycle_id');
$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);

Validator::required($type, 'type');
$type = Validator::enum($type, ['data', 'expense', 'sale', 'inventory'], 'type');

Validator::required($deleteType, 'delete_type');
$deleteType = Validator::enum($deleteType, ['single', 'by_label', 'by_metric_type'], 'delete_type');

if ($deleteType === 'single') {
    Validator::required($itemId, 'item_id');
    $itemId = (int) Validator::numeric($itemId, 'item_id', 1);
}

if ($deleteType === 'by_label') {
    Validator::required($label, 'label');
}

if ($deleteType === 'by_metric_type') {
    Validator::required($metricType, 'metric_type');
}

$con = db();
CycleModel::requireWriteAccess($con, $cycleId, $userId);

try {
    $query = null;
    $params = [':cycle_id' => $cycleId];

    if ($type === 'data') {
        if ($deleteType === 'single') {
            $query = "DELETE FROM cycle_data WHERE id = :id AND cycle_id = :cycle_id";
            $params[':id'] = $itemId;
        } elseif ($deleteType === 'by_metric_type') {
            $query = "DELETE FROM cycle_data WHERE metric_type = :metric_type AND cycle_id = :cycle_id";
            $params[':metric_type'] = $metricType;
        } else {
            $query = "DELETE FROM cycle_data WHERE metric_type = :metric_type AND cycle_id = :cycle_id";
            $params[':metric_type'] = $label;
        }
    } elseif ($type === 'expense') {
        if ($deleteType === 'single') {
            $query = "DELETE FROM cycle_expenses WHERE id = :id AND cycle_id = :cycle_id";
            $params[':id'] = $itemId;
        } else {
            $query = "DELETE FROM cycle_expenses WHERE label = :label AND cycle_id = :cycle_id";
            $params[':label'] = $label;
        }
    } elseif ($type === 'sale') {
        if ($deleteType === 'single') {
            $query = "DELETE FROM cycle_sales WHERE id = :id AND cycle_id = :cycle_id";
            $params[':id'] = $itemId;
        } else {
            Response::fail('delete_type "by_label" is not supported for sales', 400);
        }
    } elseif ($type === 'inventory') {
        if ($deleteType === 'single') {
            $query = "DELETE FROM cycle_inventory WHERE id = :id AND cycle_id = :cycle_id";
            $params[':id'] = $itemId;
        } else {
            $query = "DELETE FROM cycle_inventory WHERE item_name = :item_name AND cycle_id = :cycle_id";
            $params[':item_name'] = $label;
        }
    }

    $stmt = $con->prepare($query);
    $stmt->execute($params);
    $deletedCount = $stmt->rowCount();

    if ($deletedCount === 0) {
        Response::notFound('No items found to delete');
    }

    Response::success([
        'message' => $deleteType === 'single' ? 'Item deleted successfully' : 'All items with this label deleted successfully',
        'deleted_count' => $deletedCount,
    ]);
} catch (PDOException $e) {
    error_log("delete_cycle_item error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
