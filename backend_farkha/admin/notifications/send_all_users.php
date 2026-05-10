<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class NotificationSendAllApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $title = $this->getField('title');
            $body = $this->getField('body', '');

            Validator::required($title, 'title');

            $result = NotificationService::broadcastToTopic($title, $body, 'users', '', '');

            if ($result === null) {
                $this->error('فشل إرسال الإشعار', 500);
                return;
            }

            AdminAuth::logAction('notification.send_all', 'broadcast', 'all', [
                'title' => $title,
                'body' => $body,
            ]);

            $this->success(null);
        }, 'notification_send_all');
    }
}

new NotificationSendAllApi();
