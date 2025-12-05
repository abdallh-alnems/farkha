<?php
// Simple analytics API

// Include required files
require_once __DIR__ . '/../core/connect.php';
include "../core/queries/queries.php";

class ToolsAnalyticsAPI extends BaseAPI {
    private $analyticsData = null;

    private function getAnalyticsData() {
        if ($this->analyticsData === null) {
            $query = Queries::getUnifiedToolsUsageAnalyticsQuery();
            $this->analyticsData = $this->db->fetchAll($query);
        }
        return $this->analyticsData;
    }

    public function getAnalyticsDataForPeriod($period = '7days') {
        $analyticsData = $this->getAnalyticsData();
        
        // Format the results based on requested period
        $formattedData = [];
        foreach ($analyticsData as $row) {
            $totalUsage = 0;
            switch ($period) {
                case '7days':
                    $totalUsage = (int)$row['usage_7days'];
                    break;
                case '30days':
                    $totalUsage = (int)$row['usage_30days'];
                    break;
                case '1year':
                    $totalUsage = (int)$row['usage_1year'];
                    break;
                case 'alltime':
                    $totalUsage = (int)$row['usage_alltime'];
                    break;
                default:
                    $totalUsage = (int)$row['usage_7days'];
            }
            
            $formattedData[] = [
                'tool_id' => $row['tool_id'],
                'total_usage' => $totalUsage
            ];
        }
        
        // Add period information
        $response = [
            'period' => $period,
            'data' => $formattedData
        ];
        
        $this->sendSuccess($response);
    }
    
    public function getAllAnalyticsData() {
        $analyticsData = $this->getAnalyticsData();
        
        // Format the results for all periods
        $formattedData = [
            '7days' => [
                'period' => '7days',
                'data' => $this->formatAnalyticsDataForPeriod($analyticsData, 'usage_7days')
            ],
            '30days' => [
                'period' => '30days',
                'data' => $this->formatAnalyticsDataForPeriod($analyticsData, 'usage_30days')
            ],
            '1year' => [
                'period' => '1year',
                'data' => $this->formatAnalyticsDataForPeriod($analyticsData, 'usage_1year')
            ],
            'alltime' => [
                'period' => 'alltime',
                'data' => $this->formatAnalyticsDataForPeriod($analyticsData, 'usage_alltime')
            ]
        ];
        
        $this->sendSuccess($formattedData);
    }
    
    private function formatAnalyticsDataForPeriod($data, $periodColumn) {
        $formattedData = [];
        foreach ($data as $row) {
            $formattedData[] = [
                'tool_id' => $row['tool_id'],
                'total_usage' => (int)$row[$periodColumn]
            ];
        }
        return $formattedData;
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
            $api->getAnalyticsDataForPeriod($period);
        }
    } else {
        ApiResponse::fail('Method not allowed', 405);
    }
} catch (Exception $e) {
    handleApiError($e, ['context' => 'tools_analytics_api']);
}

?>
