<?php
require_once __DIR__ . '/../../core/connect.php';
include "../../core/queries/queries.php";

class UpdatePriceAPI extends BaseAPI {
    
    public function __construct() {
        parent::__construct();
        $this->handleRequest();
    }
    
    private function handleRequest() {
        $this->handleApiRequest(function() {
            // Validate HTTP method
            if (!$this->validateHttpMethod()) return;
            
            $type = $this->getType();
            $higher = $this->getHigher();
            $lower = $this->getLower();
            
            // Validate inputs using common methods
            if (!$this->validateRequiredNumeric($type, 'type')) return;
            if (!$this->validateRequiredNumeric($higher, 'higher price')) return;
            if (!$this->validateLowerPrice($lower)) return;
            
            // Check if type exists
            if (!$this->typeExists($type)) {
                $this->handleNotFound('Type');
                return;
            }
            
            $this->updatePrice($higher, $lower, $type);
        });
    }
    
    private function typeExists($type) {
        try {
            $query = "SELECT id FROM types WHERE id = :type LIMIT 1";
            $params = ['type' => (int)$type];
            
            $result = $this->db->fetchOne($query, $params);
            
            return $result !== false;
            
        } catch (Exception $e) {
            throw $e;
        }
    }
    
    private function updatePrice($higher, $lower, $type) {
        try {
            $query = Queries::updatePriceQuery();
            $lowerValue = !empty($lower) ? $lower : null;
            
            $params = [
                'higher' => (float)$higher,
                'lower' => $lowerValue,
                'type' => (int)$type,
                'type2' => (int)$type
            ];
            
            $result = $this->db->execute($query, $params);
            
            if ($result === 0) {
                $this->handleNotFound('Price record');
                return;
            }
            
            // Price updated successfully
            
            $this->sendSuccess(null);
            
        } catch (Exception $e) {
            throw $e;
        }
    }
}

// Initialize the API
try {
    new UpdatePriceAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'update_price_api']);
}
?>
