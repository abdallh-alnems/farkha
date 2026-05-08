<?php

final class AnalyticsModel {
    public static function upsertToolsUsage(int $toolId): void {
        Database::execute(
            "INSERT INTO tools_usage (usage_date, tool_id, usage_count)
             VALUES (CURDATE(), ?, 1)
             ON DUPLICATE KEY UPDATE usage_count = usage_count + 1",
            [$toolId]
        );
    }

    public static function fetchUnifiedAnalytics(string $period): array {
        $interval = match ($period) {
            '7days' => '6 DAY',
            '30days' => '29 DAY',
            '1year' => '1 YEAR',
            default => null,
        };

        if ($interval) {
            return Database::fetchAll(
                "SELECT tool_id, SUM(usage_count) as total_usage
                 FROM tools_usage WHERE usage_date >= CURDATE() - INTERVAL {$interval}
                 GROUP BY tool_id ORDER BY total_usage DESC"
            );
        }

        return Database::fetchAll(
            "SELECT tool_id, SUM(usage_count) as total_usage
             FROM tools_usage GROUP BY tool_id ORDER BY total_usage DESC"
        );
    }
}
