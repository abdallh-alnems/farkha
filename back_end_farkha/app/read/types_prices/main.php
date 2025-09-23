<?php

include "../../../connect.php";
include "../../cache.php";
include "../../../queries.php";

class MainCategoriesAPI extends BaseAPI {
    private $cache;
    
    public function __construct() {
        parent::__construct();
        $this->cache = CacheManager::getInstance();             
    }
    
    public function getMainCategories() {
        try {
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
            
            $this->cache->set($cacheKey, $enhancedData, 86400); // 24 hours
            
            
            $this->sendSuccess($enhancedData, 'database');
            
        } catch (Exception $e) {
            ApiLogger::error('Failed to retrieve main categories', [
                'error' => $e->getMessage()
            ]);
            handleApiError($e, ['context' => 'main_categories']);
        }
    }
}

// Initialize and execute
try {
    $api = new MainCategoriesAPI();
    $api->getMainCategories();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'main_categories_api']);
}
?>
