<?php

include "../../../connect.php";
include "../../../queries.php";

class TypesPricesAPI extends BaseAPI {
    
    public function __construct() {
        parent::__construct();
        
    }
    
    public function getTypesPrices() {
        try {
            // Validate input parameters using centralized helper
            $type = ApiValidationHelper::validateMainType(filterRequest('type'));
            
            if (!$type) {
                $this->handleError(400, 'Main type is required');
                return;
            }
            
            $data = $this->fetchTypesPrices($type);
            
            if (empty($data)) {
                $this->handleError(404, 'No types prices found for the specified main type');
                return;
            }
            
            
            $this->sendSuccess($data);
            
        } catch (Exception $e) {
            ApiLogger::error('Failed to retrieve types prices', [
                'error' => $e->getMessage()
            ]);
            handleApiError($e, ['context' => 'types_prices']);
        }
    }
    
    // Validation method removed - now using centralized ApiValidationHelper::validateMainType()
    
    private function fetchTypesPrices($mainType) {
            $query = Queries::getPricesByTypeQuery();
        
        return $this->db->fetchAll($query, [$mainType]);
    }
    
}

// Initialize and execute
try {
    $api = new TypesPricesAPI();
    $api->getTypesPrices();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'types_prices_api']);
}
?>
