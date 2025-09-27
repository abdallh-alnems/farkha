<?php
// Simple analytics API
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Set content type
header('Content-Type: application/json; charset=utf-8');

// Include required files
include "../connect.php"; 
include "../queries.php";

// Check authentication
checkAuthenticate(); 

class ToolsAnalyticsAPI extends BaseAPI {

    public function getAnalyticsData($period = '7days') {
        $db = DatabaseConnection::getInstance();
        
        // Get analytics data based on period
        $query = '';
        switch ($period) {
            case '7days':
                $query = Queries::getToolsUsage7DaysQuery();
                break;
            case '30days':
                $query = Queries::getToolsUsage30DaysQuery();
                break;
            case '1year':
                $query = Queries::getToolsUsage1YearQuery();
                break;
            case 'alltime':
                $query = Queries::getToolsUsageAllTimeQuery();
                break;
            default:
                $query = Queries::getToolsUsage7DaysQuery();
        }
        
        $analyticsData = $db->fetchAll($query);
        
        // Format the results
        $formattedData = [];
        foreach ($analyticsData as $row) {
            $formattedData[] = [
                'tool_id' => $row['tool_id'],
                'total_usage' => (int)$row['total_usage']
            ];
        }
        
        // Add period information
        $response = [
            'period' => $period,
            'data' => $formattedData
        ];
        
        ApiResponse::success($response, 200);
    }
    
    public function getAllAnalyticsData() {
        $db = DatabaseConnection::getInstance();
        
        $analyticsData = [
            '7days' => [
                'period' => '7days',
                'data' => $this->formatAnalyticsData($db->fetchAll(Queries::getToolsUsage7DaysQuery()))
            ],
            '30days' => [
                'period' => '30days',
                'data' => $this->formatAnalyticsData($db->fetchAll(Queries::getToolsUsage30DaysQuery()))
            ],
            '1year' => [
                'period' => '1year',
                'data' => $this->formatAnalyticsData($db->fetchAll(Queries::getToolsUsage1YearQuery()))
            ],
            'alltime' => [
                'period' => 'alltime',
                'data' => $this->formatAnalyticsData($db->fetchAll(Queries::getToolsUsageAllTimeQuery()))
            ]
        ];
        
        ApiResponse::success($analyticsData, 200);
    }
    
    private function formatAnalyticsData($data) {
        $formattedData = [];
        foreach ($data as $row) {
            $formattedData[] = [
                'tool_id' => $row['tool_id'],
                'total_usage' => (int)$row['total_usage']
            ];
        }
        return $formattedData;
    }
    
}

// Handle the request
$method = $_SERVER['REQUEST_METHOD'];

// Get parameters from both GET and POST
$period = $_GET['period'] ?? $_POST['period'] ?? '7days';
$all = $_GET['all'] ?? $_POST['all'] ?? false;

try {
    $api = new ToolsAnalyticsAPI();

    // Accept both GET and POST methods
    if ($method === 'GET' || $method === 'POST') {
        if ($all === 'true' || $all === true) {
            $api->getAllAnalyticsData();
        } else {
            $api->getAnalyticsData($period);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Method not allowed'], JSON_UNESCAPED_UNICODE);
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ], JSON_UNESCAPED_UNICODE);
}

?>
