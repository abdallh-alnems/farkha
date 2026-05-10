<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class UserDeleteApi extends AdminBaseApi {
    protected ?string $minRole = 'superadmin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $userId = (int) $this->requireNumeric('user_id', 1);
            $reason = trim($this->getField('reason', 'admin_delete'));

            $user = Database::fetchOne("SELECT * FROM users WHERE id = ? LIMIT 1", [$userId]);
            if (!$user) {
                $this->error('User not found', 404);
            }

            $cyclesOwned = (int) Database::fetchOne(
                "SELECT COUNT(*) c FROM cycles WHERE owner_user_id = ? AND deleted_at IS NULL",
                [$userId]
            )['c'];

            $cyclesMember = (int) Database::fetchOne(
                "SELECT COUNT(*) c FROM cycle_users WHERE user_id = ?",
                [$userId]
            )['c'];

            $accountAge = (int) ((time() - strtotime($user['created_at'])) / 86400);

            $lastDevice = Database::fetchOne(
                "SELECT platform FROM user_devices WHERE user_id = ? ORDER BY last_active DESC LIMIT 1",
                [$userId]
            );
            $lastPlatform = $lastDevice ? $lastDevice['platform'] : null;

            Database::execute(
                "INSERT INTO account_deletions (account_age_days, cycles_owned_count, cycles_member_count, last_platform, reason)
                 VALUES (?, ?, ?, ?, ?)",
                [$accountAge, $cyclesOwned, $cyclesMember, $lastPlatform, $reason]
            );

            AdminAuth::logAction('user.delete', 'user', $userId, [
                'name' => $user['name'],
                'phone' => $user['phone'],
                'reason' => $reason,
            ]);

            $firebaseUid = $user['firebase_uid'];
            Database::execute("DELETE FROM users WHERE id = ?", [$userId]);

            try {
                Auth::deleteFirebaseUser($firebaseUid);
            } catch (Exception $e) {
                error_log("Failed to delete Firebase user: " . $e->getMessage());
            }

            $this->success(null);
        }, 'user_delete');
    }
}

new UserDeleteApi();
