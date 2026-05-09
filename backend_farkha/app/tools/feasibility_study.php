<?php

require_once __DIR__ . '/../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$data = Cache::remember('feasibility_study', function () {
    $rows = PriceModel::fetchFeasibilityStudy();
    if (empty($rows)) {
        Response::notFound('No feasibility study data found');
    }
    return $rows;
});

Response::success($data);
