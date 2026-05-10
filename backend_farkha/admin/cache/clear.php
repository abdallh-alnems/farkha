<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class CacheClearApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $count = Cache::getInstance()->clear();
            AdminAuth::logAction('cache.clear', 'cache', null, ['files_deleted' => $count]);
            $this->success(['files_deleted' => $count]);
        }, 'cache_clear');
    }
}

new CacheClearApi();
