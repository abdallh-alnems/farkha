<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class DeletePricesApi extends BaseApi {
    protected bool $requireAuth = true;
    protected bool $requirePost = true;

    public function __construct() {
        parent::__construct();
        RateLimiter::enforceIpLimit();
        $this->handleRequest(function () {
            $type = $this->requireNumeric('type', 1);

            $result = PriceModel::deleteLatest((int) $type);
            if ($result > 0) {
                Cache::getInstance()->clear();
                $this->success(null);
            } else {
                $this->error('No price found to delete', 404);
            }
        }, 'delete_price');
    }
}

new DeletePricesApi();
