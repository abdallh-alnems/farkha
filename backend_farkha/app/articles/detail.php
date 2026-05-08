<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();

$id = Validator::getCombinedField('id');
Validator::required($id, 'id');
$id = (int) Validator::numeric($id, 'id', 1);

$data = Cache::remember("article_detail_{$id}", function () use ($id) {
    $result = ArticleModel::fetchDetail($id);
    if (!$result) {
        Response::notFound('Article');
    }
    return ['content' => $result['content']];
});

Response::success($data);
