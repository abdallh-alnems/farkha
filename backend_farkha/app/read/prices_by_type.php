<?php

require_once __DIR__ . '/../../core/connect.php';
include "../../core/queries/queries.php";

class TypesPricesAPI extends BaseAPI {
    
    public function __construct() {
        parent::__construct();
        $this->handleRequest();
    }
    
    private function handleRequest() {
        $this->handleApiRequest(function() {
            $this->getTypesPrices();
        }, 'types_prices_api');
    }
    
    public function getTypesPrices() {
        // Validate input parameters using centralized helper
        $type = $this->getValidatedMainType();
        
        if (!$type) {
            $this->handleError(400, 'Main type is required');
            return;
        }
        
        $data = $this->fetchTypesPrices($type);
        
        if (empty($data)) {
            $this->handleNoData('No types prices found for the specified main type');
            return;
        }
        
        $this->sendSuccess($data);
    }
    
    private function fetchTypesPrices($mainType) {
        $query = Queries::getPricesByTypeQuery();
        return $this->db->fetchAll($query, [$mainType]);
    }
}

// Initialize and execute
try {
    new TypesPricesAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'types_prices_api']);
}
?>

