
<?php
/**
 * Professional Feasibility Study API
 * Enhanced with proper error handling, validation, and security
 */

include "../../connect.php";
include "../../queries.php";

class FeasibilityStudyAPI extends BaseAPI {
    
    public function __construct() {
        parent::__construct();
        
        // Authentication handled in connect.php
    }
    
    public function getFeasibilityStudy() {
        try {
            // Validate input parameters using centralized helpers
            $generalTypes = ApiValidationHelper::validateGeneralTypes($_GET['general_types'] ?? '1,18');
            $feedTypes = ApiValidationHelper::validateFeedTypes($_GET['feed_types'] ?? '50,51,52');
            
            $generalQuery = Queries::getFeasibilityStudyGeneralPrices($generalTypes);
            $feedQuery = Queries::getFeasibilityStudyFeedPrices($feedTypes);
            $query = $generalQuery . " UNION ALL " . $feedQuery;
            
            $data = $this->db->fetchAll($query);
            
            if (empty($data)) {
                $this->handleError(404, 'No feasibility study data found');
                return;
            }
            
            
            $this->sendSuccess($data);
            
        } catch (Exception $e) {
            ApiLogger::error('Failed to retrieve feasibility study', [
                'error' => $e->getMessage()
            ]);
            handleApiError($e, ['context' => 'feasibility_study']);
        }
    }
    
    // Validation methods removed - now using centralized ApiValidationHelper methods
}

// Initialize and execute
try {
    $api = new FeasibilityStudyAPI();
    $api->getFeasibilityStudy();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'feasibility_study_api']);
}
?>