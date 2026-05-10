<?php

require_once __DIR__ . '/../../config/bootstrap.php';
require_once __DIR__ . '/../../core/RemoteConfigService.php';

class UpdateRemoteConfigApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $name = $this->getField('name');
            $value = $this->getField('value');
            $description = $this->getField('description', '');

            Validator::required($name, 'name');
            Validator::required($value, 'value');
            Validator::maxLength($name, 100, 'name');

            $data = RemoteConfigService::setParameter($name, $value, $description);
            $this->success($data);
        }, 'remote_config_update');
    }
}

new UpdateRemoteConfigApi();
