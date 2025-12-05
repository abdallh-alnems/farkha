<?php
require_once __DIR__ . '/../../../core/connect.php';
include "../../../core/queries/queries.php";

class ArticleDetailAPI extends BaseAPI {
    private $cache;
    
    public function __construct() {
        parent::__construct();
        $this->cache = CacheManager::getInstance();
        $this->handleRequest();
    }
    
    private function handleRequest() {
        $this->handleApiRequest(function() {
            $articleId = RequestHelper::getField('id');
            
            // Validate article ID using common method
            if (!$this->validateRequiredNumeric($articleId, 'article ID')) return;
            
            $this->getArticleData($articleId);
        });
    }
    
    public function getArticleData($articleId) {
        try {
            $cacheKey = "article_detail_{$articleId}";
            $cachedData = $this->cache->get($cacheKey);
            
            if ($cachedData !== null) {
                $this->sendSuccess($cachedData, 'cache');
                return;
            }
            
            $query = Queries::getArticleDetailQuery();
            $params = ['id' => (int)$articleId];
            
            $result = $this->db->fetchOne($query, $params);
            
            if (!$result) {
                $this->handleNotFound('Article');
                return;
            }
            
            $articleData = [
                'content' => $result['content']
            ];
            
            $this->cache->set($cacheKey, $articleData); // 24 hours (default)
            
            $this->sendSuccess($articleData, 'database');
            
        } catch (Exception $e) {
            throw $e;
        }

    }
}

// Initialize the API
try {
    new ArticleDetailAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'article_detail_api']);
}
?>

