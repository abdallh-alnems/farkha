<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class ToggleReviewStarApi extends AdminBaseApi {
    protected ?string $minRole = 'editor';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $type = $this->getField('type');
            $id = (int) $this->getField('id');

            if (!in_array($type, ['app', 'cycle'], true)) {
                $this->error('type يجب أن يكون app أو cycle');
            }

            $table = $type === 'app' ? 'app_reviews' : 'cycle_feedbacks';

            $row = Database::fetchOne("SELECT is_starred FROM {$table} WHERE id = ?", [$id]);
            if (!$row) {
                $this->error('التقييم غير موجود', 404);
            }

            $newVal = $row['is_starred'] ? 0 : 1;
            Database::query("UPDATE {$table} SET is_starred = ? WHERE id = ?", [$newVal, $id]);

            $this->success(['is_starred' => $newVal]);
        }, 'toggle_review_star');
    }
}

new ToggleReviewStarApi();
