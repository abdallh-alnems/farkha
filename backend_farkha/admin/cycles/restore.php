<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class CycleRestoreApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $cycleId = (int) $this->requireNumeric('cycle_id', 1);

            $cycle = Database::fetchOne("SELECT id, name, deleted_at FROM cycles WHERE id = ? LIMIT 1", [$cycleId]);
            if (!$cycle) {
                $this->error('Cycle not found', 404);
            }
            if ($cycle['deleted_at'] === null) {
                $this->error('Cycle is not deleted', 400);
            }

            Database::execute("UPDATE cycles SET deleted_at = NULL WHERE id = ?", [$cycleId]);

            AdminAuth::logAction('cycle.restore', 'cycle', $cycleId, ['name' => $cycle['name']]);
            $this->success(null);
        }, 'cycle_restore');
    }
}

new CycleRestoreApi();
