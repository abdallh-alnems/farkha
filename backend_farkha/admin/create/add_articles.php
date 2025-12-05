<?php
require_once __DIR__ . '/../../core/connect.php';
include "../../core/queries/queries.php";

class AddArticleAPI extends BaseAPI {
    private $cache;
    
    public function __construct() {
        parent::__construct();
        $this->cache = CacheManager::getInstance();
        $this->handleRequest();
    }
    
    private function handleRequest() {
        $this->handleApiRequest(function() {
            // Validate HTTP method
            if (!$this->validateHttpMethod()) return;
            
            $title = $this->getTitle();
            $content = $this->getContent();
            
            // Validate inputs using common methods
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
            
            // Get the ID of the newly inserted article using PDO's lastInsertId
            $newArticleId = $this->db->getLastInsertId();
            
            // Check if we got a valid ID (should be > 0)
            if (!$newArticleId || $newArticleId <= 0) {
                $this->handleError(500, 'Failed to get new article ID');
                return;
            }
            
            // Clear articles list cache to show the new article
            $this->invalidateArticlesListCache();
            
            // Article added successfully
            
            $this->sendSuccess(null);
            
        } catch (Exception $e) {
            throw $e;
        }
    }
    
    
    private function invalidateArticlesListCache() {
        try {
            // Clear articles list cache since we added a new article
            $cacheKey = "articles_list";
            
            // Check if cache exists before trying to delete
            $cachedData = $this->cache->get($cacheKey);
            if ($cachedData !== null) {
                $deleted = $this->cache->delete($cacheKey);
                
                // Cache invalidated successfully
            } else {
                // Cache was already empty
            }
            
        } catch (Exception $e) {
            // Cache invalidation failed
            // Don't throw here - cache invalidation failure shouldn't break the addition
        }
    }
}

// Initialize the API
try {
    new AddArticleAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'add_article_api']);
}
?>