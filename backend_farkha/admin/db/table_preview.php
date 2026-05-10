<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class DbTablePreviewApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    private const ALLOWED_TABLES = [
        'users', 'user_devices', 'cycles', 'cycle_users', 'cycle_data',
        'cycle_expenses', 'cycle_sales', 'cycle_inventory', 'cycle_invitations',
        'cycle_notes', 'cycle_feedbacks', 'app_reviews', 'prices', 'types',
        'product_categories', 'articles', 'tools_usage', 'tools_usage_events',
        'phone_verifications', 'account_deletions', 'admin_users', 'admin_sessions', 'admin_audit_log',
    ];

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
