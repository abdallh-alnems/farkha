<?php
require_once __DIR__ . '/../../core/connect.php';
include "../../core/queries/queries.php";

class AddArticleAPI extends BaseAPI {
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
            
            $title = $this->getTitle();
            $content = $this->getContent();
            
            if (!$this->validateRequiredField($title, 'Article title')) return;
            if (!$this->validateRequiredField($content, 'Article content')) return;
            if (!$this->validateTitleLength($title)) return;
            
            $this->addArticle($title, $content);
        });
    }
    
    private function addArticle($title, $content) {
        try {
            $query = Queries::insertArticleQuery();
            $params = [
                'title' => $title,
                'content' => $content
            ];
            
            $result = $this->db->execute($query, $params);
            
            if ($result === 0) {
                $this->handleError(500, 'Failed to add article');
                return;
            }
            
            $newArticleId = $this->db->getLastInsertId();
            
            if (!$newArticleId || $newArticleId <= 0) {
                $this->handleError(500, 'Failed to get new article ID');
                return;
            }
            
            $this->invalidateArticlesListCache();
            $this->sendSuccess(null);
        } catch (Exception $e) {
            throw $e;
        }
    }
    
    private function invalidateArticlesListCache() {
        try {
            $cacheKey = "articles_list";
            $cachedData = $this->cache->get($cacheKey);
            if ($cachedData !== null) {
                $this->cache->delete($cacheKey);
            }
        } catch (Exception $e) {
        }
    }
}

try {
    new AddArticleAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'add_article_api']);
}
