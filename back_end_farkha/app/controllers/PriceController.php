<?php

require_once __DIR__ . '/../models/PriceRepository.php';
require_once __DIR__ . '/../utils/ResponseHandler.php';
require_once __DIR__ . '/../utils/Validator.php';

/**
 * Price Controller
 * Handles price-related API endpoints
 */
class PriceController
{
    private $priceRepository;

    public function __construct()
    {
        $this->priceRepository = new PriceRepository();
    }

    /**
     * Add new price
     * POST /prices/add
     */
    public function addPrice()
    {
        try {
            // Get and validate input
            $data = Validator::filterRequest(['price', 'type_id']);
            
            $validator = new Validator($data);
            $validator->required('price', 'Price is required')
                     ->numeric('price', 'Price must be numeric')
                     ->positive('price', 'Price must be positive')
                     ->required('type_id', 'Type ID is required')
                     ->integer('type_id', 'Type ID must be an integer')
                     ->positive('type_id', 'Type ID must be positive');

            if ($validator->fails()) {
                ResponseHandler::validationError($validator->getErrors());
                return;
            }

            // Add price
            $priceId = $this->priceRepository->addPrice($data['price'], $data['type_id']);
            
            if ($priceId) {
                ResponseHandler::success(['price_id' => $priceId], 'Price added successfully', 201);
            } else {
                ResponseHandler::error('Failed to add price');
            }

        } catch (Exception $e) {
            error_log("Error adding price: " . $e->getMessage());
            ResponseHandler::serverError('Failed to add price');
        }
    }

    /**
     * Get latest prices by type
     * GET /prices/latest?type=1
     */
    public function getLatestPrices()
    {
        try {
            $typeId = $_GET['type'] ?? null;
            
            if (!$typeId || !is_numeric($typeId)) {
                ResponseHandler::error('Valid type ID is required');
                return;
            }

            $prices = $this->priceRepository->getLatestPricesByType($typeId, 2);
            
            if (!empty($prices)) {
                ResponseHandler::success($prices, 'Latest prices retrieved successfully');
            } else {
                ResponseHandler::notFound('No prices found for this type');
            }

        } catch (Exception $e) {
            error_log("Error getting latest prices: " . $e->getMessage());
            ResponseHandler::serverError('Failed to get latest prices');
        }
    }

    /**
     * Get feasibility study data
     * GET /prices/feasibility-study
     */
    public function getFeasibilityStudy()
    {
        try {
            $prices = $this->priceRepository->getFeasibilityStudyData();
            
            if (!empty($prices)) {
                ResponseHandler::success($prices, 'Feasibility study data retrieved successfully');
            } else {
                ResponseHandler::notFound('No feasibility study data found');
            }

        } catch (Exception $e) {
            error_log("Error getting feasibility study: " . $e->getMessage());
            ResponseHandler::serverError('Failed to get feasibility study data');
        }
    }

    /**
     * Get prices with types for specific main category
     * POST /prices/by-type
     */
    public function getPricesByType()
    {
        try {
            $data = Validator::filterRequest(['type']);
            
            $validator = new Validator($data);
            $validator->required('type', 'Type is required')
                     ->integer('type', 'Type must be an integer')
                     ->positive('type', 'Type must be positive');

            if ($validator->fails()) {
                ResponseHandler::validationError($validator->getErrors());
                return;
            }

            $prices = $this->priceRepository->getPricesWithTypes($data['type']);
            
            if (!empty($prices)) {
                ResponseHandler::success($prices, 'Prices retrieved successfully');
            } else {
                ResponseHandler::notFound('No prices found for this type');
            }

        } catch (Exception $e) {
            error_log("Error getting prices by type: " . $e->getMessage());
            ResponseHandler::serverError('Failed to get prices by type');
        }
    }

    /**
     * Get web prices
     * GET /prices/web
     */
    public function getWebPrices()
    {
        try {
            $prices = $this->priceRepository->getWebPrices();
            
            if (!empty($prices)) {
                ResponseHandler::success($prices, 'Web prices retrieved successfully');
            } else {
                ResponseHandler::notFound('No web prices found');
            }

        } catch (Exception $e) {
            error_log("Error getting web prices: " . $e->getMessage());
            ResponseHandler::serverError('Failed to get web prices');
        }
    }

    /**
     * Get price statistics
     * GET /prices/stats?type=1&days=30
     */
    public function getPriceStats()
    {
        try {
            $typeId = $_GET['type'] ?? null;
            $days = $_GET['days'] ?? 30;
            
            if (!$typeId || !is_numeric($typeId)) {
                ResponseHandler::error('Valid type ID is required');
                return;
            }

            if (!is_numeric($days) || $days <= 0) {
                $days = 30;
            }

            $stats = $this->priceRepository->getPriceStatistics($typeId, $days);
            
            if ($stats) {
                ResponseHandler::success($stats, 'Price statistics retrieved successfully');
            } else {
                ResponseHandler::notFound('No price statistics found');
            }

        } catch (Exception $e) {
            error_log("Error getting price stats: " . $e->getMessage());
            ResponseHandler::serverError('Failed to get price statistics');
        }
    }
}
