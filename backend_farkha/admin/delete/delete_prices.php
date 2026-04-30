<?php
require_once __DIR__ . '/../../core/connect.php';
include "../../core/queries/queries.php";

class DeletePriceAPI extends BaseAPI {

    protected function checkAuthentication() {
        checkAppCheckRequired();
    }
    
    public function __construct() {
        parent::__construct();
        $this->handleRequest();
    }
    
    private function handleRequest() {
        $this->handleApiRequest(function() {
            if (!$this->validateHttpMethod()) return;
            
            $type = $this->getType();
            
            if (!$this->validateRequiredNumeric($type, 'type')) return;
            
            $this->deletePriceWithValidation($type);
        });
    }
    
    private function deletePriceWithValidation($type) {
        try {
            $query = Queries::deletePriceWithValidationQuery();
            
            $params = [
                'type' => (int)$type,
                'type2' => (int)$type,
                'type3' => (int)$type
            ];
            
            $result = $this->db->execute($query, $params);
            
            if ($result === 0) {
                $this->handleNotFound('Price record');
                return;
            }
            
            $this->sendSuccess(null);
        } catch (Exception $e) {
            throw $e;
        }
    }
}

try {
    new DeletePriceAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'delete_price_api']);
}
