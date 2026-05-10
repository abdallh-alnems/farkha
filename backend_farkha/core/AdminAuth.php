<?php

final class AdminAuth {
    private const TOKEN_LIFETIME_HOURS = 12;

    public static function require(?string $minRole = null): array {
        $token = self::extractBearerToken();
        if (!$token) {
            Response::fail('Admin token required', 401);
        }

        $hash = hash('sha256', $token);
        $row = Database::fetchOne(
            "SELECT s.admin_id, s.expires_at, a.role, a.username, a.is_active, a.display_name
             FROM admin_sessions s JOIN admin_users a ON a.id = s.admin_id
             WHERE s.token_hash = ? LIMIT 1",
            [$hash]
        );

        if (!$row) {
            Response::fail('Invalid admin token', 401);
        }
        if (!$row['is_active']) {
            Response::fail('Admin account disabled', 403);
        }
        if (strtotime($row['expires_at']) < time()) {
            Database::execute("DELETE FROM admin_sessions WHERE token_hash = ?", [$hash]);
            Response::fail('Session expired', 401);
        }

        if ($minRole && !self::roleSufficient($row['role'], $minRole)) {
            Response::fail('Insufficient permissions', 403);
        }

        Database::execute(
            "UPDATE admin_sessions SET last_used_at = NOW() WHERE token_hash = ?",
            [$hash]
        );

        $GLOBALS['current_admin'] = $row;
        return $row;
    }

    public static function login(string $username, string $password, string $ip, string $ua): array {
        $admin = Database::fetchOne(
            "SELECT id, password_hash, role, display_name, is_active FROM admin_users WHERE username = ? LIMIT 1",
            [$username]
        );

        if (!$admin || !$admin['is_active'] || !password_verify($password, $admin['password_hash'])) {
            Response::fail('Invalid credentials', 401);
        }

        $token = bin2hex(random_bytes(32));
        $hash = hash('sha256', $token);
        $expires = date('Y-m-d H:i:s', time() + self::TOKEN_LIFETIME_HOURS * 3600);

        Database::execute(
            "INSERT INTO admin_sessions (admin_id, token_hash, expires_at, ip, user_agent) VALUES (?,?,?,?,?)",
            [$admin['id'], $hash, $expires, $ip, substr($ua, 0, 255)]
        );

        Database::execute(
            "UPDATE admin_users SET last_login_at = NOW(), last_login_ip = ? WHERE id = ?",
            [$ip, $admin['id']]
        );

        self::logAction('auth.login', 'admin_user', $admin['id']);

        return [
            'token' => $token,
            'expires_at' => $expires,
            'admin' => [
                'id' => (int) $admin['id'],
                'username' => $username,
                'display_name' => $admin['display_name'],
                'role' => $admin['role'],
            ],
        ];
    }

    public static function logout(): void {
        $token = self::extractBearerToken();
        if ($token) {
            $hash = hash('sha256', $token);
            Database::execute("DELETE FROM admin_sessions WHERE token_hash = ?", [$hash]);
            $admin = $GLOBALS['current_admin'] ?? null;
            if ($admin) {
                $GLOBALS['current_admin'] = $admin;
                self::logAction('auth.logout');
            }
        }
    }

    public static function logAction(string $action, ?string $targetType = null, $targetId = null, ?array $payload = null): void {
        $admin = $GLOBALS['current_admin'] ?? null;
        try {
            Database::execute(
                "INSERT INTO admin_audit_log (admin_id, action, target_type, target_id, payload, ip) VALUES (?,?,?,?,?,?)",
                [
                    $admin['admin_id'] ?? null,
                    $action,
                    $targetType,
                    $targetId !== null ? (string) $targetId : null,
                    $payload ? json_encode($payload, JSON_UNESCAPED_UNICODE) : null,
                    $_SERVER['REMOTE_ADDR'] ?? null,
                ]
            );
        } catch (Exception $e) {
            error_log("Audit log failed: " . $e->getMessage());
        }
    }

    public static function currentAdmin(): ?array {
        return $GLOBALS['current_admin'] ?? null;
    }

    private static function extractBearerToken(): ?string {
        $h = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
        if (preg_match('/Bearer\s+(.+)/i', $h, $m)) {
            return trim($m[1]);
        }
        return null;
    }

    private static function roleSufficient(string $actual, string $required): bool {
        $rank = ['readonly' => 1, 'admin' => 2, 'superadmin' => 3];
        return ($rank[$actual] ?? 0) >= ($rank[$required] ?? 0);
    }
}
