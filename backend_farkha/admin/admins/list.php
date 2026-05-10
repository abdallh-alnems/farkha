<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class AdminListApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $rows = Database::fetchAll(
                "SELECT id, username, display_name, role, is_active, last_login_at, last_login_ip, created_at
                 FROM admin_users ORDER BY role = 'superadmin' DESC, role = 'admin' DESC, created_at DESC"
            );

            $list = array_map(function ($r) {
                return [
                    'id' => (int) $r['id'],
                    'username' => $r['username'],
                    'display_name' => $r['display_name'],
                    'role' => $r['role'],
                    'is_active' => (bool) $r['is_active'],
                    'last_login_at' => $r['last_login_at'],
                    'last_login_ip' => $r['last_login_ip'],
                    'created_at' => $r['created_at'],
                ];
            }, $rows);

            $this->success($list);
        }, 'admin_list');
    }
}

new AdminListApi();
