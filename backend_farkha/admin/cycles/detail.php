<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class CycleDetailApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $cycleId = (int) $this->requireNumeric('cycle_id', 1);

            $cycle = Database::fetchOne(
                "SELECT c.*, u.name AS owner_name FROM cycles c LEFT JOIN users u ON u.id = c.owner_user_id WHERE c.id = ? LIMIT 1",
                [$cycleId]
            );

            if (!$cycle) {
                $this->error('Cycle not found', 404);
            }

            $members = Database::fetchAll(
                "SELECT cu.user_id, cu.role, cu.status, u.name, u.phone
                 FROM cycle_users cu JOIN users u ON u.id = cu.user_id
                 WHERE cu.cycle_id = ?",
                [$cycleId]
            );

            $data = Database::fetchAll(
                "SELECT * FROM cycle_data WHERE cycle_id = ? ORDER BY entry_date DESC LIMIT 100",
                [$cycleId]
            );

            $expenses = Database::fetchAll(
                "SELECT * FROM cycle_expenses WHERE cycle_id = ? ORDER BY entry_date DESC LIMIT 100",
                [$cycleId]
            );

            $sales = Database::fetchAll(
                "SELECT * FROM cycle_sales WHERE cycle_id = ? ORDER BY sale_date DESC",
                [$cycleId]
            );

            $notes = Database::fetchAll(
                "SELECT * FROM cycle_notes WHERE cycle_id = ? ORDER BY entry_date DESC LIMIT 50",
                [$cycleId]
            );

            $this->success([
                'cycle' => $cycle,
                'members' => $members,
                'data' => $data,
                'expenses' => $expenses,
                'sales' => $sales,
                'notes' => $notes,
            ]);
        }, 'cycle_detail');
    }
}

new CycleDetailApi();
