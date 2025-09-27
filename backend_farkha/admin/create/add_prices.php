    <?php

    // Enable error reporting for debugging
    error_reporting(E_ALL);
    ini_set('display_errors', 1);

    include "../../connect.php";
    include "../../queries.php";

    class AddPricesAPI extends BaseAPI {
        
        public function addPrice() {
            try {
                // Validate input parameters
                $higher = filterRequest('higher');
                $lower = filterRequest('lower');
                $type = filterRequest('type');
                
                if (empty($higher) || empty($lower) || empty($type)) {
                    $this->handleError(400, 'Higher price, lower price, and type are required');
                    return;
                }
                
                // Validate prices are numeric
                if (!is_numeric($higher) || !is_numeric($lower)) {
                    $this->handleError(400, 'Higher and lower prices must be valid numbers');
                    return;
                }
                
                // Validate type is numeric
                if (!is_numeric($type)) {
                    $this->handleError(400, 'Type must be a valid number');
                    return;
                }
                
                // Insert price using the database connection (date will be added automatically)
                $query = "INSERT INTO `prices` (`higher`, `lower`, `type`) VALUES (?, ?, ?)";
                $result = $this->db->execute($query, [$higher, $lower, $type]);
                
                if ($result > 0) {
                    $this->sendSuccess(null);
                } else {
                    $this->handleError(500, 'Failed to add price');
                }
            } catch (Exception $e) {
                // Log the error and return a proper error response
                error_log("Add Price Error: " . $e->getMessage());
                
                // Check if ApiResponse class exists
                if (class_exists('ApiResponse')) {
                    ApiResponse::error('Internal server error: ' . $e->getMessage(), 500);
                } else {
                    // Fallback error response
                    header('Content-Type: application/json');
                    http_response_code(500);
                    echo json_encode([
                        'status' => 'error',
                        'message' => 'Internal server error: ' . $e->getMessage()
                    ]);
                }
            }
        }
    }

    // Handle the request
    $method = $_SERVER['REQUEST_METHOD'];

    if ($method === 'POST') {
        $api = new AddPricesAPI();
        $api->addPrice();
    } else {
        ApiResponse::error('Method not allowed', 405);
    }

    ?>
