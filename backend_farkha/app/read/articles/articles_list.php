<?php
require_once __DIR__ . '/../../../core/connect.php';
include "../../../core/queries/queries.php";

class ArticlesListAPI extends BaseAPI {
    private $cache;
    
    public function __construct() {
        parent::__construct();
        $this->cache = CacheManager::getInstance();
        $this->handleRequest();
    }
    
    private function handleRequest() {
        $this->handleApiRequest(function() {
            $this->getArticlesList();
        }, 'articles_list_api');
    }
    
    public function getArticlesList() {
        $cacheKey = 'articles_list';
        $cachedData = $this->cache->get($cacheKey);
        
        if ($cachedData !== null) {
            $this->sendSuccess($cachedData, 'cache');
            return;
        }
        
        $query = Queries::getArticlesListQuery();
        $data = $this->db->fetchAll($query);
        
        if (empty($data)) {
            $this->handleError(404, 'No articles found');
            return;
        }
        
        $this->cache->set($cacheKey, $data); // 24 hours (default)
        $this->sendSuccess($data, 'database');
    }
}

// Initialize and execute
try {
    new ArticlesListAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'articles_list_api']);
}
?>