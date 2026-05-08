<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();

$typeId = Validator::getCombinedField('type_id');
Validator::required($typeId, 'type_id');
$typeId = (int) Validator::numeric($typeId, 'type_id', 1);

$rawLimit = Validator::getCombinedField('limit');
$limit = ($rawLimit !== null && is_numeric($rawLimit)) ? max(1, min(1000, (int) $rawLimit)) : 30;

$beforeDate = Validator::getCombinedField('before_date');
if ($beforeDate !== null && trim($beforeDate) === '') {
    $beforeDate = null;
}

$typeRow = Database::fetchOne("SELECT id FROM types WHERE id = ?", [$typeId]);
if (empty($typeRow)) {
    Response::notFound('النوع غير موجود');
}

$history = PriceModel::fetchHistoryByType($typeId, $limit, $beforeDate);

Response::success($history);
