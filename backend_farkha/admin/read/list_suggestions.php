<?php

require_once __DIR__ . '/../../core/connect.php';
include "../../core/queries/queries.php";

class ListSuggestionsAPI extends BaseAPI {
    
    public function __construct() {
        parent::__construct();
        $this->handleRequest();
    }
    
    private function handleRequest() {
        $this->handleApiRequest(function() {
            $this->getSuggestionsList();
        }, 'list_suggestions_api');
    }
    
    public function getSuggestionsList() {
        $query = Queries::getSuggestionsListQuery();
        $data = $this->db->fetchAll($query);
        
        if (empty($data)) {
            $this->handleNoData('No suggestions found');
            return;
        }
        
        $this->sendSuccess($data);
    }
}

// Initialize and execute
try {
    new ListSuggestionsAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'list_suggestions_api']);
}
?>

