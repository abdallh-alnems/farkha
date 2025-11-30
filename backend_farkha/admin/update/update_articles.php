<?php
require_once __DIR__ . '/../../core/connect.php';
include "../../core/queries/queries.php";

class UpdateArticleAPI extends BaseAPI {
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
            
            $articleId = $this->getId();
            $title = $this->getTitle();
            $content = $this->getContent();
            
            // Validate inputs using common methods
            if (!$this->validateRequiredNumeric($articleId, 'article ID')) return;
            if (!$this->validateRequiredField($title, 'Article title')) return;
            if (!$this->validateRequiredField($content, 'Article content')) return;
            if (!$this->validateTitleLength($title)) return;
            
            // Single query to update article with validation
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
            
            // Invalidate cache for this article
            $this->invalidateArticleCache($articleId);
            
            // Invalidate articles list cache to show updated article
            $this->invalidateArticlesListCache();
            
            // Article updated successfully
            
            $this->sendSuccess(null);
            
        } catch (Exception $e) {
            throw $e;
        }
    }
    
    private function invalidateArticleCache($articleId) {
        try {
            $cacheKey = "article_detail_{$articleId}";
            
            // Delete only the specific article cache
            $deleted = $this->cache->delete($cacheKey);
            
            // Article cache invalidated successfully
            
        } catch (Exception $e) {
            // Cache invalidation failed
            // Don't throw here - cache invalidation failure shouldn't break the update
        }
    }
    
    private function invalidateArticlesListCache() {
        try {
            // Clear articles list cache since we updated an article
            $deleted = $this->cache->delete("articles_list");
            
            // Articles list cache invalidated successfully
            
        } catch (Exception $e) {
            // Cache invalidation failed
            // Don't throw here - cache invalidation failure shouldn't break the update
        }
    }
}

// Initialize the API
try {
    new UpdateArticleAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'update_article_api']);
}
?>
