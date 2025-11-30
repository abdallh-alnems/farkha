<?php
include_once __DIR__ . "/http/responses.php";
include_once __DIR__ . "/http/request.php";
include_once __DIR__ . "/validation.php";
include_once __DIR__ . "/auth.php";

if (!class_exists('BaseAPI')) {
/**
 * Base API Class
 * 
 * All APIs that extend this class are automatically protected by authentication.
 * To disable authentication for a specific API, set $requireAuth = false in the child class:
 * 
 * class PublicAPI extends BaseAPI {
 *     protected $requireAuth = false;
 *     public function __construct() {
 *         parent::__construct();
 *     }
 * }
 */
abstract class BaseAPI {
    protected $db;
    /**
     * Set to false to disable authentication for this API endpoint
     * Default: true (authentication required)
     */
    protected $requireAuth = true;

    public function __construct() {
        $this->db = DatabaseConnection::getInstance();
        
        // Check authentication automatically (unless disabled)
        if ($this->requireAuth) {
            $this->checkAuthentication();
        }
        
        $this->checkRateLimit();
    }
    
    // Authentication check
    protected function checkAuthentication() {
        checkAuthenticate();
    }

    protected function checkRateLimit($limit = API_RATE_LIMIT, $window = 3600) {
        $identifier = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        if (!RateLimiter::checkLimit($identifier, $limit, $window)) {
            $this->handleError(429, 'Rate limit exceeded');
        }
    }

    protected function handleError($code, $message, $context = []) {
        ApiResponse::fail($message, $code);
    }

    protected function sendSuccess($data, $source = null) {
        ApiResponse::success($data, 200, $source);
    }

    // HTTP Method validation
    protected function validateHttpMethod() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST' && $_SERVER['REQUEST_METHOD'] !== 'GET') {
            $this->handleError(405, 'Method not allowed. Use POST or GET.');
            return false;
        }
        return true;
    }
    
    // Unified error handling for API requests
    protected function handleApiRequest($callback, $context = 'api') {
        try {
            return $callback();
        } catch (Exception $e) {
            handleApiError($e, ['context' => $context]);
        }
    }
    
    // Common validation methods with unified error messages
    protected function validateRequiredNumeric($value, $fieldName, $min = 1) {
        if (!ValidationHelper::validateNumeric($value, $min)) {
            $message = "Valid {$fieldName} is required";
            $this->handleError(400, $message);
            return false;
        }
        return true;
    }
    
    protected function validateRequiredField($value, $fieldName) {
        if (empty($value)) {
            $this->handleError(400, "{$fieldName} is required");
            return false;
        }
        return true;
    }
    
    // Specific validation methods
    protected function validateTitleLength($title, $maxLength = 255) {
        if (strlen($title) > $maxLength) {
            $this->handleError(400, 'Title is too long (maximum 255 characters)');
            return false;
        }
        return true;
    }
    
    protected function validateLowerPrice($lower) {
        if (!empty($lower) && !is_numeric($lower)) {
            $this->handleError(400, 'Lower price must be a valid number');
            return false;
        }
        return true;
    }
    
    protected function handleNotFound($itemName = 'Item') {
        $this->handleError(404, "{$itemName} not found");
    }
    
    protected function handleNoData($message = null) {
        $msg = $message ?: 'No data found';
        $this->handleError(404, $msg);
    }
    
    // Request helper methods for getting form data
    protected function getTitle() {
        return RequestHelper::getField('title');
    }
    
    protected function getContent() {
        return RequestHelper::getField('content');
    }
    
    protected function getType() {
        return RequestHelper::getField('type');
    }
    
    protected function getHigher() {
        return RequestHelper::getField('higher');
    }
    
    protected function getLower() {
        return RequestHelper::getField('lower');
    }
    
    protected function getId() {
        return RequestHelper::getField('id');
    }

    protected function getValidatedMainType(string $field = 'type'): ?int {
        return ValidationHelper::validateMainType(RequestHelper::getField($field));
    }

    protected function getSanitizedTypeIds(string $field = 'type_ids'): array {
        $rawValue = RequestHelper::getField($field, []);
        return ValidationHelper::sanitizeTypeIds($rawValue);
    }
}
}

?>
