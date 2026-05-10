<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class UsersListApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $page = max(1, (int) ($this->getField('page') ?? 1));
            $pageSize = min(100, max(1, (int) ($this->getField('page_size') ?? 20)));
            $q = trim($this->getField('q', ''));
            $offset = ($page - 1) * $pageSize;

            $where = "1=1";
            $params = [];

            if ($q !== '') {
                $where .= " AND (u.name LIKE ? OR u.phone LIKE ? OR u.firebase_uid LIKE ?)";
                $like = "%{$q}%";
                $params = [$like, $like, $like];
            }

            $total = (int) Database::fetchOne(
                "SELECT COUNT(*) c FROM users u WHERE {$where}",
                $params
            )['c'];

            $items = Database::fetchAll(
                "SELECT u.id, u.name, u.phone, u.firebase_uid, u.created_at, u.updated_at,
                        (SELECT COUNT(*) FROM cycle_users cu WHERE cu.user_id = u.id) AS cycles_count
                 FROM users u
                 WHERE {$where}
                 ORDER BY u.id DESC
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
        }, 'users_list');
    }
}

new UsersListApi();
