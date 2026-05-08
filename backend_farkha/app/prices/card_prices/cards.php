<?php

require_once __DIR__ . '/../../../core/connect.php';
include "../../../core/queries/queries.php";

class PricesAPI extends BaseAPI {
    
    public function __construct() {
        parent::__construct();
        $this->handleRequest();
    }
    
    private function handleRequest() {
        $this->handleApiRequest(function() {
            $this->getPrices();
        }, 'prices_api');
    }
    
    private function fetchPriceData($typeIds) {
        try {
            $query = Queries::getPricesStreamWithTypeFilterQuery($typeIds);
            $result = $this->db->fetchAll($query, $typeIds);
            return $result;
        } catch (Exception $e) {
            return false;
        }
    }
    
    public function getPrices() {
        $typeIds = $this->getSanitizedTypeIds();
        
        // Validate type_ids
        if (empty($typeIds)) {
            $this->handleError(400, 'يجب تحديد أنواع الأسعار المطلوبة');
            return;
        }
        
        // Fetch data
        $data = $this->fetchPriceData($typeIds);
        
        if ($data === false) {
            $this->handleError(500, 'خطأ في جلب البيانات');
            return;
        }
        
        if (empty($data)) {
            $this->handleError(404, 'لا توجد بيانات متاحة');
            return;
        }
        
        // Send success response
        $this->sendSuccess($data);
    }
}

// Initialize the API
try {
    new PricesAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'prices_api']);
}
?>
