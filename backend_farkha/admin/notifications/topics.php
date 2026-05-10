<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class TopicsListApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $topics = TopicManager::getAllTopics();
            $this->success($topics);
        }, 'topics_list');
    }
}

new TopicsListApi();
