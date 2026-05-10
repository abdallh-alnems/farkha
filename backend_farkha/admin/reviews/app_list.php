<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class AppReviewsListApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $page = max(1, (int) ($this->getField('page') ?? 1));
            $pageSize = min(100, max(1, (int) ($this->getField('page_size') ?? 20)));
            $minRating = $this->getField('min_rating');
            $maxRating = $this->getField('max_rating');
            $starredOnly = $this->getField('starred_only');
            $platform = $this->getField('platform');
            $dateFrom = $this->getField('date_from');
            $dateTo = $this->getField('date_to');
            $offset = ($page - 1) * $pageSize;

            $where = "1=1";
            $params = [];

            if ($minRating !== null) {
                $where .= " AND ar.rating >= ?";
                $params[] = (int) $minRating;
            }
            if ($maxRating !== null) {
                $where .= " AND ar.rating <= ?";
                $params[] = (int) $maxRating;
            }
            if ($starredOnly !== null && filter_var($starredOnly, FILTER_VALIDATE_BOOLEAN)) {
                $where .= " AND ar.is_starred = 1";
            }
            if ($platform !== null && in_array($platform, ['android', 'ios'], true)) {
                $where .= " AND ar.platform = ?";
                $params[] = $platform;
            }
            if ($dateFrom !== null) {
                $where .= " AND ar.created_at >= ?";
                $params[] = $dateFrom . ' 00:00:00';
            }
            if ($dateTo !== null) {
                $where .= " AND ar.created_at <= ?";
                $params[] = $dateTo . ' 23:59:59';
            }

            $total = (int) Database::fetchOne("SELECT COUNT(*) c FROM app_reviews ar WHERE {$where}", $params)['c'];

            $items = Database::fetchAll(
                "SELECT ar.*, u.name AS user_name FROM app_reviews ar LEFT JOIN users u ON u.id = ar.user_id
                 WHERE {$where} ORDER BY ar.created_at DESC LIMIT {$pageSize} OFFSET {$offset}",
                $params
            );

            $avg = (float) (Database::fetchOne("SELECT AVG(rating) a FROM app_reviews WHERE rating IS NOT NULL")['a'] ?? 0);
            $distribution = Database::fetchAll(
                "SELECT rating, COUNT(*) c FROM app_reviews WHERE rating IS NOT NULL GROUP BY rating ORDER BY rating DESC"
            );

            $this->success([
                'items' => $items,
                'total' => $total,
                'page' => $page,
                'page_size' => $pageSize,
                'average' => round($avg, 2),
                'distribution' => $distribution,
            ]);
        }, 'app_reviews_list');
    }
}

new AppReviewsListApi();
