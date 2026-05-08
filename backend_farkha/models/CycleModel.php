<?php

final class CycleModel {
    public static function create(PDO $con, array $data): int {
        $stmt = $con->prepare(
            "INSERT INTO cycles (name, owner_user_id, chick_count, space, breed, system_type, start_date_raw)
             VALUES (:name, :owner_user_id, :chick_count, :space, :breed, :system_type, :start_date_raw)"
        );
        $stmt->execute([
            ':name' => $data['name'],
            ':owner_user_id' => $data['owner_user_id'],
            ':chick_count' => $data['chick_count'],
            ':space' => $data['space'],
            ':breed' => $data['breed'],
            ':system_type' => $data['system_type'],
            ':start_date_raw' => $data['start_date_raw'],
        ]);
        return (int) $con->lastInsertId();
    }

    public static function addMember(PDO $con, int $cycleId, int $userId, string $role, string $status = 'accepted'): void {
        $stmt = $con->prepare(
            "INSERT INTO cycle_users (user_id, cycle_id, role, status) VALUES (:user_id, :cycle_id, :role, :status)"
        );
        $stmt->execute([
            ':user_id' => $userId,
            ':cycle_id' => $cycleId,
            ':role' => $role,
            ':status' => $status,
        ]);
    }

    public static function fetchUserCycles(int $userId): array {
        return Database::fetchAll(
            "SELECT c.id, c.name, c.owner_user_id, c.chick_count, c.system_type, c.start_date_raw, c.end_date_raw, cu.role,
                COALESCE(CAST((SELECT SUM(CAST(TRIM(cd2.value) AS DECIMAL(10,2))) FROM cycle_data cd2 WHERE cd2.cycle_id = c.id AND cd2.label = 'عدد النافق') AS UNSIGNED), 0) as mortality,
                COALESCE(CAST((SELECT SUM(ce2.value) FROM cycle_expenses ce2 WHERE ce2.cycle_id = c.id) AS UNSIGNED), 0) as total_expenses
            FROM cycles c
            INNER JOIN cycle_users cu ON c.id = cu.cycle_id
            WHERE cu.user_id = :user_id AND c.end_date_raw IS NULL AND cu.status = 'accepted' AND c.deleted_at IS NULL
            ORDER BY c.id DESC",
            [':user_id' => $userId]
        );
    }

    public static function fetchDetails(int $cycleId, int $userId): ?array {
        return Database::fetchOne(
            "SELECT c.*, cu.role FROM cycles c
             INNER JOIN cycle_users cu ON c.id = cu.cycle_id
             WHERE c.id = :cycle_id AND cu.user_id = :user_id AND cu.status = 'accepted' AND c.deleted_at IS NULL LIMIT 1",
            [':cycle_id' => $cycleId, ':user_id' => $userId]
        );
    }

    public static function fetchMembers(int $cycleId): array {
        return Database::fetchAll(
            "SELECT u.id, u.name, u.phone, cu.role, cu.status
             FROM cycle_users cu INNER JOIN users u ON cu.user_id = u.id
             WHERE cu.cycle_id = :cycle_id",
            [':cycle_id' => $cycleId]
        );
    }

    public static function checkReadAccess(int $cycleId, int $userId): ?array {
        return Database::fetchOne(
            "SELECT cu.role FROM cycle_users cu INNER JOIN cycles c ON cu.cycle_id = c.id WHERE cu.cycle_id = :cycle_id AND cu.user_id = :user_id AND cu.status = 'accepted' AND c.deleted_at IS NULL LIMIT 1",
            [':cycle_id' => $cycleId, ':user_id' => $userId]
        );
    }

    public static function checkWriteAccess(int $cycleId, int $userId): ?array {
        return Database::fetchOne(
            "SELECT cu.role FROM cycle_users cu INNER JOIN cycles c ON cu.cycle_id = c.id WHERE cu.cycle_id = :cycle_id AND cu.user_id = :user_id AND cu.status = 'accepted' AND cu.role IN ('owner', 'admin') AND c.deleted_at IS NULL LIMIT 1",
            [':cycle_id' => $cycleId, ':user_id' => $userId]
        );
    }

    public static function requireWriteAccess(PDO $con, int $cycleId, int $userId): array {
        $stmt = $con->prepare(
            "SELECT cu.role FROM cycle_users cu INNER JOIN cycles c ON cu.cycle_id = c.id WHERE cu.cycle_id = :cid AND cu.user_id = :uid AND cu.status = 'accepted' AND cu.role IN ('owner', 'admin') AND c.deleted_at IS NULL LIMIT 1"
        );
        $stmt->execute([':cid' => $cycleId, ':uid' => $userId]);
        $access = $stmt->fetch();
        if (!$access) {
            Response::fail('Access denied to this cycle', 403);
        }
        return $access;
    }

    public static function requireReadAccess(PDO $con, int $cycleId, int $userId): array {
        $stmt = $con->prepare(
            "SELECT cu.role FROM cycle_users cu INNER JOIN cycles c ON cu.cycle_id = c.id WHERE cu.cycle_id = :cid AND cu.user_id = :uid AND cu.status = 'accepted' AND c.deleted_at IS NULL LIMIT 1"
        );
        $stmt->execute([':cid' => $cycleId, ':uid' => $userId]);
        $access = $stmt->fetch();
        if (!$access) {
            Response::fail('Access denied to this cycle', 403);
        }
        return $access;
    }

    public static function deleteFull(PDO $con, int $cycleId): void {
        $con->prepare("DELETE FROM cycle_data WHERE cycle_id = ?")->execute([$cycleId]);
        $con->prepare("DELETE FROM cycle_expenses WHERE cycle_id = ?")->execute([$cycleId]);
        $con->prepare("DELETE FROM cycle_notes WHERE cycle_id = ?")->execute([$cycleId]);
        $con->prepare("DELETE FROM cycle_inventory WHERE cycle_id = ?")->execute([$cycleId]);
        $con->prepare("DELETE FROM cycle_sales WHERE cycle_id = ?")->execute([$cycleId]);
        $con->prepare("DELETE FROM cycle_users WHERE cycle_id = ?")->execute([$cycleId]);
        $con->prepare("UPDATE cycles SET deleted_at = NOW() WHERE id = ?")->execute([$cycleId]);
    }

    public static function update(PDO $con, int $cycleId, array $data): void {
        $fields = [];
        $params = [':id' => $cycleId];

        $allowed = ['name', 'chick_count', 'space', 'breed', 'system_type', 'start_date_raw'];

        foreach ($allowed as $col) {
            if (array_key_exists($col, $data)) {
                $fields[] = "{$col} = :{$col}";
                $params[":{$col}"] = $data[$col];
            }
        }

        if (empty($fields)) {
            return;
        }

        $sql = "UPDATE cycles SET " . implode(', ', $fields) . " WHERE id = :id";
        $stmt = $con->prepare($sql);
        $stmt->execute($params);
    }

    public static function updateStatus(PDO $con, int $cycleId, string $status, ?string $endDate = null): void {
        $end = ($status === 'finished') ? ($endDate ?? date('Y-m-d')) : null;
        $stmt = $con->prepare("UPDATE cycles SET end_date_raw = :end WHERE id = :id");
        $stmt->execute([':end' => $end, ':id' => $cycleId]);
    }

    public static function leave(PDO $con, int $cycleId, int $userId): void {
        $stmt = $con->prepare("DELETE FROM cycle_users WHERE cycle_id = :cid AND user_id = :uid");
        $stmt->execute([':cid' => $cycleId, ':uid' => $userId]);
    }

    public static function insertData(PDO $con, int $cycleId, string $label, string $value, string $metricType = 'other'): void {
        $numericValue = null;
        $textValue = null;
        if (is_numeric($value)) {
            $numericValue = (float) $value;
        } else {
            $textValue = $value;
        }

        $stmt = $con->prepare(
            "INSERT INTO cycle_data (cycle_id, metric_type, label, value, numeric_value, text_value)
             VALUES (:cid, :metric_type, :label, :value, :numeric_value, :text_value)"
        );
        $stmt->execute([
            ':cid' => $cycleId,
            ':metric_type' => $metricType,
            ':label' => $label,
            ':value' => $value,
            ':numeric_value' => $numericValue,
            ':text_value' => $textValue,
        ]);
    }

    public static function insertExpense(PDO $con, int $cycleId, string $label, float $value): void {
        $stmt = $con->prepare("INSERT INTO cycle_expenses (cycle_id, label, value) VALUES (:cid, :label, :value)");
        $stmt->execute([':cid' => $cycleId, ':label' => $label, ':value' => $value]);
    }

    public static function insertSale(PDO $con, int $cycleId, array $data): void {
        $stmt = $con->prepare(
            "INSERT INTO cycle_sales (cycle_id, quantity, total_weight, price_per_kg, total_price, sale_date)
             VALUES (:cid, :qty, :weight, :ppk, :total, :date)"
        );
        $stmt->execute([
            ':cid' => $cycleId,
            ':qty' => $data['quantity'],
            ':weight' => $data['total_weight'],
            ':ppk' => $data['price_per_kg'],
            ':total' => $data['total_price'],
            ':date' => $data['sale_date'],
        ]);
    }

    public static function fetchDataChronological(int $cycleId): array {
        return Database::fetchAll(
            "SELECT id, cycle_id, label, value, entry_date FROM cycle_data WHERE cycle_id = :cid ORDER BY entry_date ASC",
            [':cid' => $cycleId]
        );
    }

    public static function fetchExpensesChronological(int $cycleId): array {
        return Database::fetchAll(
            "SELECT id, cycle_id, label, value, entry_date FROM cycle_expenses WHERE cycle_id = :cid ORDER BY entry_date ASC",
            [':cid' => $cycleId]
        );
    }

    public static function fetchSales(int $cycleId): array {
        return Database::fetchAll(
            "SELECT * FROM cycle_sales WHERE cycle_id = :cid ORDER BY sale_date DESC",
            [':cid' => $cycleId]
        );
    }

    public static function fetchNotes(int $cycleId): array {
        return Database::fetchAll(
            "SELECT * FROM cycle_notes WHERE cycle_id = :cid ORDER BY entry_date DESC",
            [':cid' => $cycleId]
        );
    }

    public static function insertNote(PDO $con, int $cycleId, string $content): void {
        $stmt = $con->prepare("INSERT INTO cycle_notes (cycle_id, content) VALUES (:cid, :content)");
        $stmt->execute([':cid' => $cycleId, ':content' => $content]);
    }

    public static function deleteNote(PDO $con, int $noteId, int $cycleId): void {
        $stmt = $con->prepare("DELETE FROM cycle_notes WHERE id = :id AND cycle_id = :cid");
        $stmt->execute([':id' => $noteId, ':cid' => $cycleId]);
    }

    public static function updateNote(PDO $con, int $noteId, int $cycleId, string $content): void {
        $stmt = $con->prepare("UPDATE cycle_notes SET content = :content WHERE id = :id AND cycle_id = :cid");
        $stmt->execute([':content' => $content, ':id' => $noteId, ':cid' => $cycleId]);
    }

    public static function fetchInventorySummary(int $cycleId): array {
        return Database::fetchAll(
            "SELECT item_name, category, unit,
                SUM(CASE WHEN transaction_type = 'in' THEN quantity ELSE 0 END) as total_in,
                SUM(CASE WHEN transaction_type = 'out' THEN quantity ELSE 0 END) as total_out,
                SUM(CASE WHEN transaction_type = 'in' THEN quantity ELSE -quantity END) as remaining
            FROM cycle_inventory WHERE cycle_id = :cid
            GROUP BY item_name, category, unit ORDER BY item_name ASC",
            [':cid' => $cycleId]
        );
    }

    public static function fetchUserInvitations(int $userId): array {
        return Database::fetchAll(
            "SELECT c.id as cycle_id, c.name as cycle_name, c.start_date_raw, cu.role, u_owner.name as inviter_name
            FROM cycles c
            INNER JOIN cycle_users cu ON c.id = cu.cycle_id
            INNER JOIN cycle_users cu_owner ON c.id = cu_owner.cycle_id AND cu_owner.role = 'owner'
            INNER JOIN users u_owner ON cu_owner.user_id = u_owner.id
            WHERE cu.user_id = :uid AND cu.status = 'pending' AND c.deleted_at IS NULL ORDER BY c.created_at DESC",
            [':uid' => $userId]
        );
    }

    public static function acceptInvitation(PDO $con, int $cycleId, int $userId): void {
        $stmt = $con->prepare("UPDATE cycle_users SET status = 'accepted' WHERE cycle_id = :cid AND user_id = :uid AND status = 'pending'");
        $stmt->execute([':cid' => $cycleId, ':uid' => $userId]);
    }

    public static function rejectInvitation(PDO $con, int $cycleId, int $userId): void {
        $stmt = $con->prepare("DELETE FROM cycle_users WHERE cycle_id = :cid AND user_id = :uid AND status = 'pending'");
        $stmt->execute([':cid' => $cycleId, ':uid' => $userId]);
    }

    public static function createInvitation(PDO $con, int $cycleId, string $code, int $createdByUserId): void {
        $stmt = $con->prepare(
            "INSERT INTO cycle_invitations (cycle_id, created_by_user_id, code, status, expires_at) VALUES (:cid, :creator, :code, 'active', DATE_ADD(NOW(), INTERVAL 7 DAY))"
        );
        $stmt->execute([':cid' => $cycleId, ':creator' => $createdByUserId, ':code' => $code]);
    }

    public static function fetchHistoryCycles(PDO $con, int $userId, int $limit, int $offset, ?string $search = null, ?string $dateFrom = null, ?string $dateTo = null): array {
        $where = "cu.user_id = :uid AND c.end_date_raw IS NOT NULL AND cu.status = 'accepted' AND c.deleted_at IS NULL";
        $params = [':uid' => $userId, ':limit' => $limit, ':offset' => $offset];

        if ($search) {
            $where .= " AND c.name LIKE :search";
            $params[':search'] = "%{$search}%";
        }
        if ($dateFrom) {
            $where .= " AND DATE(c.start_date_raw) >= :df";
            $params[':df'] = $dateFrom;
        }
        if ($dateTo) {
            $where .= " AND DATE(c.start_date_raw) <= :dt";
            $params[':dt'] = $dateTo;
        }

        $stmt = $con->prepare(
            "SELECT c.id, c.name, c.chick_count, c.space, c.breed, c.system_type, c.start_date_raw, c.end_date_raw, cu.role,
                COALESCE(CAST((SELECT SUM(CAST(TRIM(cd2.value) AS DECIMAL(10,2))) FROM cycle_data cd2 WHERE cd2.cycle_id = c.id AND cd2.label = 'عدد النافق') AS UNSIGNED), 0) as mortality,
                COALESCE(CAST((SELECT SUM(ce2.value) FROM cycle_expenses ce2 WHERE ce2.cycle_id = c.id) AS UNSIGNED), 0) as total_expenses,
                COALESCE(CAST((SELECT SUM(CAST(TRIM(cd2.value) AS DECIMAL(10,2))) FROM cycle_data cd2 WHERE cd2.cycle_id = c.id AND cd2.label = 'استهلاك العلف') AS UNSIGNED), 0) as total_feed,
                COALESCE(CAST((SELECT cd3.value FROM cycle_data cd3 WHERE cd3.cycle_id = c.id AND cd3.label = 'متوسط وزن القطيع' ORDER BY cd3.entry_date DESC LIMIT 1) AS DECIMAL(10,3)), 0) as average_weight,
                COALESCE((SELECT SUM(total_price) FROM cycle_sales cs2 WHERE cs2.cycle_id = c.id), 0) as total_sales
            FROM cycles c INNER JOIN cycle_users cu ON c.id = cu.cycle_id
            WHERE {$where} ORDER BY c.end_date_raw DESC, c.id DESC LIMIT :limit OFFSET :offset"
        );
        $stmt->execute($params);
        return $stmt->fetchAll();
    }
}
