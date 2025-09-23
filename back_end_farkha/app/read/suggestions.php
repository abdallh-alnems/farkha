<?php
/**
 * Professional Suggestions API
 * Enhanced with proper error handling, validation, and security
 */

include "../../connect.php";

class SuggestionsAPI extends BaseAPI {
    
    public function addSuggestion() {
        try {
            // Validate input
            $suggestion = filterRequest('suggestion');
            
            if (empty($suggestion)) {
                $this->handleError(400, 'Suggestion text is required');
                return;
            }
            
            // Sanitize input
            $suggestion = ApiValidator::sanitizeInput($suggestion);
            
            // Insert suggestion using centralized helper
            $query = "INSERT INTO `suggestion` (`suggestion_text`) VALUES (?)";
            $result = DatabaseHelper::executeInsert($query, [$suggestion]);
            
            if ($result['success']) {
                // Use legacy response format for backward compatibility
                LegacyApiResponse::send(true, null, 'Suggestion processed');
            } else {
                LegacyApiResponse::send(false, null, 'Failed to add suggestion');
            }
            
        } catch (Exception $e) {
            ApiLogger::error('Failed to add suggestion', [
                'error' => $e->getMessage()
            ]);
            handleApiError($e, ['context' => 'add_suggestion']);
        }
    }
}

// Initialize and execute
try {
    $api = new SuggestionsAPI();
    $api->addSuggestion();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'suggestions_api']);
}
?>