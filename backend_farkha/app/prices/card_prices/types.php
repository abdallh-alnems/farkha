<?php

require_once __DIR__ . '/../../../core/connect.php';
include "../../../core/queries/queries.php";

class TypesAPI extends BaseAPI {
    private $cache;
    
    public function __construct() {
        parent::__construct();
        $this->cache = CacheManager::getInstance();
        $this->handleRequest();           
    }
    
    private function handleRequest() {
        $this->handleApiRequest(function() {
            $this->getTypesList();
        }, 'types_api');
    }
    
    public function getTypesList() {
        $cacheKey = 'types_list';
        $cachedData = $this->cache->get($cacheKey);
        
        if ($cachedData !== null) {
            $this->sendSuccess($cachedData, 'cache');
            return;
        }
        
        $query = Queries::getTypesListQuery();
        $data = $this->db->fetchAll($query);
        
        if (empty($data)) {
            $this->handleError(404, 'No types found');
            return;
        }
        
        // Group data by main type
        $groupedData = [];
        foreach ($data as $item) {
            $mainType = $item['type_main_name'];
            if (!isset($groupedData[$mainType])) {
                $groupedData[$mainType] = [];
            }
            $groupedData[$mainType][] = [
                'id' => $item['id'],
                'name' => $item['name']
            ];
        }
        
        $this->cache->set($cacheKey, $groupedData);
        $this->sendSuccess($groupedData, 'database');
    }
    
}

// Initialize and execute
try {
    $api = new TypesAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'types_api']);
}
?>
