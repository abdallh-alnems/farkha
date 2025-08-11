<?php

/**
 * API Routes Definition
 */

function loadRoutes($router)
{
    // Health check endpoint
    $router->get('/health', function() {
        ResponseHandler::success([
            'status' => 'healthy',
            'version' => '2.0',
            'timestamp' => date('Y-m-d H:i:s')
        ], 'API is running');
    });

    // Authentication endpoint
    $router->post('/auth/login', [AuthController::class, 'login']);
    $router->post('/auth/token', [AuthController::class, 'generateToken']);

    // Price routes
    $router->post('/prices/add', [PriceController::class, 'addPrice'], [AuthMiddleware::class . '@checkBasicAuth']);
    $router->get('/prices/latest', [PriceController::class, 'getLatestPrices']);
    $router->get('/prices/feasibility-study', [PriceController::class, 'getFeasibilityStudy']);
    $router->post('/prices/by-type', [PriceController::class, 'getPricesByType']);
    $router->get('/prices/web', [PriceController::class, 'getWebPrices']);
    $router->get('/prices/stats', [PriceController::class, 'getPriceStats']);

    // Suggestion routes
    $router->post('/suggestions/add', [SuggestionController::class, 'addSuggestion']);
    $router->get('/suggestions/recent', [SuggestionController::class, 'getRecentSuggestions']);
    $router->get('/suggestions/search', [SuggestionController::class, 'searchSuggestions']);
    $router->get('/suggestions/by-date', [SuggestionController::class, 'getSuggestionsByDate']);
    $router->get('/suggestions/stats', [SuggestionController::class, 'getSuggestionStats'], [AuthMiddleware::class . '@checkBasicAuth']);

    // Main category routes
    $router->get('/main', [MainController::class, 'getAllMain']);
    $router->get('/main/with-types', [MainController::class, 'getMainWithTypes']);
    $router->get('/main/{id}', [MainController::class, 'getMainById']);
    $router->get('/main/{id}/with-types', [MainController::class, 'getMainByIdWithTypes']);
    $router->get('/main/stats', [MainController::class, 'getMainStats'], [AuthMiddleware::class . '@checkBasicAuth']);

    // Legacy compatibility routes (redirects to new endpoints)
    $router->post('/create/add.php', function() {
        header('Location: /prices/add', true, 301);
        exit;
    });
    
    $router->post('/create/suggestion.php', function() {
        header('Location: /suggestions/add', true, 301);
        exit;
    });
    
    $router->get('/read/main.php', function() {
        header('Location: /main', true, 301);
        exit;
    });
    
    $router->get('/read/last_prices.php', function() {
        header('Location: /prices/by-type', true, 301);
        exit;
    });
    
    $router->get('/read/web_last_prices.php', function() {
        header('Location: /prices/web', true, 301);
        exit;
    });
    
    $router->get('/read/farkh_abid.php', function() {
        header('Location: /prices/latest?type=1', true, 301);
        exit;
    });
    
    $router->get('/read/feasibility_study.php', function() {
        header('Location: /prices/feasibility-study', true, 301);
        exit;
    });

    // API documentation endpoint
    $router->get('/docs', function() {
        ResponseHandler::success([
            'api_name' => 'Farkha API',
            'version' => '2.0',
            'description' => 'Poultry prices and suggestions management API',
            'endpoints' => [
                'prices' => [
                    'POST /prices/add' => 'Add new price (requires auth)',
                    'GET /prices/latest?type={id}' => 'Get latest prices by type',
                    'GET /prices/feasibility-study' => 'Get feasibility study data',
                    'POST /prices/by-type' => 'Get prices by type with form data',
                    'GET /prices/web' => 'Get web prices',
                    'GET /prices/stats?type={id}&days={days}' => 'Get price statistics'
                ],
                'suggestions' => [
                    'POST /suggestions/add' => 'Add new suggestion',
                    'GET /suggestions/recent?limit={limit}' => 'Get recent suggestions',
                    'GET /suggestions/search?q={keyword}' => 'Search suggestions',
                    'GET /suggestions/by-date?start={date}&end={date}' => 'Get suggestions by date range',
                    'GET /suggestions/stats' => 'Get suggestion statistics (requires auth)'
                ],
                'main' => [
                    'GET /main' => 'Get all main categories',
                    'GET /main/with-types' => 'Get main categories with types',
                    'GET /main/{id}' => 'Get specific main category',
                    'GET /main/{id}/with-types' => 'Get main category with types',
                    'GET /main/stats' => 'Get main categories statistics (requires auth)'
                ],
                'auth' => [
                    'POST /auth/login' => 'Login with credentials',
                    'POST /auth/token' => 'Generate JWT token'
                ],
                'utility' => [
                    'GET /health' => 'Health check',
                    'GET /docs' => 'API documentation'
                ]
            ]
        ], 'API Documentation');
    });
}
