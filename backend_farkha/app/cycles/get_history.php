<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$search = isset($input['search']) ? trim($input['search']) : '';
$dateFrom = isset($input['date_from']) ? trim($input['date_from']) : '';
$dateTo = isset($input['date_to']) ? trim($input['date_to']) : '';
$page = isset($input['page']) ? max(1, (int) $input['page']) : 1;
$limit = isset($input['limit']) ? max(1, (int) $input['limit']) : 5;
$offset = ($page - 1) * $limit;

$con = db();

try {
    $hasSearch = !empty($search);
    $hasDateFrom = !empty($dateFrom);
    $hasDateTo = !empty($dateTo);

    $cycles = CycleModel::fetchHistoryCycles($con, $userId, $limit, $offset,
        $hasSearch ? $search : null,
        $hasDateFrom ? $dateFrom : null,
        $hasDateTo ? $dateTo : null
    );

    foreach ($cycles as &$cycle) {
        $cycle['id'] = (int) $cycle['id'];
        $cycle['chick_count'] = (int) $cycle['chick_count'];
        $cycle['mortality'] = (int) $cycle['mortality'];
        $cycle['total_expenses'] = (int) $cycle['total_expenses'];
    }
    unset($cycle);

    $where = "cu.user_id = :uid AND c.end_date_raw IS NOT NULL AND cu.status = 'accepted'";
    $countParams = [':uid' => $userId];
    if ($hasSearch) {
        $where .= " AND c.name LIKE :search";
        $countParams[':search'] = "%{$search}%";
    }
    if ($hasDateFrom) {
        $where .= " AND DATE(c.start_date_raw) >= :df";
        $countParams[':df'] = $dateFrom;
    }
    if ($hasDateTo) {
        $where .= " AND DATE(c.start_date_raw) <= :dt";
        $countParams[':dt'] = $dateTo;
    }

    $totalCount = (int) Database::fetchOne(
        "SELECT COUNT(*) as total FROM cycles c INNER JOIN cycle_users cu ON c.id = cu.cycle_id WHERE {$where}",
        $countParams
    )['total'];

    Response::success([
        'cycles' => $cycles,
        'count' => count($cycles),
        'total_count' => $totalCount,
        'page' => $page,
        'limit' => $limit,
    ]);
} catch (PDOException $e) {
    error_log("get_history error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
