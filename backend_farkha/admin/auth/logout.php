<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class LogoutApi extends AdminBaseApi {
    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            AdminAuth::logout();
            $this->success(null);
        }, 'admin_logout');
    }
}

new LogoutApi();
