<?php

require_once __DIR__ . '/../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$categories = Cache::remember('main_categories', function () {
    return Database::fetchAll("SELECT id, name FROM product_categories ORDER BY id");
});

$groups = [];

foreach ($categories as $cat) {
    $prices = PriceModel::fetchByMainType((int) $cat['id']);
    if (!empty($prices)) {
        $groups[] = [
            'id' => (int) $cat['id'],
            'name' => $cat['name'],
            'prices' => $prices,
        ];
    }
}

Response::success($groups);
