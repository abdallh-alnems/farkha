<?php

/**
 * Farkha API - Main Entry Point
 * Restructured with Clean Architecture and Best Practices
 */

// Autoload classes (simple autoloader)
spl_autoload_register(function ($class) {
    $paths = [
        __DIR__ . '/../app/core/',
        __DIR__ . '/../app/config/',
        __DIR__ . '/../app/controllers/',
        __DIR__ . '/../app/models/',
        __DIR__ . '/../app/middleware/',
        __DIR__ . '/../app/utils/'
    ];
    
    foreach ($paths as $path) {
        $file = $path . $class . '.php';
        if (file_exists($file)) {
            require_once $file;
            break;
        }
    }
});

// Include routes
require_once __DIR__ . '/routes.php';

try {
    // Initialize application
    $app = App::getInstance();
    
    // Create router
    $router = new Router();
    
    // Load routes
    loadRoutes($router);
    
    // Run application
    $app->run($router);
    
} catch (Exception $e) {
    error_log("Application error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Internal server error',
        'timestamp' => date('Y-m-d H:i:s')
    ]);
}
