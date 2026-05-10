<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class NotificationSendTopicApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $topic = $this->getField('topic');
            $title = $this->getField('title');
            $body = $this->getField('body', '');
            $data = $this->getField('data');

            Validator::required($topic, 'topic');
            Validator::required($title, 'title');

            $dataArr = is_array($data) ? $data : [];
            NotificationService::broadcastToTopic($title, $body, $topic, '', '');

            AdminAuth::logAction('notification.send_topic', 'topic', $topic, [
                'title' => $title,
                'body' => $body,
            ]);

            $this->success(null);
        }, 'notification_send_topic');
    }
}

new NotificationSendTopicApi();
