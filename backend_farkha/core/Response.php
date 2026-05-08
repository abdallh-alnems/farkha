<?php

final class Response {
    public static function success($data = null, int $code = 200, ?string $source = null): void {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');
        $response = ['status' => 'success'];
        if ($source !== null) {
            $response['data_source'] = $source;
        }
        if ($data !== null) {
            $response['data'] = $data;
        }
        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        exit;
    }

    public static function error(string $message, int $code = 400, ?array $details = null): void {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');
        $response = [
            'status' => 'error',
            'code' => $code,
            'message' => $message,
        ];
        if ($details !== null) {
            $response['details'] = $details;
        }
        error_log("API Error [{$code}]: {$message}");
        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        exit;
    }

    public static function fail(string $message, int $code = 400, ?string $errorCode = null): void {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');
        $response = [
            'status' => 'fail',
            'code' => $code,
            'message' => $message,
        ];
        if ($errorCode !== null) {
            $response['error_code'] = $errorCode;
        }
        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        exit;
    }

    public static function errorWithData(array $data, int $code = 400): void {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(array_merge(['success' => false], $data), JSON_UNESCAPED_UNICODE);
        exit;
    }

    public static function notFound(string $item = 'Resource'): void {
        self::fail("{$item} not found", 404);
    }

    public static function unauthorized(string $message = 'Authentication required'): void {
        self::fail($message, 401);
    }

    public static function forbidden(string $message = 'Access denied'): void {
        self::fail($message, 403);
    }

    public static function rateLimited(int $retryAfter = 0): void {
        if ($retryAfter > 0) {
            header("Retry-After: {$retryAfter}");
        }
        self::fail('Rate limit exceeded. Try again later.', 429);
    }
}
