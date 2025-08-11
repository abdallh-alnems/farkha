<?php

require_once __DIR__ . '/../utils/ResponseHandler.php';

/**
 * Simple Router Class
 * Handles API routing and method dispatching
 */
class Router
{
    private $routes = [];
    private $middleware = [];

    /**
     * Add GET route
     */
    public function get($path, $callback, $middleware = [])
    {
        $this->addRoute('GET', $path, $callback, $middleware);
    }

    /**
     * Add POST route
     */
    public function post($path, $callback, $middleware = [])
    {
        $this->addRoute('POST', $path, $callback, $middleware);
    }

    /**
     * Add PUT route
     */
    public function put($path, $callback, $middleware = [])
    {
        $this->addRoute('PUT', $path, $callback, $middleware);
    }

    /**
     * Add DELETE route
     */
    public function delete($path, $callback, $middleware = [])
    {
        $this->addRoute('DELETE', $path, $callback, $middleware);
    }

    /**
     * Add route with any method
     */
    private function addRoute($method, $path, $callback, $middleware = [])
    {
        $this->routes[] = [
            'method' => $method,
            'path' => $path,
            'callback' => $callback,
            'middleware' => $middleware
        ];
    }

    /**
     * Add global middleware
     */
    public function middleware($middleware)
    {
        $this->middleware[] = $middleware;
    }

    /**
     * Run the router
     */
    public function run()
    {
        $method = $_SERVER['REQUEST_METHOD'];
        $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
        
        // Remove base path if needed
        $basePath = dirname($_SERVER['SCRIPT_NAME']);
        if ($basePath !== '/' && strpos($path, $basePath) === 0) {
            $path = substr($path, strlen($basePath));
        }
        
        // Handle OPTIONS requests for CORS
        if ($method === 'OPTIONS') {
            $this->handleOptions();
            return;
        }

        // Find matching route
        foreach ($this->routes as $route) {
            if ($this->matchRoute($route, $method, $path)) {
                $this->executeRoute($route, $path);
                return;
            }
        }

        // No route found
        ResponseHandler::notFound('Endpoint not found');
    }

    /**
     * Check if route matches
     */
    private function matchRoute($route, $method, $path)
    {
        if ($route['method'] !== $method) {
            return false;
        }

        $pattern = preg_replace('/\{[^}]+\}/', '([^/]+)', $route['path']);
        $pattern = str_replace('/', '\/', $pattern);
        $pattern = '/^' . $pattern . '$/';

        return preg_match($pattern, $path);
    }

    /**
     * Execute matched route
     */
    private function executeRoute($route, $path)
    {
        try {
            // Run global middleware
            foreach ($this->middleware as $middleware) {
                if (!$this->runMiddleware($middleware)) {
                    return;
                }
            }

            // Run route-specific middleware
            foreach ($route['middleware'] as $middleware) {
                if (!$this->runMiddleware($middleware)) {
                    return;
                }
            }

            // Extract parameters from path
            $params = $this->extractParams($route['path'], $path);

            // Execute callback
            $callback = $route['callback'];
            if (is_array($callback)) {
                $controller = new $callback[0]();
                call_user_func_array([$controller, $callback[1]], $params);
            } else {
                call_user_func_array($callback, $params);
            }

        } catch (Exception $e) {
            error_log("Router error: " . $e->getMessage());
            ResponseHandler::serverError('Internal server error');
        }
    }

    /**
     * Run middleware
     */
    private function runMiddleware($middleware)
    {
        try {
            if (is_string($middleware)) {
                $instance = new $middleware();
                return $instance->handle();
            } elseif (is_array($middleware)) {
                $instance = new $middleware[0]();
                return call_user_func([$instance, $middleware[1]]);
            } elseif (is_callable($middleware)) {
                return call_user_func($middleware);
            }
        } catch (Exception $e) {
            error_log("Middleware error: " . $e->getMessage());
            ResponseHandler::unauthorized('Authentication failed');
            return false;
        }
        
        return true;
    }

    /**
     * Extract parameters from path
     */
    private function extractParams($routePath, $actualPath)
    {
        $routeParts = explode('/', trim($routePath, '/'));
        $actualParts = explode('/', trim($actualPath, '/'));
        
        $params = [];
        for ($i = 0; $i < count($routeParts); $i++) {
            if (strpos($routeParts[$i], '{') === 0) {
                $params[] = $actualParts[$i] ?? null;
            }
        }
        
        return $params;
    }

    /**
     * Handle OPTIONS requests for CORS
     */
    private function handleOptions()
    {
        header('HTTP/1.1 200 OK');
        exit;
    }
}
