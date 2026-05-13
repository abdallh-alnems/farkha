<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class AdminListApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $page = max(1, (int) ($this->getField('page') ?? 1));
            $pageSize = min(100, max(1, (int) ($this->getField('page_size') ?? 50)));
            $offset = ($page - 1) * $pageSize;

            $total = (int) Database::fetchOne("SELECT COUNT(*) c FROM admin_users", [])['c'];
            $totalPages = (int) ceil($total / $pageSize);

            if ($page > $totalPages && $total > 0) {
                $this->error('الصفحة المطلوبة خارج النطاق', 400);
            }

            $rows = Database::fetchAll(
                "SELECT id, username, display_name, role, is_active, last_login_at, created_at
                 FROM admin_users ORDER BY role = 'superadmin' DESC, role = 'admin' DESC, created_at DESC
                 LIMIT ? OFFSET ?",
                [$pageSize, $offset]
            );

            $list = array_map(function ($r) {
                return [
                    'id' => (int) $r['id'],
                    'username' => $r['username'],
                    'display_name' => $r['display_name'],
                    'role' => $r['role'],
                    'is_active' => (bool) $r['is_active'],
                    'last_login_at' => $r['last_login_at'],
                    'created_at' => $r['created_at'],
                ];
            }, $rows);

            $this->success([
                'items' => $list,
                'total' => $total,
                'page' => $page,
                'page_size' => $pageSize,
                'total_pages' => $totalPages,
            ]);
        }, 'admin_list');
    }
}

new AdminListApi();
