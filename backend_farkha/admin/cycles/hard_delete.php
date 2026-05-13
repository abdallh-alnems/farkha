<?php

require_once __DIR__ . '/../../config/bootstrap.php';
require_once __DIR__ . '/../../core/NotificationService.php';

class CycleHardDeleteApi extends AdminBaseApi {
    protected ?string $minRole = 'superadmin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $cycleId = (int) $this->requireNumeric('cycle_id', 1);

            $cycle = Database::fetchOne("SELECT id, name FROM cycles WHERE id = ? LIMIT 1", [$cycleId]);
            if (!$cycle) {
                $this->error('Cycle not found', 404);
            }

            $members = Database::fetchAll(
                "SELECT user_id FROM cycle_users WHERE cycle_id = ?",
                [$cycleId]
            );

            AdminAuth::logAction('cycle.hard_delete', 'cycle', $cycleId, ['name' => $cycle['name']]);

            Database::execute("DELETE FROM cycle_notes WHERE cycle_id = ?", [$cycleId]);
            Database::execute("DELETE FROM cycle_sales WHERE cycle_id = ?", [$cycleId]);
            Database::execute("DELETE FROM cycle_expenses WHERE cycle_id = ?", [$cycleId]);
            Database::execute("DELETE FROM cycle_data WHERE cycle_id = ?", [$cycleId]);
            Database::execute("DELETE FROM cycle_inventory WHERE cycle_id = ?", [$cycleId]);
            Database::execute("DELETE FROM cycle_users WHERE cycle_id = ?", [$cycleId]);
            Database::execute("DELETE FROM cycle_invitations WHERE cycle_id = ?", [$cycleId]);
            Database::execute("DELETE FROM cycles WHERE id = ?", [$cycleId]);

            $con = Database::getInstance();
            foreach ($members as $m) {
                try {
                    $uid = (int) $m['user_id'];
                    $locale = I18n::userLocale($con, $uid);
                    NotificationService::sendToUser($con, $uid,
                        I18n::get('notif.cycle_hard_deleted.title', [], $locale),
                        I18n::get('notif.cycle_hard_deleted.body', ['name' => $cycle['name']], $locale),
                        ['type' => 'cycle_hard_deleted', 'cycle_id' => (string) $cycleId]
                    );
                } catch (Exception $e) {
                    error_log("Failed to notify user {$m['user_id']} of cycle hard delete: " . $e->getMessage());
                }
            }

            $this->success(null);
        }, 'cycle_hard_delete');
    }
}

new CycleHardDeleteApi();
