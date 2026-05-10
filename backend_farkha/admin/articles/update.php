<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class UpdateArticleApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $id = $this->requireNumeric('id', 1);
            $title = $this->getField('title');
            $content = $this->getField('content');

            Validator::required($title, 'Title');
            Validator::required($content, 'Content');
            Validator::maxLength($title, 255, 'Title');

            $result = ArticleModel::update((int) $id, $title, $content);
            if ($result > 0) {
                AdminAuth::logAction('article.update', 'article', (int) $id, ['title' => $title]);
                Cache::getInstance()->delete('article_' . (int) $id);
                Cache::getInstance()->delete('articles_list');
                $this->success(null);
            } else {
                $this->error('Article not found', 404);
            }
        }, 'update_article');
    }
}

new UpdateArticleApi();
