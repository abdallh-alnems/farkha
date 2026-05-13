<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class DevicesListApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $page = max(1, (int) ($this->getField('page') ?? 1));
            $pageSize = min(100, max(1, (int) ($this->getField('page_size') ?? 20)));
            $offset = ($page - 1) * $pageSize;

            $platform = trim($this->getField('platform', ''));
            $activeDays = (int) ($this->getField('active_days') ?? 7);
            $q = trim($this->getField('q', ''));

            $where = ["1=1"];
            $params = [];

            if ($platform !== '' && in_array($platform, ['android', 'ios'], true)) {
                $where[] = "ud.platform = ?";
                $params[] = $platform;
            }

            if ($activeDays > 0) {
                $where[] = "ud.last_active >= NOW() - INTERVAL ? DAY";
                $params[] = $activeDays;
            }

            if ($q !== '') {
                $where[] = "(u.name LIKE ? OR u.phone LIKE ?)";
                $like = "%{$q}%";
                $params[] = $like;
                $params[] = $like;
            }

            $whereClause = implode(' AND ', $where);

            $total = (int) Database::fetchOne(
                "SELECT COUNT(*) c FROM user_devices ud
                 LEFT JOIN users u ON u.id = ud.user_id
                 WHERE {$whereClause}",
                $params
            )['c'];

            $items = Database::fetchAll(
                "SELECT ud.id, ud.platform, ud.device_id,
                        ud.last_active, ud.created_at,
                        ud.user_id, u.name AS user_name, u.phone AS user_phone
                 FROM user_devices ud
                 LEFT JOIN users u ON u.id = ud.user_id
                 WHERE {$whereClause}
                 ORDER BY ud.last_active DESC
                 LIMIT {$pageSize} OFFSET {$offset}",
                $params
            );

            $stats = [
                'total' => (int) Database::fetchOne("SELECT COUNT(*) c FROM user_devices")['c'],
                'android' => (int) Database::fetchOne("SELECT COUNT(*) c FROM user_devices WHERE platform='android'")['c'],
                'ios' => (int) Database::fetchOne("SELECT COUNT(*) c FROM user_devices WHERE platform='ios'")['c'],
                'active_7d' => (int) Database::fetchOne("SELECT COUNT(*) c FROM user_devices WHERE last_active >= NOW() - INTERVAL 7 DAY")['c'],
                'active_30d' => (int) Database::fetchOne("SELECT COUNT(*) c FROM user_devices WHERE last_active >= NOW() - INTERVAL 30 DAY")['c'],
            ];

            $this->success([
                'items' => $items,
                'total' => $total,
                'page' => $page,
                'page_size' => $pageSize,
                'total_pages' => (int) ceil($total / $pageSize),
                'stats' => $stats,
            ]);
        }, 'devices_list');
    }
}

new DevicesListApi();
