<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class NotificationSendUserApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $userId = (int) $this->requireNumeric('user_id', 1);
            $title = $this->getField('title');
            $body = $this->getField('body', '');
            $data = $this->getField('data');

            Validator::required($title, 'title');

            $user = Database::fetchOne("SELECT id FROM users WHERE id = ? LIMIT 1", [$userId]);
            if (!$user) {
                $this->error('User not found', 404);
            }

            $dataArr = is_array($data) ? $data : [];
            NotificationService::sendToUser(Database::getInstance(), $userId, $title, $body, $dataArr);

            AdminAuth::logAction('notification.send_user', 'user', $userId, [
                'title' => $title,
                'body' => $body,
            ]);

            $this->success(null);
        }, 'notification_send_user');
    }
}

new NotificationSendUserApi();
