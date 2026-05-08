<?php

require_once __DIR__ . '/../config/bootstrap.php';

Auth::checkAppCheck();

$period = Validator::getCombinedField('period') ?? '7days';
$all = Validator::getCombinedField('all');

try {
    if ($all === 'true' || $all === true) {
        $data = [
            '7days' => ['period' => '7days', 'data' => AnalyticsModel::fetchUnifiedAnalytics('7days')],
            '30days' => ['period' => '30days', 'data' => AnalyticsModel::fetchUnifiedAnalytics('30days')],
            '1year' => ['period' => '1year', 'data' => AnalyticsModel::fetchUnifiedAnalytics('1year')],
            'alltime' => ['period' => 'alltime', 'data' => AnalyticsModel::fetchUnifiedAnalytics('alltime')],
        ];
        Response::success($data);
    } else {
        $data = AnalyticsModel::fetchUnifiedAnalytics($period);
        Response::success([
            'period' => $period,
            'data' => $data,
        ]);
    }
} catch (PDOException $e) {
    error_log("tools_analytics error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
