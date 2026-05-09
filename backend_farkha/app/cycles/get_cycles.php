<?php

require_once __DIR__ . '/../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];

try {
    $cycles = CycleModel::fetchUserCycles($userId);

    foreach ($cycles as &$cycle) {
        $cycle['id'] = (int) $cycle['id'];
        $cycle['chick_count'] = (int) $cycle['chick_count'];
        $cycle['mortality'] = (int) $cycle['mortality'];
        $cycle['total_expenses'] = (int) $cycle['total_expenses'];
    }
    unset($cycle);

    Response::success([
        'cycles' => $cycles,
        'count' => count($cycles),
    ]);
} catch (PDOException $e) {
    error_log("get_cycles error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
