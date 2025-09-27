<?php

include "../../../connect.php";
include "../../../cache.php";
include "../../../queries.php";

class TypesAPI extends BaseAPI {
    private $cache;
    
    public function __construct() {
        parent::__construct();
        $this->cache = CacheManager::getInstance();             
    }
    
    public function getTypesList() {
        try {
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
            
            $this->cache->set($cacheKey, $groupedData, 86400); // 24 hours
            
            $this->sendSuccess($groupedData, 'database');
            
        } catch (Exception $e) {
            ApiLogger::error('Failed to retrieve types', [
                'error' => $e->getMessage()
            ]);
            handleApiError($e, ['context' => 'types']);
        }
    }
    
}

// Initialize and execute
try {
    $api = new TypesAPI();
    $api->getTypesList();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'types_api']);
}
?>
