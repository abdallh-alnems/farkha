<?php

/**
 * Standardized Response Handler
 * Provides consistent API responses
 */
class ResponseHandler
{
    /**
     * Send success response
     */
    public static function success($data = null, $message = 'Success', $code = 200)
    {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');
        
        $response = [
            'status' => 'success',
            'message' => $message,
            'timestamp' => date('Y-m-d H:i:s')
        ];

        if ($data !== null) {
            $response['data'] = $data;
        }

        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        exit;
    }

    /**
     * Send error response
     */
    public static function error($message = 'Error occurred', $code = 400, $errors = null)
    {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');
        
        $response = [
            'status' => 'error',
            'message' => $message,
            'timestamp' => date('Y-m-d H:i:s')
        ];

        if ($errors !== null) {
            $response['errors'] = $errors;
        }

        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        exit;
    }

    /**
     * Send validation error response
     */
    public static function validationError($errors, $message = 'Validation failed')
    {
        self::error($message, 422, $errors);
    }

    /**
     * Send not found response
     */
    public static function notFound($message = 'Resource not found')
    {
        self::error($message, 404);
    }

    /**
     * Send server error response
     */
    public static function serverError($message = 'Internal server error')
    {
        self::error($message, 500);
    }

    /**
     * Send unauthorized response
     */
    public static function unauthorized($message = 'Unauthorized')
    {
        self::error($message, 401);
    }

    /**
     * Send forbidden response
     */
    public static function forbidden($message = 'Forbidden')
    {
        self::error($message, 403);
    }
}
