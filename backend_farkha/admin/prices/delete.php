<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class DeletePricesApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $type = $this->requireNumeric('type', 1);

            $result = PriceModel::deleteLatest((int) $type);
            if ($result > 0) {
                AdminAuth::logAction('price.delete', 'price', $type);
                Cache::getInstance()->clear();
                $this->success(null);
            } else {
                $this->error('No price found to delete', 404);
            }
        }, 'delete_price');
    }
}

new DeletePricesApi();
