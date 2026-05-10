<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class DashboardOverviewApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $data = [
                'users' => [
                    'total' => (int) Database::fetchOne("SELECT COUNT(*) c FROM users")['c'],
                    'verified_phone' => (int) Database::fetchOne("SELECT COUNT(*) c FROM users WHERE phone IS NOT NULL")['c'],
                    'new_today' => (int) Database::fetchOne("SELECT COUNT(*) c FROM users WHERE DATE(created_at) = CURDATE()")['c'],
                    'new_7d' => (int) Database::fetchOne("SELECT COUNT(*) c FROM users WHERE created_at >= NOW() - INTERVAL 7 DAY")['c'],
                    'new_30d' => (int) Database::fetchOne("SELECT COUNT(*) c FROM users WHERE created_at >= NOW() - INTERVAL 30 DAY")['c'],
                    'deletions_30d' => (int) Database::fetchOne("SELECT COUNT(*) c FROM account_deletions WHERE deleted_at >= NOW() - INTERVAL 30 DAY")['c'],
                ],
                'cycles' => [
                    'total_active' => (int) Database::fetchOne("SELECT COUNT(*) c FROM cycles WHERE deleted_at IS NULL AND end_date_raw IS NULL")['c'],
                    'total_closed' => (int) Database::fetchOne("SELECT COUNT(*) c FROM cycles WHERE end_date_raw IS NOT NULL")['c'],
                    'total_deleted' => (int) Database::fetchOne("SELECT COUNT(*) c FROM cycles WHERE deleted_at IS NOT NULL")['c'],
                    'created_7d' => (int) Database::fetchOne("SELECT COUNT(*) c FROM cycles WHERE created_at >= NOW() - INTERVAL 7 DAY")['c'],
                ],
                'devices' => [
                    'total' => (int) Database::fetchOne("SELECT COUNT(*) c FROM user_devices")['c'],
                    'android' => (int) Database::fetchOne("SELECT COUNT(*) c FROM user_devices WHERE platform='android'")['c'],
                    'ios' => (int) Database::fetchOne("SELECT COUNT(*) c FROM user_devices WHERE platform='ios'")['c'],
                    'active_7d' => (int) Database::fetchOne("SELECT COUNT(*) c FROM user_devices WHERE last_active >= NOW() - INTERVAL 7 DAY")['c'],
                ],
                'tools' => [
                    'usage_today' => (int) Database::fetchOne("SELECT COALESCE(SUM(usage_count),0) c FROM tools_usage WHERE usage_date = CURDATE()")['c'],
                    'usage_7d' => (int) Database::fetchOne("SELECT COALESCE(SUM(usage_count),0) c FROM tools_usage WHERE usage_date >= CURDATE() - INTERVAL 6 DAY")['c'],
                    'top_today' => Database::fetchAll("SELECT tool_id, usage_count FROM tools_usage WHERE usage_date = CURDATE() ORDER BY usage_count DESC LIMIT 5"),
                ],
                'reviews' => [
                    'app_total' => (int) Database::fetchOne("SELECT COUNT(*) c FROM app_reviews")['c'],
                    'app_avg' => (float) (Database::fetchOne("SELECT AVG(rating) a FROM app_reviews WHERE rating IS NOT NULL")['a'] ?? 0),
                    'cycle_total' => (int) Database::fetchOne("SELECT COUNT(*) c FROM cycle_feedbacks")['c'],
                    'cycle_avg' => (float) (Database::fetchOne("SELECT AVG(rating) a FROM cycle_feedbacks")['a'] ?? 0),
                ],
                'prices' => [
                    'total_records' => (int) Database::fetchOne("SELECT COUNT(*) c FROM prices")['c'],
                    'updated_today' => (int) Database::fetchOne("SELECT COUNT(*) c FROM prices WHERE DATE(date) = CURDATE()")['c'],
                ],
                'timeline_30d' => [
                    'users' => Database::fetchAll(
                        "SELECT DATE(created_at) d, COUNT(*) c FROM users
                         WHERE created_at >= CURDATE() - INTERVAL 29 DAY
                         GROUP BY DATE(created_at) ORDER BY d"
                    ),
                    'cycles' => Database::fetchAll(
                        "SELECT DATE(created_at) d, COUNT(*) c FROM cycles
                         WHERE created_at >= CURDATE() - INTERVAL 29 DAY
                         GROUP BY DATE(created_at) ORDER BY d"
                    ),
                ],
                'generated_at' => date('c'),
            ];
            $this->success($data);
        }, 'dashboard_overview');
    }
}

new DashboardOverviewApi();
