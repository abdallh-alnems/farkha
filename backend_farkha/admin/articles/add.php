<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class AddArticleApi extends BaseApi {
    protected bool $requireAuth = true;
    protected bool $requirePost = true;

    public function __construct() {
        parent::__construct();
        Auth::requireAppCheck();
        $this->handleRequest(function () {
            $title = $this->getField('title');
            $content = $this->getField('content');

            Validator::required($title, 'Title');
            Validator::required($content, 'Content');
            Validator::maxLength($title, 255, 'Title');

            $id = ArticleModel::create($title, $content);
            Cache::getInstance()->delete('articles_list');
            $this->success(['id' => $id]);
        }, 'add_article');
    }
}

new AddArticleApi();
