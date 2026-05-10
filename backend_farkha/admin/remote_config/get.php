<?php

require_once __DIR__ . '/../../config/bootstrap.php';
require_once __DIR__ . '/../../core/RemoteConfigService.php';

class GetRemoteConfigApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $data = RemoteConfigService::getAll();
            $this->success($data);
        }, 'remote_config_get');
    }
}

new GetRemoteConfigApi();
