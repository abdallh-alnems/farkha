<?php

include "function.php";


$errorCode = isset($_GET['code']) ? (int)$_GET['code'] : 500;
$customMessage = isset($_GET['message']) ? $_GET['message'] : null;
$customDetails = isset($_GET['details']) ? json_decode($_GET['details'], true) : null;


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


$error = $errorMessages[$errorCode] ?? $errorMessages[500];


if ($customMessage) {
    $error['message'] = $customMessage;
}


http_response_code($errorCode);


header('Content-Type: application/json; charset=utf-8');


header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");


ApiLogger::error("HTTP Error {$errorCode}", [
    'error_title' => $error['title'],
    'error_message' => $error['message'],
    'request_uri' => $_SERVER['REQUEST_URI'] ?? 'unknown',
    'request_method' => $_SERVER['REQUEST_METHOD'] ?? 'unknown',
    'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown',
    'ip_address' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
]);


$response = [
    'status' => 'error',
    'message' => $error['message']
];


if (defined('DEBUG_MODE') && DEBUG_MODE) {
    $response['debug'] = [
        'request_uri' => $_SERVER['REQUEST_URI'] ?? 'unknown',
        'request_method' => $_SERVER['REQUEST_METHOD'] ?? 'unknown',
        'server_time' => date('Y-m-d H:i:s'),
        'php_version' => PHP_VERSION,
        'memory_usage' => memory_get_usage(true),
        'memory_peak' => memory_get_peak_usage(true)
    ];
}


echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);


if ($errorCode >= 500) {
    error_log("Farkha API Error {$errorCode}: " . json_encode($response));
}
?>
