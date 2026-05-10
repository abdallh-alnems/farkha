<?php

require_once __DIR__ . '/../../config/bootstrap.php';
require_once __DIR__ . '/../../core/NotificationService.php';

class CycleSoftDeleteApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $cycleId = (int) $this->requireNumeric('cycle_id', 1);

            $cycle = Database::fetchOne("SELECT id, name, deleted_at FROM cycles WHERE id = ? LIMIT 1", [$cycleId]);
            if (!$cycle) {
                $this->error('Cycle not found', 404);
            }
            if ($cycle['deleted_at'] !== null) {
                $this->error('Cycle already deleted', 400);
            }

            $members = Database::fetchAll(
                "SELECT user_id FROM cycle_users WHERE cycle_id = ? AND status = 'accepted'",
                [$cycleId]
            );

            Database::execute("UPDATE cycles SET deleted_at = NOW() WHERE id = ?", [$cycleId]);

            AdminAuth::logAction('cycle.soft_delete', 'cycle', $cycleId, ['name' => $cycle['name']]);

            $con = Database::getInstance();
            foreach ($members as $m) {
                NotificationService::sendToUser($con, (int) $m['user_id'],
                    'تم حذف الدورة',
                    "تم حذف دورة \"{$cycle['name']}\" من قبل الإدارة",
                    ['type' => 'cycle_deleted', 'cycle_id' => (string) $cycleId]
                );
            }

            $this->success(null);
        }, 'cycle_soft_delete');
    }
}

new CycleSoftDeleteApi();
