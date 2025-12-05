<?php

require_once __DIR__ . '/core/connect.php';
include "core/queries/queries.php";

class MainCategoriesAPI extends BaseAPI {
    private $cache;
    
    public function __construct() {
        parent::__construct();
        $this->cache = CacheManager::getInstance();
        $this->handleRequest();
    }

    private function handleRequest() {
        $this->handleApiRequest(function() {
            $this->getMainCategories();
        }, 'main_categories');
    }
    
    public function getMainCategories() {
        $cacheKey = 'main_categories';
        $cachedData = $this->cache->get($cacheKey);
        if ($cachedData !== null) {
            $this->sendSuccess($cachedData, 'cache');
            return;
        }

        $query = Queries::getMainCategoriesQuery();
        $data = $this->db->fetchAll($query);
        if (empty($data)) {
            $this->handleError(404, 'No main categories found');
            return;
        }
        $enhancedData = $data;
        $this->cache->set($cacheKey, $enhancedData);
        $this->sendSuccess($enhancedData, 'database');
    }
}

try {
    $api = new MainCategoriesAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'main_categories_api']);
}
?>
