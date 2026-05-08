<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();

$data = Cache::remember('broiler_latest_price', function () {
    $result = PriceModel::fetchLatestByType(1);
    if (!$result) {
        Response::notFound('No broiler chicken price data found');
    }
    return ['price' => $result['price']];
});

Response::success($data);
