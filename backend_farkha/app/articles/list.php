<?php

require_once __DIR__ . '/../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$data = Cache::remember('articles_list', function () {
    return ArticleModel::fetchList();
});

Response::success($data);
