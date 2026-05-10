<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class AuditListApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $page = max(1, (int) ($this->getField('page') ?? 1));
            $pageSize = min(100, max(1, (int) ($this->getField('page_size') ?? 50)));
            $action = $this->getField('action');
            $adminId = $this->getField('admin_id');
            $dateFrom = $this->getField('date_from');
            $dateTo = $this->getField('date_to');
            $offset = ($page - 1) * $pageSize;

            $where = "1=1";
            $params = [];

            if ($action) {
                $where .= " AND aal.action LIKE ?";
                $params[] = "%{$action}%";
            }
            if ($adminId) {
                $where .= " AND aal.admin_id = ?";
                $params[] = (int) $adminId;
            }
            if ($dateFrom) {
                $where .= " AND aal.created_at >= ?";
                $params[] = $dateFrom;
            }
            if ($dateTo) {
                $where .= " AND aal.created_at <= ?";
                $params[] = $dateTo;
            }

            $total = (int) Database::fetchOne(
                "SELECT COUNT(*) c FROM admin_audit_log aal WHERE {$where}",
                $params
            )['c'];

            $items = Database::fetchAll(
                "SELECT aal.*, au.username AS admin_username
                 FROM admin_audit_log aal
                 LEFT JOIN admin_users au ON au.id = aal.admin_id
                 WHERE {$where}
                 ORDER BY aal.created_at DESC
                 LIMIT {$pageSize} OFFSET {$offset}",
                $params
            );

            $this->success([
                'items' => $items,
                'total' => $total,
                'page' => $page,
                'page_size' => $pageSize,
            ]);
        }, 'audit_list');
    }
}

new AuditListApi();
