<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class AddPricesApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $higher = $this->requireNumeric('higher', 0);
            $type = $this->requireNumeric('type', 1);
            $lower = $this->getField('lower');
            $lowerValue = !empty($lower) ? Validator::numeric($lower, 'lower price', 0) : null;

            $latest = PriceModel::fetchLatestByType((int) $type);
            if ($latest) {
                $sameHigher = (float) $latest['higher'] === (float) $higher;
                $sameLower = ($lowerValue === null && ($latest['lower'] === null || (float) $latest['lower'] === 0.0))
                    || ($lowerValue !== null && $latest['lower'] !== null && (float) $latest['lower'] === (float) $lowerValue);
                if ($sameHigher && $sameLower) {
                    $this->error('السعر المدخل مطابق للسعر الحالي، لا يمكن تكرار نفس السعر', 409);
                }
            }

            $result = PriceModel::insert($higher, $lowerValue, (int) $type);

            if ($result > 0) {
                AdminAuth::logAction('price.add', 'price', $result, ['type' => (int) $type, 'higher' => $higher, 'lower' => $lowerValue]);
                $this->sendNotification((int) $type);
                $this->success(null);
            } else {
                $this->error('Failed to add price', 500);
            }
        }, 'add_price');
    }

    private function sendNotification(int $type): void {
        try {
            $topic = TopicManager::getTopicByProductId($type);
            if ($topic) {
                $name = TopicManager::getProductNameByTopic($topic);
                NotificationService::broadcastToTopic("تم تغيير سعر {$name}", '', $topic, (string) $type, $name);
            } else {
                NotificationService::broadcastToTopic('تم تحديث أسعار المنتجات', '', 'users', (string) $type, 'منتج غير معروف');
            }
        } catch (Exception $e) {
            error_log('FCM Notification failed: ' . $e->getMessage());
        }
    }
}

new AddPricesApi();
