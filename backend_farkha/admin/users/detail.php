<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class UserDetailApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $userId = (int) $this->requireNumeric('user_id', 1);

            $user = Database::fetchOne(
                "SELECT id, name, phone, firebase_uid, created_at, updated_at FROM users WHERE id = ? LIMIT 1",
                [$userId]
            );

            if (!$user) {
                $this->error('User not found', 404);
            }

            $devices = Database::fetchAll(
                "SELECT id, platform, device_id, last_active, created_at FROM user_devices WHERE user_id = ? ORDER BY last_active DESC",
                [$userId]
            );

            $cycles = Database::fetchAll(
                "SELECT c.id, c.name, c.chick_count, c.start_date_raw, c.end_date_raw,
                        cu.role, cu.status, c.deleted_at
                 FROM cycle_users cu
                 JOIN cycles c ON c.id = cu.cycle_id
                 WHERE cu.user_id = ?
                 ORDER BY c.created_at DESC",
                [$userId]
            );

            $reviews = Database::fetchAll(
                "SELECT id, rating, issue, suggestion, app_version, platform, created_at FROM app_reviews WHERE user_id = ? ORDER BY created_at DESC LIMIT 10",
                [$userId]
            );

            $this->success([
                'user' => $user,
                'devices' => $devices,
                'cycles' => $cycles,
                'reviews' => $reviews,
            ]);
        }, 'user_detail');
    }
}

new UserDetailApi();
