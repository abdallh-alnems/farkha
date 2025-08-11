<?php

require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/../utils/ResponseHandler.php';
require_once __DIR__ . '/../utils/Validator.php';

/**
 * Authentication Controller
 * Handles authentication endpoints
 */
class AuthController
{
    private $authMiddleware;

    public function __construct()
    {
        $this->authMiddleware = new AuthMiddleware();
    }

    /**
     * Login with basic credentials
     * POST /auth/login
     */
    public function login()
    {
        try {
            if ($this->authMiddleware->checkBasicAuth()) {
                $token = $this->authMiddleware->generateJWT([
                    'user' => $_SERVER['PHP_AUTH_USER'],
                    'type' => 'api_access'
                ]);

                ResponseHandler::success([
                    'token' => $token,
                    'token_type' => 'Bearer',
                    'expires_in' => 3600
                ], 'Login successful');
            }
        } catch (Exception $e) {
            error_log("Login error: " . $e->getMessage());
            ResponseHandler::unauthorized('Login failed');
        }
    }

    /**
     * Generate JWT token with basic auth
     * POST /auth/token
     */
    public function generateToken()
    {
        try {
            $data = Validator::filterRequest(['username', 'password']);
            
            $validator = new Validator($data);
            $validator->required('username', 'Username is required')
                     ->required('password', 'Password is required');

            if ($validator->fails()) {
                ResponseHandler::validationError($validator->getErrors());
                return;
            }

            // Set basic auth headers for validation
            $_SERVER['PHP_AUTH_USER'] = $data['username'];
            $_SERVER['PHP_AUTH_PW'] = $data['password'];

            if ($this->authMiddleware->checkBasicAuth()) {
                $token = $this->authMiddleware->generateJWT([
                    'user' => $data['username'],
                    'type' => 'api_access'
                ]);

                ResponseHandler::success([
                    'token' => $token,
                    'token_type' => 'Bearer',
                    'expires_in' => 3600
                ], 'Token generated successfully');
            }
        } catch (Exception $e) {
            error_log("Token generation error: " . $e->getMessage());
            ResponseHandler::unauthorized('Token generation failed');
        }
    }

    /**
     * Validate JWT token
     * POST /auth/validate
     */
    public function validateToken()
    {
        try {
            $payload = $this->authMiddleware->checkJWTAuth();
            if ($payload) {
                ResponseHandler::success([
                    'valid' => true,
                    'payload' => $payload,
                    'expires_at' => date('Y-m-d H:i:s', $payload['exp'])
                ], 'Token is valid');
            }
        } catch (Exception $e) {
            error_log("Token validation error: " . $e->getMessage());
            ResponseHandler::unauthorized('Invalid token');
        }
    }

    /**
     * Refresh JWT token
     * POST /auth/refresh
     */
    public function refreshToken()
    {
        try {
            $payload = $this->authMiddleware->checkJWTAuth();
            if ($payload) {
                // Generate new token
                $newToken = $this->authMiddleware->generateJWT([
                    'user' => $payload['user'],
                    'type' => 'api_access'
                ]);

                ResponseHandler::success([
                    'token' => $newToken,
                    'token_type' => 'Bearer',
                    'expires_in' => 3600
                ], 'Token refreshed successfully');
            }
        } catch (Exception $e) {
            error_log("Token refresh error: " . $e->getMessage());
            ResponseHandler::unauthorized('Token refresh failed');
        }
    }
}
