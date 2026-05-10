<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class CyclesListApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $page = max(1, (int) ($this->getField('page') ?? 1));
            $pageSize = min(100, max(1, (int) ($this->getField('page_size') ?? 20)));
            $status = $this->getField('status', 'all');
            $ownerId = $this->getField('owner_id');
            $offset = ($page - 1) * $pageSize;

            $where = "1=1";
            $params = [];

            if ($status === 'active') {
                $where .= " AND c.deleted_at IS NULL AND c.end_date_raw IS NULL";
            } elseif ($status === 'closed') {
                $where .= " AND c.end_date_raw IS NOT NULL AND c.deleted_at IS NULL";
            } elseif ($status === 'deleted') {
                $where .= " AND c.deleted_at IS NOT NULL";
            }

            if ($ownerId !== null) {
                $where .= " AND c.owner_user_id = ?";
                $params[] = (int) $ownerId;
            }

            $total = (int) Database::fetchOne(
                "SELECT COUNT(*) c FROM cycles c WHERE {$where}",
                $params
            )['c'];

            $items = Database::fetchAll(
                "SELECT c.id, c.name, c.owner_user_id, c.chick_count, c.breed,
                        c.start_date_raw, c.end_date_raw, c.deleted_at, c.created_at,
                        u.name AS owner_name
                 FROM cycles c
                 LEFT JOIN users u ON u.id = c.owner_user_id
                 WHERE {$where}
                 ORDER BY c.created_at DESC
                 LIMIT {$pageSize} OFFSET {$offset}",
                $params
            );

            $this->success([
                'items' => $items,
                'total' => $total,
                'page' => $page,
                'page_size' => $pageSize,
                'total_pages' => (int) ceil($total / $pageSize),
            ]);
        }, 'cycles_list');
    }
}

new CyclesListApi();
