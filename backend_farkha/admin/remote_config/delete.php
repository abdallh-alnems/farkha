<?php

require_once __DIR__ . '/../../config/bootstrap.php';
require_once __DIR__ . '/../../core/RemoteConfigService.php';

class DeleteRemoteConfigApi extends AdminBaseApi {
    protected ?string $minRole = 'superadmin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $name = $this->getField('name');
            Validator::required($name, 'name');

            $data = RemoteConfigService::deleteParameter($name);
            $this->success($data);
        }, 'remote_config_delete');
    }
}

new DeleteRemoteConfigApi();
