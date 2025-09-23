<?php

include "config.php";

class ApiResponse {
    public static function success($data = null, $code = 200, $source = null) {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');

        $response = [
            'status' => 'success'
        ];

        // Add data source information
        if ($source !== null) {
            $response['data_source'] = $source;
        }

        if ($data !== null) {
            $response['data'] = $data;
        }

        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        exit;
    }

    public static function error($message = 'Error', $code = 400, $details = null) {
        // Redirect to error.php for consistent error handling
        $errorUrl = "error.php?code=" . $code;
        if ($details) {
            $errorUrl .= "&details=" . urlencode(json_encode($details));
        }
        if ($message !== 'Error') {
            $errorUrl .= "&message=" . urlencode($message);
        }

        header("Location: " . $errorUrl);
        exit;
    }

    public static function fail($message = 'Failed', $code = 400) {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');

        $response = [
            'status' => 'fail',
            'code' => $code,
            'message' => $message,
            'timestamp' => date('Y-m-d H:i:s'),
            'version' => API_VERSION
        ];

        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        exit;
    }
}

class ApiValidator {
    public static function sanitizeInput($input) {
        if (is_array($input)) {
            return array_map([self::class, 'sanitizeInput'], $input);
        }
        return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
    }
}

class ApiLogger {
    public static function log($level, $message, $context = []) {
        // Only log errors, ignore other levels
        if ($level !== 'ERROR') {
            return;
        }

        // Use PHP's built-in error_log for errors only
        $logEntry = [
            'level' => $level,
            'message' => $message,
            'context' => $context,
            'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown'
        ];

        // Log only errors to PHP error log
        error_log("Farkha API [{$level}]: " . json_encode($logEntry, JSON_UNESCAPED_UNICODE));
    }

    public static function info($message, $context = []) {
        // Info messages are ignored - no logging
        return;
    }

    public static function error($message, $context = []) {
        self::log('ERROR', $message, $context);
    }

    public static function warning($message, $context = []) {
        // Warning messages are ignored - no logging
        return;
    }
}

class RateLimiter {
    private static $cache = [];

    public static function checkLimit($identifier, $limit = API_RATE_LIMIT, $window = 3600) {
        $key = "rate_limit_{$identifier}";
        $now = time();

        if (!isset(self::$cache[$key])) {
            self::$cache[$key] = [];
        }

        // Clean old entries
        self::$cache[$key] = array_filter(self::$cache[$key], function($timestamp) use ($now, $window) {
            return ($now - $timestamp) < $window;
        });

        if (count(self::$cache[$key]) >= $limit) {
            return false;
        }

        self::$cache[$key][] = $now;
        return true;
    }
}

// Legacy function with typo fix
function filterRequest($key, $default = null) {
    $value = $_POST[$key] ?? $_GET[$key] ?? $default;
    return ApiValidator::sanitizeInput($value);
}

function setCorsHeaders() {
    header("Access-Control-Allow-Origin: " . CORS_ALLOWED_ORIGINS);
    header("Access-Control-Allow-Headers: " . CORS_ALLOWED_HEADERS);
    header("Access-Control-Allow-Methods: " . CORS_ALLOWED_METHODS);

    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }
}

function handleApiError($e, $context = []) {
    ApiLogger::error('API Error: ' . $e->getMessage(), array_merge($context, [
        'file' => $e->getFile(),
        'line' => $e->getLine(),
        'trace' => $e->getTraceAsString()
    ]));

    ApiResponse::error('Internal server error', 500);
}

function checkAuthenticate() {
    if (!isset($_SERVER['PHP_AUTH_USER']) || !isset($_SERVER['PHP_AUTH_PW'])) {
        ApiLogger::warning('Authentication required', [
            'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
        ]);
        header('WWW-Authenticate: Basic realm="Farkha API"');
        ApiResponse::error('Authentication required', 401);
    }

    if ($_SERVER['PHP_AUTH_USER'] !== PHP_USER || $_SERVER['PHP_AUTH_PW'] !== PHP_PASS) {
        ApiLogger::warning('Failed authentication attempt', [
            'user' => $_SERVER['PHP_AUTH_USER'],
            'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
        ]);
        header('WWW-Authenticate: Basic realm="Farkha API"');
        ApiResponse::error('Invalid credentials', 401);
    }

    ApiLogger::info('Authentication successful', [
        'user' => $_SERVER['PHP_AUTH_USER'],
        'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
    ]);
}



class DatabaseHelper {

    public static function executeQuery($query, $params = [], $errorContext = 'database_operation') {
        try {
            $db = DatabaseConnection::getInstance();
            $stmt = $db->query($query, $params);
            $data = $stmt->fetchAll();
            $count = $stmt->rowCount();

            if ($count > 0) {
                return [
                    'success' => true,
                    'data' => $data,
                    'count' => $count
                ];
            } else {
                return [
                    'success' => false,
                    'data' => [],
                    'count' => 0
                ];
            }
        } catch (Exception $e) {
            ApiLogger::error('Database query failed', [
                'query' => $query,
                'params' => $params,
                'error' => $e->getMessage()
            ]);
            throw $e;
        }
    }

    
    public static function executeInsert($query, $params = []) {
        try {
            $db = DatabaseConnection::getInstance();
            $stmt = $db->query($query, $params);
            $count = $stmt->rowCount();

            return [
                'success' => $count > 0,
                'affected_rows' => $count
            ];
        } catch (Exception $e) {
            ApiLogger::error('Database insert failed', [
                'query' => $query,
                'params' => $params,
                'error' => $e->getMessage()
            ]);
            throw $e;
        }
    }
}


class ApiValidationHelper {

    public static function validateMainType($type) {
        if (empty($type)) return null;

        $type = (int) $type;
        if ($type <= 0) return null;

        return $type;
    }

 
    public static function validateGeneralTypes($input) {
        if (empty($input)) return '1,18';

        $types = is_array($input) ? $input : explode(',', $input);
        $validTypes = array_filter(array_map('intval', $types), function($type) {
            return $type > 0;
        });

        return implode(',', array_unique($validTypes)) ?: '1,18';
    }

 
    public static function validateFeedTypes($input) {
        if (empty($input)) return '50,51,52';

        $types = is_array($input) ? $input : explode(',', $input);
        $validTypes = array_filter(array_map('intval', $types), function($type) {
            return $type > 0;
        });

        return implode(',', array_unique($validTypes)) ?: '50,51,52';
    }

    public static function sanitizeTypeIds($input) {
        if (empty($input)) return [];

        $type_ids = is_array($input) ? $input : explode(',', $input);
        $sanitized = array_unique(array_filter(array_map('trim', $type_ids), function($id) {
            return is_numeric($id) && $id > 0;
        }));

        // Limit to maximum 50 types for performance
        return array_slice($sanitized, 0, 50);
    }
}



abstract class BaseAPI {
    protected $db;

    public function __construct() {
        $this->db = DatabaseConnection::getInstance();
        $this->checkRateLimit();

        ApiLogger::info(static::class . ' accessed', [
            'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
        ]);
    }

   
    protected function checkRateLimit($limit = API_RATE_LIMIT, $window = 3600) {
        $identifier = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        if (!RateLimiter::checkLimit($identifier, $limit, $window)) {
            ApiLogger::warning('Rate limit exceeded for ' . static::class, [
                'ip' => $identifier
            ]);
            header("Location: error.php?code=429&message=" . urlencode('Rate limit exceeded'));
            exit;
        }
    }

   
    protected function handleError($code, $message, $context = []) {
        header("Location: error.php?code={$code}&message=" . urlencode($message));
        exit;
    }

    protected function sendSuccess($data, $source = null) {
        ApiResponse::success($data, 200, $source);
    }
}


class LegacyApiResponse {
    public static function send($success, $data = null, $message = null) {
        header('Content-Type: application/json; charset=utf-8');
        
        $response = ['status' => $success ? 'success' : 'fail'];
        
        if ($data !== null) {
            $response['data'] = $data;
        }
        
        if ($message !== null) {
            $response['message'] = $message;
        }
        
        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        exit;

    }
}

?>