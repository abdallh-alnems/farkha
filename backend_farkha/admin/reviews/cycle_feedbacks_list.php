<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class CycleFeedbacksListApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $page = max(1, (int) ($this->getField('page') ?? 1));
            $pageSize = min(100, max(1, (int) ($this->getField('page_size') ?? 20)));
            $starredOnly = $this->getField('starred_only');
            $platform = $this->getField('platform');
            $dateFrom = $this->getField('date_from');
            $dateTo = $this->getField('date_to');
            $offset = ($page - 1) * $pageSize;

            $where = "1=1";
            $params = [];

            if ($starredOnly !== null && filter_var($starredOnly, FILTER_VALIDATE_BOOLEAN)) {
                $where .= " AND cf.is_starred = 1";
            }
            if ($platform !== null && in_array($platform, ['android', 'ios'], true)) {
                $where .= " AND cf.platform = ?";
                $params[] = $platform;
            }
            if ($dateFrom !== null) {
                $d = DateTime::createFromFormat('Y-m-d', $dateFrom);
                if (!$d || $d->format('Y-m-d') !== $dateFrom) {
                    $this->error('صيغة date_from غير صالحة (متوقع Y-m-d)', 400);
                }
                $where .= " AND cf.created_at >= ?";
                $params[] = $dateFrom . ' 00:00:00';
            }
            if ($dateTo !== null) {
                $d = DateTime::createFromFormat('Y-m-d', $dateTo);
                if (!$d || $d->format('Y-m-d') !== $dateTo) {
                    $this->error('صيغة date_to غير صالحة (متوقع Y-m-d)', 400);
                }
                $where .= " AND cf.created_at <= ?";
                $params[] = $dateTo . ' 23:59:59';
            }

            $total = (int) Database::fetchOne("SELECT COUNT(*) c FROM cycle_feedbacks cf WHERE {$where}", $params)['c'];

            $items = Database::fetchAll(
                "SELECT cf.*, u.name AS user_name FROM cycle_feedbacks cf LEFT JOIN users u ON u.id = cf.user_id
                 WHERE {$where} ORDER BY cf.created_at DESC LIMIT {$pageSize} OFFSET {$offset}",
                $params
            );

            $avg = (float) (Database::fetchOne("SELECT AVG(rating) a FROM cycle_feedbacks cf WHERE {$where}", $params)['a'] ?? 0);

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
