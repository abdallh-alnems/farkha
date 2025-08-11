<?php

require_once __DIR__ . '/../config/app.php';
require_once __DIR__ . '/../middleware/CorsMiddleware.php';
require_once __DIR__ . '/../utils/Logger.php';

/**
 * Application Bootstrap Class
 */
class App
{
    private static $instance = null;
    private $config;

    private function __construct()
    {
        $this->config = AppConfig::getConfig();
        $this->initialize();
    }

    public static function getInstance()
    {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    /**
     * Initialize application
     */
    private function initialize()
    {
        // Set timezone
        date_default_timezone_set($this->config['timezone']);

        // Set error reporting
        if ($this->config['debug']) {
            error_reporting(E_ALL);
            ini_set('display_errors', 1);
        } else {
            error_reporting(0);
            ini_set('display_errors', 0);
        }

        // Load environment variables
        $this->loadEnvironment();

        // Set up error handlers
        $this->setupErrorHandlers();
    }

    /**
     * Load environment variables from .env file
     */
    private function loadEnvironment()
    {
        $envFile = __DIR__ . '/../../.env';
        if (file_exists($envFile)) {
            $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
            foreach ($lines as $line) {
                if (strpos($line, '=') !== false && strpos($line, '#') !== 0) {
                    list($key, $value) = explode('=', $line, 2);
                    $key = trim($key);
                    $value = trim($value, '"\'');
                    $_ENV[$key] = $value;
                    putenv("$key=$value");
                }
            }
        }
    }

    /**
     * Set up error handlers
     */
    private function setupErrorHandlers()
    {
        set_error_handler(function($severity, $message, $file, $line) {
            Logger::error("PHP Error: $message in $file on line $line");
            if (!$this->config['debug']) {
                ResponseHandler::serverError('Internal server error');
                exit;
            }
        });

        set_exception_handler(function($exception) {
            Logger::error("Uncaught Exception: " . $exception->getMessage());
            if (!$this->config['debug']) {
                ResponseHandler::serverError('Internal server error');
            } else {
                ResponseHandler::serverError($exception->getMessage());
            }
            exit;
        });
    }

    /**
     * Run the application
     */
    public function run($router)
    {
        // Add CORS middleware
        $router->middleware(CorsMiddleware::class);
        
        // Run the router
        $router->run();
    }

    /**
     * Get application configuration
     */
    public function getConfig()
    {
        return $this->config;
    }

    // Prevent cloning
    private function __clone() {}

    // Prevent unserializing
    public function __wakeup()
    {
        throw new Exception("Cannot unserialize singleton");
    }
}
