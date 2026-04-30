<?php
require_once __DIR__ . '/../../core/connect.php';
include "../../core/queries/queries.php";

class UpdateArticleAPI extends BaseAPI {
    private $cache;

    protected function checkAuthentication() {
        checkAppCheckRequired();
    }

    public function __construct() {
        parent::__construct();
        $this->cache = CacheManager::getInstance();
        $this->handleRequest();
    }
    
    private function handleRequest() {
        $this->handleApiRequest(function() {
            if (!$this->validateHttpMethod()) return;
            
            $articleId = $this->getId();
            $title = $this->getTitle();
            $content = $this->getContent();
            
            if (!$this->validateRequiredNumeric($articleId, 'article ID')) return;
            if (!$this->validateRequiredField($title, 'Article title')) return;
            if (!$this->validateRequiredField($content, 'Article content')) return;
            if (!$this->validateTitleLength($title)) return;
            
            $this->updateArticleWithValidation($articleId, $title, $content);
        });
    }
    
    private function updateArticleWithValidation($articleId, $title, $content) {
        try {
            $query = Queries::updateArticleWithValidationQuery();
            $params = [
                'id' => (int)$articleId,
                'title' => $title,
                'content' => $content,
                'id2' => (int)$articleId
            ];
            
            $result = $this->db->execute($query, $params);
            
            if ($result === 0) {
                $this->handleNotFound('Article');
                return;
            }
            
            $this->invalidateArticleCache($articleId);
            $this->invalidateArticlesListCache();
            $this->sendSuccess(null);
        } catch (Exception $e) {
            throw $e;
        }
    }
    
    private function invalidateArticleCache($articleId) {
        try {
            $cacheKey = "article_detail_{$articleId}";
            $this->cache->delete($cacheKey);
        } catch (Exception $e) {
        }
    }
    
    private function invalidateArticlesListCache() {
        try {
            $this->cache->delete("articles_list");
        } catch (Exception $e) {
        }
    }
}

try {
    new UpdateArticleAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'update_article_api']);
}
