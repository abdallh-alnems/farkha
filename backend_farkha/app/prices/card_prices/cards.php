<?php

require_once __DIR__ . '/../../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$typeIds = Validator::getCombinedField('type_ids');
$sanitizedIds = Validator::sanitizeTypeIds($typeIds);

if (empty($sanitizedIds)) {
    Response::fail('يجب تحديد أنواع الأسعار المطلوبة', 400);
}

$data = PriceModel::fetchStream($sanitizedIds);

if (empty($data)) {
    Response::notFound('لا توجد بيانات متاحة');
}

Response::success($data);
