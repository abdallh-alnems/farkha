<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class DbTablePreviewApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    private const ALLOWED_TABLES = [
        'users', 'user_devices', 'cycles', 'cycle_users', 'cycle_data',
        'cycle_expenses', 'cycle_sales', 'cycle_inventory', 'cycle_invitations',
        'cycle_notes', 'cycle_feedbacks', 'app_reviews', 'types',
        'product_categories', 'articles',
        'phone_verifications', 'admin_users', 'admin_sessions', 'admin_audit_log',
    ];

    private const SENSITIVE_COLUMNS = [
        'admin_users' => ['password_hash', 'last_login_ip'],
        'admin_sessions' => ['token_hash', 'ip', 'user_agent'],
        'users' => ['firebase_uid'],
        'user_devices' => ['fcm_token'],
    ];

    private static function stripSensitive(string $table, array $rows): array {
        $cols = self::SENSITIVE_COLUMNS[$table] ?? [];
        if (empty($cols)) return $rows;
        return array_map(function ($row) use ($cols) {
            foreach ($cols as $c) {
                unset($row[$c]);
            }
            return $row;
        }, $rows);
    }

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $table = trim($this->getField('table', ''));
            $limit = min(100, max(1, (int) ($this->getField('limit') ?? 50)));
            $offset = max(0, (int) ($this->getField('offset') ?? 0));

            if (!in_array($table, self::ALLOWED_TABLES, true)) {
                $this->error('Table not allowed for preview', 403);
            }

            $rows = Database::fetchAll(
                "SELECT * FROM `{$table}` ORDER BY 1 DESC LIMIT {$limit} OFFSET {$offset}"
            );

            $rows = self::stripSensitive($table, $rows);

            $total = (int) Database::fetchOne("SELECT COUNT(*) c FROM `{$table}`")['c'];

            $this->success([
                'table' => $table,
                'rows' => $rows,
                'total' => $total,
                'limit' => $limit,
                'offset' => $offset,
            ]);
        }, 'db_table_preview');
    }
}

new DbTablePreviewApi();
