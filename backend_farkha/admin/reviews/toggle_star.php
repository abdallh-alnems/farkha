<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class ToggleReviewStarApi extends AdminBaseApi {
    protected ?string $minRole = 'editor';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $type = $this->getField('type');
            $id = (int) $this->getField('id');

            if ($id < 1) {
                $this->error('معرّف التقييم غير صالح', 400);
            }

            if (!in_array($type, ['app', 'cycle'], true)) {
                $this->error('type يجب أن يكون app أو cycle');
            }

            $table = $type === 'app' ? 'app_reviews' : 'cycle_feedbacks';

            $con = Database::getInstance();
            $con->beginTransaction();

            try {
                $row = Database::fetchOne("SELECT id, is_starred FROM {$table} WHERE id = ? FOR UPDATE", [$id]);
                if (!$row) {
                    $con->rollBack();
                    $this->error('التقييم غير موجود', 404);
                }

                $newStarred = $row['is_starred'] ? 0 : 1;
                Database::query("UPDATE {$table} SET is_starred = ? WHERE id = ?", [$newStarred, $id]);

                $con->commit();

                $this->success(['is_starred' => $newStarred]);
            } catch (Exception $e) {
                if ($con->inTransaction()) $con->rollBack();
                throw $e;
            }
        }, 'toggle_review_star');
    }
}

new ToggleReviewStarApi();
