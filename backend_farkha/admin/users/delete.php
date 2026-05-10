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

            $con = Database::getInstance();

            NotificationService::sendDataOnlyToUser($con, $userId, [
                'type' => 'force_logout',
                'title' => 'تم حذف حسابك',
                'body' => 'تم حذف حسابك من قبل الإدارة',
            ]);

            $con->beginTransaction();

            try {
                $stmt = $con->prepare("SELECT cycle_id, role FROM cycle_users WHERE user_id = ?");
                $stmt->execute([$userId]);
                $userCycles = $stmt->fetchAll();

                $cyclesOwned = 0;
                $cyclesMember = 0;
                foreach ($userCycles as $row) {
                    if ($row['role'] === 'owner') {
                        $cyclesOwned++;
                        CycleModel::deleteFull($con, (int) $row['cycle_id']);
                    } else {
                        $cyclesMember++;
                        $del = $con->prepare("DELETE FROM cycle_users WHERE cycle_id = ? AND user_id = ?");
                        $del->execute([(int) $row['cycle_id'], $userId]);
                    }
                }

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

                $con->commit();

                try {
                    Auth::deleteFirebaseUser($firebaseUid);
                } catch (Exception $e) {
                    error_log("Failed to delete Firebase user: " . $e->getMessage());
                }

                $this->success(null);
            } catch (Exception $e) {
                if ($con->inTransaction()) $con->rollBack();
                error_log('Admin user delete error: ' . $e->getMessage());
                $this->error('فشل حذف المستخدم: ' . $e->getMessage(), 500);
            }
        }, 'user_delete');
    }
}

new UserDeleteApi();
