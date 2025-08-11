<?php

require_once __DIR__ . '/../config/app.php';

/**
 * CORS Middleware
 * Handles Cross-Origin Resource Sharing
 */
class CorsMiddleware
{
    private $config;

    public function __construct()
    {
        $this->config = AppConfig::getConfig()['cors'];
    }

    /**
     * Handle CORS
     */
    public function handle()
    {
        // Get origin
        $origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
        
        // Check if origin is allowed
        if ($this->isOriginAllowed($origin)) {
            header("Access-Control-Allow-Origin: $origin");
        } else {
            header("Access-Control-Allow-Origin: " . $this->config['allowed_origins'][0]);
        }

        // Set other CORS headers
        header("Access-Control-Allow-Methods: " . implode(', ', $this->config['allowed_methods']));
        header("Access-Control-Allow-Headers: " . implode(', ', $this->config['allowed_headers']));
        header("Access-Control-Allow-Credentials: true");
        header("Access-Control-Max-Age: 3600");

        // Set content type
        header("Content-Type: application/json; charset=utf-8");

        return true;
    }

    /**
     * Check if origin is allowed
     */
    private function isOriginAllowed($origin)
    {
        $allowedOrigins = $this->config['allowed_origins'];
        
        // If * is allowed, accept all origins
        if (in_array('*', $allowedOrigins)) {
            return true;
        }
        
        // Check exact match
        if (in_array($origin, $allowedOrigins)) {
            return true;
        }
        
        // Check wildcard patterns
        foreach ($allowedOrigins as $allowed) {
            if (strpos($allowed, '*') !== false) {
                $pattern = str_replace('*', '.*', $allowed);
                if (preg_match('/^' . $pattern . '$/', $origin)) {
                    return true;
                }
            }
        }
        
        return false;
    }
}
