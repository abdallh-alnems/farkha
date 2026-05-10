<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class MeApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $admin = AdminAuth::currentAdmin();
            $this->success([
                'id' => (int) $admin['admin_id'],
                'username' => $admin['username'],
                'display_name' => $admin['display_name'],
                'role' => $admin['role'],
            ]);
        }, 'admin_me');
    }
}

new MeApi();
