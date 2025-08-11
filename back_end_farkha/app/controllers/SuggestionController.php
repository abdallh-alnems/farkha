<?php

require_once __DIR__ . '/../models/SuggestionRepository.php';
require_once __DIR__ . '/../utils/ResponseHandler.php';
require_once __DIR__ . '/../utils/Validator.php';

/**
 * Suggestion Controller
 * Handles suggestion-related API endpoints
 */
class SuggestionController
{
    private $suggestionRepository;

    public function __construct()
    {
        $this->suggestionRepository = new SuggestionRepository();
    }

    /**
     * Add new suggestion
     * POST /suggestions/add
     */
    public function addSuggestion()
    {
        try {
            // Get and validate input
            $data = Validator::filterRequest(['suggestion']);
            
            $validator = new Validator($data);
            $validator->required('suggestion', 'Suggestion text is required')
                     ->minLength('suggestion', 10, 'Suggestion must be at least 10 characters')
                     ->maxLength('suggestion', 1000, 'Suggestion must not exceed 1000 characters');

            if ($validator->fails()) {
                ResponseHandler::validationError($validator->getErrors());
                return;
            }

            // Add suggestion
            $suggestionId = $this->suggestionRepository->addSuggestion($data['suggestion']);
            
            if ($suggestionId) {
                ResponseHandler::success(
                    ['suggestion_id' => $suggestionId], 
                    'Suggestion added successfully', 
                    201
                );
            } else {
                ResponseHandler::error('Failed to add suggestion');
            }

        } catch (Exception $e) {
            error_log("Error adding suggestion: " . $e->getMessage());
            ResponseHandler::serverError('Failed to add suggestion');
        }
    }

    /**
     * Get recent suggestions
     * GET /suggestions/recent?limit=10
     */
    public function getRecentSuggestions()
    {
        try {
            $limit = $_GET['limit'] ?? 10;
            
            // Validate limit
            if (!is_numeric($limit) || $limit <= 0 || $limit > 100) {
                $limit = 10;
            }

            $suggestions = $this->suggestionRepository->getRecentSuggestions($limit);
            
            if (!empty($suggestions)) {
                ResponseHandler::success($suggestions, 'Recent suggestions retrieved successfully');
            } else {
                ResponseHandler::notFound('No suggestions found');
            }

        } catch (Exception $e) {
            error_log("Error getting recent suggestions: " . $e->getMessage());
            ResponseHandler::serverError('Failed to get recent suggestions');
        }
    }

    /**
     * Search suggestions
     * GET /suggestions/search?q=keyword
     */
    public function searchSuggestions()
    {
        try {
            $keyword = $_GET['q'] ?? '';
            
            if (empty(trim($keyword))) {
                ResponseHandler::error('Search keyword is required');
                return;
            }

            if (strlen(trim($keyword)) < 3) {
                ResponseHandler::error('Search keyword must be at least 3 characters');
                return;
            }

            $suggestions = $this->suggestionRepository->searchSuggestions(trim($keyword));
            
            if (!empty($suggestions)) {
                ResponseHandler::success($suggestions, 'Search results retrieved successfully');
            } else {
                ResponseHandler::notFound('No suggestions found matching your search');
            }

        } catch (Exception $e) {
            error_log("Error searching suggestions: " . $e->getMessage());
            ResponseHandler::serverError('Failed to search suggestions');
        }
    }

    /**
     * Get suggestions by date range
     * GET /suggestions/by-date?start=2024-01-01&end=2024-01-31
     */
    public function getSuggestionsByDate()
    {
        try {
            $startDate = $_GET['start'] ?? '';
            $endDate = $_GET['end'] ?? '';
            
            // Validate dates
            if (empty($startDate) || empty($endDate)) {
                ResponseHandler::error('Start date and end date are required');
                return;
            }

            if (!$this->isValidDate($startDate) || !$this->isValidDate($endDate)) {
                ResponseHandler::error('Invalid date format. Use YYYY-MM-DD');
                return;
            }

            if (strtotime($startDate) > strtotime($endDate)) {
                ResponseHandler::error('Start date cannot be after end date');
                return;
            }

            $suggestions = $this->suggestionRepository->getSuggestionsByDateRange($startDate, $endDate);
            
            if (!empty($suggestions)) {
                ResponseHandler::success($suggestions, 'Suggestions retrieved successfully');
            } else {
                ResponseHandler::notFound('No suggestions found in the specified date range');
            }

        } catch (Exception $e) {
            error_log("Error getting suggestions by date: " . $e->getMessage());
            ResponseHandler::serverError('Failed to get suggestions by date');
        }
    }

    /**
     * Get suggestion statistics
     * GET /suggestions/stats
     */
    public function getSuggestionStats()
    {
        try {
            $stats = $this->suggestionRepository->getSuggestionStats();
            
            if ($stats) {
                ResponseHandler::success($stats, 'Suggestion statistics retrieved successfully');
            } else {
                ResponseHandler::notFound('No suggestion statistics found');
            }

        } catch (Exception $e) {
            error_log("Error getting suggestion stats: " . $e->getMessage());
            ResponseHandler::serverError('Failed to get suggestion statistics');
        }
    }

    /**
     * Validate date format
     */
    private function isValidDate($date)
    {
        $d = DateTime::createFromFormat('Y-m-d', $date);
        return $d && $d->format('Y-m-d') === $date;
    }
}
