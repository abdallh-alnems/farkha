<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class TodayPricesApi extends BaseApi {
    protected bool $requirePost = false;

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $mainType = $this->getValidatedMainType();
            if (!$mainType) {
                $this->error('Valid main type is required', 400);
            }
            $prices = PriceModel::fetchToday($mainType);
            $this->success($prices);
        }, 'today_prices');
    }
}

new TodayPricesApi();
