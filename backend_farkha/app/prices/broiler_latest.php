<?php
/**
 * Broiler Chicken Price API
 * Fetches the latest price for broiler chicken (type id = 1)
 */

require_once __DIR__ . '/../../../core/connect.php';
include __DIR__ . '/../../../core/queries/queries.php';

class BroilerChickenPriceAPI extends BaseAPI {
    
    public function __construct() {
        parent::__construct();
        $this->handleRequest();
    }
    
    private function handleRequest() {
        $this->handleApiRequest(function() {
            $this->getBroilerChickenPrice();
        }, 'broiler_chicken_price_api');
    }
    
    public function getBroilerChickenPrice() {
        $query = Queries::getCyclePrice();
        
        $data = $this->db->fetchAll($query);
        
        if (empty($data)) {
            $this->handleError(404, 'No broiler chicken price data found');
            return;
        }
        
        // Return only the price
        $this->sendSuccess(['price' => $data[0]['price']]);
    }
}

// Initialize and execute
try {
    new BroilerChickenPriceAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'broiler_chicken_price_api']);
}
?>

