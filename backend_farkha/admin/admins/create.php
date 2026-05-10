<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class AdminCreateApi extends AdminBaseApi {
    protected ?string $minRole = 'superadmin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $username = trim($this->getField('username', ''));
            $password = $this->getField('password', '');
            $displayName = trim($this->getField('display_name', ''));
            $role = trim($this->getField('role', 'readonly'));

            if (empty($username) || empty($password)) {
                $this->error('اسم المستخدم وكلمة المرور مطلوبان', 400);
            }

            if (strlen($username) < 3 || strlen($username) > 50) {
                $this->error('اسم المستخدم يجب أن يكون بين 3 و 50 حرف', 400);
            }

            if (strlen($password) < 6) {
                $this->error('كلمة المرور يجب أن تكون 6 أحرف على الأقل', 400);
            }

            $validRoles = ['readonly', 'admin', 'superadmin'];
            if (!in_array($role, $validRoles)) {
                $this->error('الصلاحية غير صالحة', 400);
            }

            $exists = Database::fetchOne(
                "SELECT id FROM admin_users WHERE username = ? LIMIT 1",
                [$username]
            );
            if ($exists) {
                $this->error('اسم المستخدم موجود بالفعل', 409);
            }

            $hash = password_hash($password, PASSWORD_BCRYPT);

            Database::execute(
                "INSERT INTO admin_users (username, password_hash, display_name, role, is_active) VALUES (?, ?, ?, ?, 1)",
                [$username, $hash, $displayName ?: $username, $role]
            );

            $newId = Database::lastInsertId();

            AdminAuth::logAction('admin.create', 'admin_user', $newId, [
                'username' => $username,
                'display_name' => $displayName,
                'role' => $role,
            ]);

            $this->success([
                'id' => (int) $newId,
                'username' => $username,
                'display_name' => $displayName ?: $username,
                'role' => $role,
            ]);
        }, 'admin_create');
    }
}

new AdminCreateApi();
