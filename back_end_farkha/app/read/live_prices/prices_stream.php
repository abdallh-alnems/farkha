<?php

include "../../../connect.php";
include "../../../queries.php";

class PricesStreamAPI {
    private $db;
    private $maxExecutionTime;
    private $checkInterval;
    
    public function __construct() {
        $this->db = DatabaseConnection::getInstance();
        $this->maxExecutionTime = 3600; // 1 hour max
        $this->checkInterval = 300; // 300 seconds (5 minutes) interval to prevent server overload
        
        set_time_limit($this->maxExecutionTime);
        
        $this->setSSEHeaders();
        
        
        $this->checkRateLimit();
        
    }
    
    
    private function setSSEHeaders() {
        header('Content-Type: text/event-stream');
        header('Cache-Control: no-cache');
        header('Connection: keep-alive');
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Headers: Cache-Control');
        header('X-Accel-Buffering: no'); // Disable nginx buffering
        header('Connection: close'); // Close connection when client disconnects
    }
    
    private function checkRateLimit() {
        $identifier = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        if (!RateLimiter::checkLimit($identifier, 10, 3600)) { // 10 requests per hour
            header("Location: ../../../error.php?code=429&message=" . urlencode('Rate limit exceeded. Please try again later.'));
            exit;
        }
    }
    
    private function sendSSEData($data) {
        echo "data: " . json_encode($data, JSON_UNESCAPED_UNICODE) . "\n\n";
        
        if (ob_get_level()) {
            ob_flush();
        }
        flush();
        
        // Check if client disconnected after sending data
        if (connection_aborted()) {
            return false;
        }
        return true;
    }
    
    
    private function fetchPriceData($type_ids) {
        try {
            $params = $type_ids;
            
            $where_clause = Queries::buildTypeFilterWhereClause($type_ids);
            $query = Queries::getPricesStreamQuery($where_clause);
            
            $result = $this->db->fetchAll($query, $params);
            
            
            return $result;
            
        } catch (Exception $e) {
            return false;
        }
    }
    
    
    public function startStream() {
        $type_ids = ApiValidationHelper::sanitizeTypeIds($_GET['type_ids'] ?? $_POST['type_ids'] ?? []);
        
        $startTime = time();
        $lastDataHash = '';
        
        while (true) {
            // Check if client is still connected
            if (connection_aborted()) {
                break;
            }
            
            // Check if client is still active (no data sent for 30 seconds)
            if (connection_status() != CONNECTION_NORMAL) {
                break;
            }
            
            if ((time() - $startTime) > $this->maxExecutionTime) {
                header("Location: ../../../error.php?code=408&message=" . urlencode('Stream timeout reached. Please reconnect.'));
                exit;
            }
            
            $data = $this->fetchPriceData($type_ids);
            
            if ($data === false) {
                header("Location: ../../../error.php?code=500&message=" . urlencode('خطأ في قاعدة البيانات'));
                exit;
            }
            
            if (empty($data)) {
                header("Location: ../../../error.php?code=404&message=" . urlencode('لا توجد بيانات للأنواع المطلوبة'));
                exit;
            }
            
            $currentDataHash = md5(json_encode($data));
            if ($currentDataHash === $lastDataHash) {
                sleep($this->checkInterval);
                continue;
            }
            $lastDataHash = $currentDataHash;
            
            if (!$this->sendSSEData([
                'status' => 'success',
                'data' => $data
            ])) {
                break; // Client disconnected
            }
            
            sleep($this->checkInterval);
        }
    }
}

// Initialize and start the stream
try {
    $stream = new PricesStreamAPI();
    $stream->startStream();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'prices_stream']);
}
?>
