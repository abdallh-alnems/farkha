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
                'reviews' => [
                    'app_total' => (int) Database::fetchOne("SELECT COUNT(*) c FROM app_reviews")['c'],
                    'app_avg' => (float) (Database::fetchOne("SELECT AVG(rating) a FROM app_reviews WHERE rating IS NOT NULL")['a'] ?? 0),
                    'cycle_total' => (int) Database::fetchOne("SELECT COUNT(*) c FROM cycle_feedbacks")['c'],
                    'cycle_avg' => (float) (Database::fetchOne("SELECT AVG(rating) a FROM cycle_feedbacks")['a'] ?? 0),
                ],
                'generated_at' => date('c'),
            ];
            $this->success($data);
        }, 'dashboard_overview');
    }
}

new DashboardOverviewApi();
