<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();

$mainType = Validator::getCombinedField('type');
Validator::required($mainType, 'type');
$mainType = (int) Validator::numeric($mainType, 'type', 1);

$data = PriceModel::fetchByMainType($mainType);

if (empty($data)) {
    Response::notFound('No types prices found for the specified main type');
}

Response::success($data);
