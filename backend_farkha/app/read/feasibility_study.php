
<?php
/**
 * Professional Feasibility Study API
 * Enhanced with proper error handling, validation, and security
 */

require_once __DIR__ . '/../../core/connect.php';
include "../../core/queries/queries.php";

class FeasibilityStudyAPI extends BaseAPI {
    
    public function __construct() {
        parent::__construct();
        $this->handleRequest();
    }
    
    private function handleRequest() {
        $this->handleApiRequest(function() {
            $this->getFeasibilityStudy();
        }, 'feasibility_study_api');
    }
    
    public function getFeasibilityStudy() {
        // Fixed query with predefined types: 1,18,41,42,43
        $query = Queries::getFeasibilityStudyPrices();
        
        $data = $this->db->fetchAll($query);
        
        if (empty($data)) {
            $this->handleError(404, 'No feasibility study data found');
            return;
        }
        
        $this->sendSuccess($data);
    }
}

// Initialize and execute
try {
    new FeasibilityStudyAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'feasibility_study_api']);
}
?>