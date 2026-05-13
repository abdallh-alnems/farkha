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

            $con->beginTransaction();

            try {
                $stmt = $con->prepare("SELECT cycle_id, role FROM cycle_users WHERE user_id = ?");
                $stmt->execute([$userId]);
                $userCycles = $stmt->fetchAll();

                foreach ($userCycles as $row) {
                    if ($row['role'] === 'owner') {
                        CycleModel::deleteFull($con, (int) $row['cycle_id']);
                    }
                }

                $con->prepare("DELETE FROM cycle_users WHERE user_id = ?")->execute([$userId]);

                AdminAuth::logAction('user.delete', 'user', $userId, [
                    'name' => $user['name'],
                    'phone' => $user['phone'],
                    'reason' => $reason,
                ]);

                try {
                    NotificationService::sendDataOnlyToUser($con, $userId, [
                        'type' => 'force_logout',
                    ]);
                } catch (Exception $ne) {
                    error_log('Force logout notification error: ' . $ne->getMessage());
                }

                $firebaseUid = $user['firebase_uid'];

                $deleteStmt = $con->prepare("DELETE FROM users WHERE id = ?");
                $deleteStmt->execute([$userId]);

                $con->commit();

                if (!empty($firebaseUid)) {
                    Auth::deleteFirebaseUser($firebaseUid);
                }

                $this->success(null);
            } catch (Exception $e) {
                if ($con->inTransaction()) $con->rollBack();
                error_log('Admin user delete error: ' . $e->getMessage());
                $this->error('فشل حذف المستخدم. يرجى المحاولة لاحقاً.', 500);
            }
        }, 'user_delete');
    }
}

new UserDeleteApi();
