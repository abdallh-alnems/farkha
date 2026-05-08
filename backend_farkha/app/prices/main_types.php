<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();

$data = Cache::remember('main_categories', function () {
    return Database::fetchAll("SELECT id, name FROM product_categories ORDER BY id");
});

Response::success($data);
