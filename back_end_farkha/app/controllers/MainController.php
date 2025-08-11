<?php

require_once __DIR__ . '/../models/MainRepository.php';
require_once __DIR__ . '/../utils/ResponseHandler.php';
require_once __DIR__ . '/../utils/Validator.php';

/**
 * Main Controller
 * Handles main category API endpoints
 */
class MainController
{
    private $mainRepository;

    public function __construct()
    {
        $this->mainRepository = new MainRepository();
    }

    /**
     * Get all main categories
     * GET /main
     */
    public function getAllMain()
    {
        try {
            $mainCategories = $this->mainRepository->findAll();
            
            if (!empty($mainCategories)) {
                ResponseHandler::success($mainCategories, 'Main categories retrieved successfully');
            } else {
                ResponseHandler::notFound('No main categories found');
            }

        } catch (Exception $e) {
            error_log("Error getting main categories: " . $e->getMessage());
            ResponseHandler::serverError('Failed to get main categories');
        }
    }

    /**
     * Get main categories with their types
     * GET /main/with-types
     */
    public function getMainWithTypes()
    {
        try {
            $mainWithTypes = $this->mainRepository->getMainWithTypes();
            
            if (!empty($mainWithTypes)) {
                // Group by main category
                $grouped = [];
                foreach ($mainWithTypes as $item) {
                    $mainId = $item['main_id'];
                    if (!isset($grouped[$mainId])) {
                        $grouped[$mainId] = [
                            'main_id' => $item['main_id'],
                            'main_name' => $item['main_name'],
                            'types' => []
                        ];
                    }
                    
                    if ($item['type_id']) {
                        $grouped[$mainId]['types'][] = [
                            'type_id' => $item['type_id'],
                            'type_name' => $item['type_name']
                        ];
                    }
                }
                
                ResponseHandler::success(array_values($grouped), 'Main categories with types retrieved successfully');
            } else {
                ResponseHandler::notFound('No main categories found');
            }

        } catch (Exception $e) {
            error_log("Error getting main with types: " . $e->getMessage());
            ResponseHandler::serverError('Failed to get main categories with types');
        }
    }

    /**
     * Get specific main category by ID
     * GET /main/{id}
     */
    public function getMainById($id)
    {
        try {
            // Validate ID
            if (!is_numeric($id) || $id <= 0) {
                ResponseHandler::error('Valid main ID is required');
                return;
            }

            $mainCategory = $this->mainRepository->findById($id);
            
            if ($mainCategory) {
                ResponseHandler::success($mainCategory, 'Main category retrieved successfully');
            } else {
                ResponseHandler::notFound('Main category not found');
            }

        } catch (Exception $e) {
            error_log("Error getting main by ID: " . $e->getMessage());
            ResponseHandler::serverError('Failed to get main category');
        }
    }

    /**
     * Get main category with types by ID
     * GET /main/{id}/with-types
     */
    public function getMainByIdWithTypes($id)
    {
        try {
            // Validate ID
            if (!is_numeric($id) || $id <= 0) {
                ResponseHandler::error('Valid main ID is required');
                return;
            }

            $mainWithTypes = $this->mainRepository->getMainByIdWithTypes($id);
            
            if (!empty($mainWithTypes)) {
                // Structure the response
                $result = [
                    'main_id' => $mainWithTypes[0]['main_id'],
                    'main_name' => $mainWithTypes[0]['main_name'],
                    'types' => []
                ];
                
                foreach ($mainWithTypes as $item) {
                    if ($item['type_id']) {
                        $result['types'][] = [
                            'type_id' => $item['type_id'],
                            'type_name' => $item['type_name']
                        ];
                    }
                }
                
                ResponseHandler::success($result, 'Main category with types retrieved successfully');
            } else {
                ResponseHandler::notFound('Main category not found');
            }

        } catch (Exception $e) {
            error_log("Error getting main by ID with types: " . $e->getMessage());
            ResponseHandler::serverError('Failed to get main category with types');
        }
    }

    /**
     * Get main categories statistics
     * GET /main/stats
     */
    public function getMainStats()
    {
        try {
            $stats = $this->mainRepository->getMainStats();
            
            if (!empty($stats)) {
                ResponseHandler::success($stats, 'Main categories statistics retrieved successfully');
            } else {
                ResponseHandler::notFound('No statistics found');
            }

        } catch (Exception $e) {
            error_log("Error getting main stats: " . $e->getMessage());
            ResponseHandler::serverError('Failed to get main categories statistics');
        }
    }
}
