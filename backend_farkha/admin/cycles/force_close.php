<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class CycleForceCloseApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $cycleId = (int) $this->requireNumeric('cycle_id', 1);
            $endDate = $this->getField('end_date', date('Y-m-d'));

            $cycle = Database::fetchOne("SELECT * FROM cycles WHERE id = ? AND deleted_at IS NULL LIMIT 1", [$cycleId]);
            if (!$cycle) {
                $this->error('Cycle not found', 404);
            }
            if ($cycle['end_date_raw'] !== null) {
                $this->error('Cycle already closed', 400);
            }

            Database::execute(
                "UPDATE cycles SET end_date_raw = ? WHERE id = ?",
                [$endDate, $cycleId]
            );

            AdminAuth::logAction('cycle.force_close', 'cycle', $cycleId, [
                'name' => $cycle['name'],
                'end_date' => $endDate,
            ]);

            $this->success(null);
        }, 'cycle_force_close');
    }
}

new CycleForceCloseApi();
