<?php

require_once __DIR__ . '/../../core/connect.php';
include "../../core/queries/queries.php";

class TodayPricesAPI extends BaseAPI {
    
    public function __construct() {
        parent::__construct();
        $this->handleRequest();
    }
    
    private function handleRequest() {
        $this->handleApiRequest(function() {
            $this->getTodayPrices();
        }, 'today_prices_api');
    }
    
    public function getTodayPrices() {
        // Validate input parameters using centralized helper
        $type = $this->getValidatedMainType();
        
        if (!$type) {
            $this->handleError(400, 'Main type is required');
            return;
        }
        
        $data = $this->fetchTodayPrices($type);
        
        if (empty($data)) {
            $this->handleNoData('No prices found for the specified main type');
            return;
        }
        
        $this->sendSuccess($data);
    }
    
    private function fetchTodayPrices($mainType) {
        $query = Queries::getTodayPricesQuery();
        return $this->db->fetchAll($query, [$mainType]);
    }
}

// Initialize and execute
try {
    new TodayPricesAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'today_prices_api']);
}
?>
