<?php

include "../../connect.php";
include "../../queries.php";

class TodayPricesAPI extends BaseAPI {
    
    public function __construct() {
        parent::__construct();
    }
    
    public function getTodayPrices() {
        try {
            // Validate input parameters using centralized helper
            $type = ApiValidationHelper::validateMainType(filterRequest('type'));
            
            if (!$type) {
                $this->handleError(400, 'Main type is required');
                return;
            }
            
            $data = $this->fetchTodayPrices($type);
            
            if (empty($data)) {
                $this->handleError(404, 'No prices found for the specified main type');
                return;
            }
            
            $this->sendSuccess($data);
            
        } catch (Exception $e) {
            ApiLogger::error('Failed to retrieve today prices', [
                'error' => $e->getMessage()
            ]);
            handleApiError($e, ['context' => 'today_prices']);
        }
    }
    
    private function fetchTodayPrices($mainType) {
        $query = Queries::getTodayPricesQuery();
        return $this->db->fetchAll($query, [$mainType]);
    }
}

// Initialize and execute
try {
    $api = new TodayPricesAPI();
    $api->getTodayPrices();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'today_prices_api']);
}
?>
