<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class CycleFeedbacksListApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $page = max(1, (int) ($this->getField('page') ?? 1));
            $pageSize = min(100, max(1, (int) ($this->getField('page_size') ?? 20)));
            $offset = ($page - 1) * $pageSize;

            $total = (int) Database::fetchOne("SELECT COUNT(*) c FROM cycle_feedbacks")['c'];

            $items = Database::fetchAll(
                "SELECT cf.*, u.name AS user_name FROM cycle_feedbacks cf LEFT JOIN users u ON u.id = cf.user_id
                 ORDER BY cf.created_at DESC LIMIT {$pageSize} OFFSET {$offset}"
            );

            $avg = (float) (Database::fetchOne("SELECT AVG(rating) a FROM cycle_feedbacks")['a'] ?? 0);

            $this->success([
                'items' => $items,
                'total' => $total,
                'page' => $page,
                'page_size' => $pageSize,
                'average' => round($avg, 2),
            ]);
        }, 'cycle_feedbacks_list');
    }
}

new CycleFeedbacksListApi();
