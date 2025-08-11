<?php

require_once __DIR__ . '/../config/app.php';
require_once __DIR__ . '/../utils/ResponseHandler.php';

/**
 * Authentication Middleware
 * Handles both Basic Auth and JWT authentication
 */
class AuthMiddleware
{
    private $config;

    public function __construct()
    {
        $this->config = AppConfig::getConfig();
    }

    /**
     * Check Basic Authentication
     */
    public function checkBasicAuth()
    {
        if (!isset($_SERVER['PHP_AUTH_USER']) || !isset($_SERVER['PHP_AUTH_PW'])) {
            $this->unauthorizedResponse('Missing authentication credentials');
            return false;
        }

        $username = $_SERVER['PHP_AUTH_USER'];
        $password = $_SERVER['PHP_AUTH_PW'];

        if ($username !== $this->config['auth']['basic_auth_user'] || 
            $password !== $this->config['auth']['basic_auth_pass']) {
            $this->unauthorizedResponse('Invalid credentials');
            return false;
        }

        return true;
    }

    /**
     * Generate JWT Token
     */
    public function generateJWT($payload)
    {
        $header = json_encode(['typ' => 'JWT', 'alg' => $this->config['auth']['jwt_algorithm']]);
        
        $payload['iat'] = time();
        $payload['exp'] = time() + $this->config['auth']['jwt_expiration'];
        $payload = json_encode($payload);

        $base64Header = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64Payload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));

        $signature = hash_hmac('sha256', $base64Header . "." . $base64Payload, $this->config['auth']['jwt_secret'], true);
        $base64Signature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

        return $base64Header . "." . $base64Payload . "." . $base64Signature;
    }

    /**
     * Verify JWT Token
     */
    public function verifyJWT($token)
    {
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            return false;
        }

        list($header, $payload, $signature) = $parts;

        $validSignature = hash_hmac('sha256', $header . "." . $payload, $this->config['auth']['jwt_secret'], true);
        $validSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($validSignature));

        if (!hash_equals($signature, $validSignature)) {
            return false;
        }

        $payload = json_decode(base64_decode($payload), true);
        
        if ($payload['exp'] < time()) {
            return false; // Token expired
        }

        return $payload;
    }

    /**
     * Get Bearer Token from Authorization header
     */
    public function getBearerToken()
    {
        $headers = apache_request_headers();
        if (isset($headers['Authorization'])) {
            if (preg_match('/Bearer\s(\S+)/', $headers['Authorization'], $matches)) {
                return $matches[1];
            }
        }
        return null;
    }

    /**
     * Check JWT Authentication
     */
    public function checkJWTAuth()
    {
        $token = $this->getBearerToken();
        if (!$token) {
            $this->unauthorizedResponse('Missing or invalid token');
            return false;
        }

        $payload = $this->verifyJWT($token);
        if (!$payload) {
            $this->unauthorizedResponse('Invalid or expired token');
            return false;
        }

        return $payload;
    }

    /**
     * Send unauthorized response
     */
    private function unauthorizedResponse($message)
    {
        http_response_code(401);
        header('WWW-Authenticate: Basic realm="Farkha API"');
        ResponseHandler::error($message, 401);
        exit;
    }
}
