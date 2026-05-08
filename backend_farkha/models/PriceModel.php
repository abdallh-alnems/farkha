<?php

final class PriceModel {
    public static function fetchFeasibilityStudy(): array {
        return Database::fetchAll("
            SELECT t.name,
                CASE WHEN gp.lower IS NULL OR gp.lower = 0 THEN gp.higher
                     ELSE ROUND((gp.higher + gp.lower) / 2, 0) END AS price
            FROM prices gp
            INNER JOIN (SELECT type, MAX(date) AS max_date FROM prices WHERE type IN (1,18,41,42,43) GROUP BY type) latest
                ON gp.type = latest.type AND gp.date = latest.max_date
            JOIN types t ON t.id = gp.type
            ORDER BY gp.type
        ");
    }

    public static function fetchLatestByType(int $type): ?array {
        return Database::fetchOne("
            SELECT t.name,
                CASE WHEN gp.lower IS NULL OR gp.lower = 0 THEN gp.higher
                     ELSE ROUND((gp.higher + gp.lower) / 2, 0) END AS price,
                gp.date, gp.higher, gp.lower
            FROM prices gp
            JOIN types t ON t.id = gp.type
            WHERE gp.type = :type
            ORDER BY gp.date DESC LIMIT 1
        ", [':type' => $type]);
    }

    public static function fetchStream(array $typeIds): array {
        $typeFilter = '';
        $params = [];
        if (!empty($typeIds)) {
            $placeholders = implode(',', array_map(fn($i) => ":t{$i}", array_keys($typeIds)));
            $typeFilter = "WHERE type IN ({$placeholders})";
            foreach ($typeIds as $i => $id) {
                $params[":t{$i}"] = $id;
            }
        }

        return Database::fetchAll("
            WITH latest_prices AS (
                SELECT type, MAX(date) as max_date FROM prices {$typeFilter} GROUP BY type
            ),
            previous_prices AS (
                SELECT gp1.type, MAX(gp1.date) as prev_date
                FROM prices gp1 INNER JOIN latest_prices lp ON gp1.type = lp.type
                WHERE gp1.date < lp.max_date GROUP BY gp1.type
            )
            SELECT today.higher AS higher_today, today.lower AS lower_today,
                   yesterday.higher AS higher_yesterday, yesterday.lower AS lower_yesterday,
                   t.name, t.id
            FROM latest_prices lp
            INNER JOIN prices today ON today.type = lp.type AND today.date = lp.max_date
            LEFT JOIN previous_prices pp ON pp.type = lp.type
            LEFT JOIN prices yesterday ON yesterday.type = pp.type AND yesterday.date = pp.prev_date
            INNER JOIN types t ON today.type = t.id
            ORDER BY t.id
        ", $params);
    }

    public static function fetchByMainType(int $mainType): array {
        return Database::fetchAll("
            SELECT t.id AS type_id, gp_today.higher AS today_higher_price, gp_today.lower AS today_lower_price,
                   gp_yesterday.higher AS yesterday_higher_price, gp_yesterday.lower AS yesterday_lower_price,
                   t.name AS type_name
            FROM types t
            LEFT JOIN prices gp_today ON gp_today.type = t.id AND gp_today.date = (SELECT MAX(gp1.date) FROM prices gp1 WHERE gp1.type = t.id)
            LEFT JOIN prices gp_yesterday ON gp_yesterday.type = t.id AND gp_yesterday.date = (
                SELECT MAX(gp2.date) FROM prices gp2 WHERE gp2.type = t.id AND gp2.date < (SELECT MAX(gp3.date) FROM prices gp3 WHERE gp3.type = t.id)
            )
            WHERE t.category_id = ?
        ", [$mainType]);
    }

    public static function fetchToday(int $mainType): array {
        return Database::fetchAll("
            SELECT DISTINCT t.id, gp_today.higher, gp_today.lower, t.name
            FROM types t
            LEFT JOIN prices gp_today ON gp_today.type = t.id AND gp_today.date = (SELECT MAX(gp1.date) FROM prices gp1 WHERE gp1.type = t.id)
            WHERE t.category_id = ? ORDER BY t.id
        ", [$mainType]);
    }

    public static function insert(float $higher, ?float $lower, int $type): int {
        return Database::execute(
            "INSERT INTO prices (higher, lower, type) VALUES (:higher, :lower, :type)",
            [':higher' => $higher, ':lower' => $lower, ':type' => $type]
        );
    }

    public static function updateLatest(int $type, float $higher, ?float $lower): int {
        return Database::execute(
            "UPDATE prices SET higher = :higher, lower = :lower
             WHERE type = :type AND date = (SELECT max_date FROM (SELECT MAX(p2.date) as max_date FROM prices p2 WHERE p2.type = :type2) as subquery)",
            [':higher' => $higher, ':lower' => $lower, ':type' => $type, ':type2' => $type]
        );
    }

    public static function deleteLatest(int $type): int {
        return Database::execute(
            "DELETE FROM prices WHERE type = :type AND date = (SELECT max_date FROM (SELECT MAX(p2.date) as max_date FROM prices p2 WHERE p2.type = :type2) as subquery)
             AND EXISTS (SELECT 1 FROM types t WHERE t.id = :type3)",
            [':type' => $type, ':type2' => $type, ':type3' => $type]
        );
    }

    public static function fetchHistoryByType(int $type, int $limit = 30, ?string $beforeDate = null): array {
        $limit = max(1, min(1000, $limit));
        if ($beforeDate) {
            return Database::fetchAll(
                "SELECT date, higher, lower FROM prices WHERE type = :type AND date < :before ORDER BY date DESC LIMIT {$limit}",
                [':type' => $type, ':before' => $beforeDate]
            );
        }
        return Database::fetchAll(
            "SELECT date, higher, lower FROM prices WHERE type = :type ORDER BY date DESC LIMIT {$limit}",
            [':type' => $type]
        );
    }
}
