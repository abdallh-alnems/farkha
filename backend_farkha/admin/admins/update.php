<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class AdminUpdateApi extends AdminBaseApi {
    protected ?string $minRole = 'superadmin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $id = (int) $this->requireNumeric('id', 1);

            $target = Database::fetchOne(
                "SELECT id, username, role FROM admin_users WHERE id = ? LIMIT 1",
                [$id]
            );
            if (!$target) {
                $this->error('المستخدم غير موجود', 404);
            }

            $currentAdmin = AdminAuth::currentAdmin();
            if ((int) $currentAdmin['admin_id'] === $id) {
                $this->error('لا يمكنك تعديل حسابك من هنا', 400);
            }

            $isActive = $this->getField('is_active');
            $role = $this->getField('role');
            $displayName = $this->getField('display_name');
            $password = $this->getField('password');

            $updates = [];
            $params = [];

            if ($isActive !== null) {
                $updates[] = 'is_active = ?';
                $params[] = (int) $isActive;
            }

            if ($role !== null) {
                $validRoles = ['readonly', 'admin', 'superadmin'];
                if (!in_array($role, $validRoles)) {
                    $this->error('الصلاحية غير صالحة', 400);
                }
                $updates[] = 'role = ?';
                $params[] = $role;
            }

            if ($displayName !== null) {
                $updates[] = 'display_name = ?';
                $params[] = trim($displayName);
            }

            if ($password !== null && strlen($password) >= 6) {
                $updates[] = 'password_hash = ?';
                $params[] = password_hash($password, PASSWORD_BCRYPT);
            }

            if (empty($updates)) {
                $this->error('لا توجد بيانات للتحديث', 400);
            }

            $params[] = $id;
            Database::execute(
                "UPDATE admin_users SET " . implode(', ', $updates) . " WHERE id = ?",
                $params
            );

            if ($isActive !== null && !(int) $isActive) {
                Database::execute("DELETE FROM admin_sessions WHERE admin_id = ?", [$id]);
            }

            AdminAuth::logAction('admin.update', 'admin_user', $id, [
                'updates' => array_map(function ($u) use ($params) {
                    return $u;
                }, $updates),
            ]);

            $this->success(null);
        }, 'admin_update');
    }
}

new AdminUpdateApi();
