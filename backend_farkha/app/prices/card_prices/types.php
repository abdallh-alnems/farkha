<?php

require_once __DIR__ . '/../../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$data = Cache::remember('types_list', function () {
    $rows = Database::fetchAll("SELECT t.id, t.name, t.category_id, m.name as main_name FROM types t INNER JOIN product_categories m ON t.category_id = m.id ORDER BY t.category_id, t.id");
    if (empty($rows)) {
        Response::notFound('No types found');
    }

    $groupedData = [];
    foreach ($rows as $item) {
        $mainType = $item['main_name'];
        if (!isset($groupedData[$mainType])) {
            $groupedData[$mainType] = [];
        }
        $groupedData[$mainType][] = [
            'id' => $item['id'],
            'name' => $item['name'],
            'category_id' => $item['category_id'],
        ];
    }
    return $groupedData;
});

Response::success($data);
