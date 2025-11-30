<?php
require_once __DIR__ . '/env.php';
require_once __DIR__ . '/http/responses.php';

// Error message constants
class ErrorMessages {
    const METHOD_NOT_ALLOWED = 'Method not allowed. Use POST or GET.';
    const INTERNAL_SERVER_ERROR = 'Internal server error';
    const FIELD_REQUIRED = 'is required';
    const VALID_FIELD_REQUIRED = 'Valid %s is required';
    const NOT_FOUND = 'not found';
    const NO_DATA_FOUND = 'No data found';
    const AUTHENTICATION_REQUIRED = 'Authentication required';
    const INVALID_CREDENTIALS = 'Invalid credentials';
    const RATE_LIMIT_EXCEEDED = 'Rate limit exceeded';
    const TITLE_TOO_LONG = 'Title is too long (maximum 255 characters)';
    const LOWER_PRICE_INVALID = 'Lower price must be a valid number';
}

class ResponseHelper {
    /**
     * Send error response with redirect to error API/JSON
     */
    public static function error($code, $message) {
        header("Location: /core/error.php?code={$code}&message=" . urlencode($message));
        exit;
    }
    /**
     * Send error response with JSON (for direct API responses)
     */
    public static function errorJson($code, $message) {
        http_response_code($code);
        echo json_encode([
            'status' => 'error',
            'code' => $code,
            'message' => $message
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
}

// Error handling functions
function handleApiError($e, $context = []) {
    ResponseHelper::error(500, 'Internal server error');
}

function redirectToError($code, $message) {
    ResponseHelper::error($code, $message);
}

// Get error parameters
$errorCode = isset($_GET['code']) ? (int)$_GET['code'] : 500;
$customMessage = isset($_GET['message']) ? $_GET['message'] : null;
$customDetails = isset($_GET['details']) ? json_decode($_GET['details'], true) : null;

// Error messages mapping
$errorMessages = [
    400 => [
        'title' => 'Bad Request',
        'message' => 'The request was invalid or cannot be served.'
    ],
    401 => [
        'title' => 'Unauthorized',
        'message' => 'Authentication is required to access this resource.'
    ],
    403 => [
        'title' => 'Forbidden',
        'message' => 'Access to this resource is forbidden.'
    ],
    404 => [
        'title' => 'Not Found',
        'message' => 'The requested resource was not found.'
    ],
    405 => [
        'title' => 'Method Not Allowed',
        'message' => 'The request method is not allowed for this resource.'
    ],
    429 => [
        'title' => 'Too Many Requests',
        'message' => 'Rate limit exceeded.'
    ],
    500 => [
        'title' => 'Internal Server Error',
        'message' => 'An internal server error occurred.'
    ],
    503 => [
        'title' => 'Service Unavailable',
        'message' => 'The service is temporarily unavailable.'
    ]
];

// Get error details
$error = $errorMessages[$errorCode] ?? $errorMessages[500];

// Override with custom message if provided
if ($customMessage) {
    $error['message'] = $customMessage;
}

// Set HTTP response code
http_response_code($errorCode);

// Set headers
header('Content-Type: application/json; charset=utf-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

// Error logged to PHP error log
if ($errorCode >= 500) {
    error_log("Farkha API Error {$errorCode}: " . json_encode([
        'error_title' => $error['title'],
        'error_message' => $error['message'],
        'request_uri' => $_SERVER['REQUEST_URI'] ?? 'unknown',
        'request_method' => $_SERVER['REQUEST_METHOD'] ?? 'unknown',
        'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown',
        'ip_address' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
    ]));
}

// Build response
$response = [
    'status' => 'error',
    'code' => $errorCode,
    'message' => $error['message'],
    'timestamp' => date('Y-m-d H:i:s'),
    'version' => API_VERSION
];


// Add custom details if provided
if ($customDetails) {
    $response['details'] = $customDetails;
}

// Output response
echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);

?>