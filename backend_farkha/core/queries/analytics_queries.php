<?php

final class AnalyticsQueries {
    public static function upsertToolsUsage(): string {
        return "INSERT INTO tools_usage (usage_date, tool_id, usage_count)
                VALUES (CURRENT_DATE, ?, 1)
                ON DUPLICATE KEY UPDATE usage_count = usage_count + 1";
    }

    public static function fetchUnifiedToolsUsageAnalytics(): string {
        return "
            SELECT 
                tool_id,
                SUM(CASE WHEN usage_date >= CURDATE() - INTERVAL 6 DAY THEN usage_count ELSE 0 END) AS usage_7days,
                SUM(CASE WHEN usage_date >= CURDATE() - INTERVAL 29 DAY THEN usage_count ELSE 0 END) AS usage_30days,
                SUM(CASE WHEN usage_date >= CURDATE() - INTERVAL 1 YEAR THEN usage_count ELSE 0 END) AS usage_1year,
                SUM(usage_count) AS usage_alltime
            FROM tools_usage
            GROUP BY tool_id
            ORDER BY usage_alltime DESC
        ";
    }
}

?>


