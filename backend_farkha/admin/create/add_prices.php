    <?php

    
    error_reporting(E_ALL);
    ini_set('display_errors', 1);

    require_once __DIR__ . '/../../core/connect.php';
    include "../../core/queries/queries.php";
    include "../../notification/fcm_sender.php";
    include "../../notification/topic_manager.php";

class AddPricesAPI extends BaseAPI {
    
    public function __construct() {
        parent::__construct();
        $this->handleRequest();
    }
    
    private function handleRequest() {
        $this->handleApiRequest(function() {
            $this->addPrice();
        }, 'add_price_api');
    }
    
    public function addPrice() {
        $higher = $this->getHigher();
        $lower = $this->getLower();
        $type = $this->getType();
        
        if (!$this->validateRequiredField($higher, 'Higher price')) return;
        if (!$this->validateRequiredNumeric($type, 'type')) return;
        if (!$this->validateRequiredNumeric($higher, 'higher price')) return;
        if (!$this->validateLowerPrice($lower)) return;
        
        $lowerValue = !empty($lower) ? $lower : null;
        $query = "INSERT INTO `prices` (`higher`, `lower`, `type`) VALUES (?, ?, ?)";
        $result = $this->db->execute($query, [$higher, $lowerValue, $type]);
        
        if ($result > 0) {
            $this->sendNotification($type);
            $this->sendSuccess(null);
        } else {
            $this->handleError(500, 'Failed to add price');
        }
    }
    
    private function sendNotification($type) {
        try {
            $productTopic = TopicManager::getTopicByProductId($type);
            
            if ($productTopic) {
                $productName = TopicManager::getProductNameByTopic($productTopic);
                $notificationTitle = "تم تغيير سعر {$productName}";
                $notificationMessage = "";
                
                $fcmResult = sendFCM(
                    $notificationTitle,
                    $notificationMessage,
                    $productTopic, 
                    $type, 
                    $productName 
                );
                
                error_log("FCM Notification sent successfully to topic '{$productTopic}' for product '{$productName}': " . $fcmResult);
            } else {
                $notificationTitle = "تم تحديث أسعار المنتجات";
                $notificationMessage = "";
                
                $fcmResult = sendFCM(
                    $notificationTitle,
                    $notificationMessage,
                    "users", 
                    $type,
                    "منتج غير معروف"
                );
                
                error_log("FCM Notification sent to fallback topic 'users' for product ID '{$type}': " . $fcmResult);
            }
        } catch (Exception $e) {
            error_log("FCM Notification failed: " . $e->getMessage());
        }
    }
}

// Initialize the API
try {
    new AddPricesAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'add_price_api']);
}
