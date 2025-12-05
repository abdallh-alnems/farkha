<?php

require_once __DIR__ . '/../../core/connect.php';
include __DIR__ . '/../../core/queries/queries.php';

class SuggestionsAPI extends BaseAPI {
    protected $requireAuth = false;

    public function __construct() {
        parent::__construct();
        $this->handleRequest();
    }

    private function handleRequest(): void {
        $this->handleApiRequest(function() {
            if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
                $this->handleError(405, 'Use POST to submit suggestions');
                return;
            }

            $suggestionText = $this->getSuggestionText();
            if (!$this->validateRequiredField($suggestionText, 'Suggestion text')) {
                return;
            }

            $this->storeSuggestion($suggestionText);
        }, 'suggestions_api');
    }

    private function getSuggestionText(): ?string {
        $value = RequestHelper::getField('suggestions_text', '');
        if ($value === null) {
            return null;
        }
        $trimmed = trim((string)$value);
        return $trimmed === '' ? null : $trimmed;
    }

    private function storeSuggestion(string $suggestionText): void {
        $query = Queries::insertSuggestionQuery();
        $result = $this->db->execute($query, ['suggestions_text' => $suggestionText]);

        if ($result === 0) {
            $this->handleError(500, 'Unable to store suggestion');
            return;
        }

        $this->sendSuccess(null);
    }
}

try {
    new SuggestionsAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'suggestions_api']);
}
?>

