<?php
/**
 * SQL Queries Library
 * Contains all SQL queries used across the API endpoints
 * This file can be included in other API files to centralize query management
 */

class Queries {
    
    /**
     * Get unified feasibility study query for all prices
     */
    public static function getFeasibilityStudyPrices($types) {
        return "
            SELECT 
                t.name,
                CASE 
                    WHEN gp.type IN (50, 51, 52) THEN gp.higher
                    ELSE ROUND((gp.higher + gp.lower) / 2, 0)
                END AS price
            FROM prices gp
            INNER JOIN (
                SELECT type, MAX(date) AS max_date
                FROM prices
                WHERE type IN ($types)
                GROUP BY type
            ) latest 
                ON gp.type = latest.type
               AND gp.date = latest.max_date
            JOIN types t 
                ON t.id = gp.type
        ";
    }
    
    /**
     * Get prices stream query with CTE for better performance
     */
    public static function getPricesStreamQuery($whereClause = "") {
        return "
            WITH latest_prices AS (
                SELECT 
                    type,
                    MAX(date) as max_date
                FROM prices
                GROUP BY type
            ),
            previous_prices AS (
                SELECT 
                    gp1.type,
                    MAX(gp1.date) as prev_date
                FROM prices gp1
                INNER JOIN latest_prices lp ON gp1.type = lp.type
                WHERE gp1.date < lp.max_date
                GROUP BY gp1.type
            )
            SELECT
                today.higher AS higher_today,
                today.lower AS lower_today,
                yesterday.higher AS higher_yesterday,
                yesterday.lower AS lower_yesterday,
                t.name,
                t.id
            FROM latest_prices lp
            INNER JOIN prices today 
                ON today.type = lp.type 
                AND today.date = lp.max_date
            LEFT JOIN previous_prices pp 
                ON pp.type = lp.type
            LEFT JOIN prices yesterday 
                ON yesterday.type = pp.type 
                AND yesterday.date = pp.prev_date
            INNER JOIN types t ON today.type = t.id
            $whereClause
            ORDER BY t.id
        ";
    }
 

    public static function getPricesByTypeQuery() {
        return "
            SELECT 
                gp_today.higher AS today_higher_price,
                gp_today.lower AS today_lower_price,
                gp_yesterday.higher AS yesterday_higher_price,
                gp_yesterday.lower AS yesterday_lower_price,
                t.name AS type_name

            FROM types t
            LEFT JOIN prices gp_today 
                ON gp_today.type = t.id
                AND gp_today.date = (
                    SELECT MAX(gp1.date) 
                    FROM prices gp1 
                    WHERE gp1.type = t.id
                )
            LEFT JOIN prices gp_yesterday 
                ON gp_yesterday.type = t.id
                AND gp_yesterday.date = (
                    SELECT MAX(gp2.date) 
                    FROM prices gp2 
                    WHERE gp2.type = t.id 
                      AND gp2.date < (
                          SELECT MAX(gp3.date) 
                          FROM prices gp3 
                          WHERE gp3.type = t.id
                      )
                )
            WHERE t.main = ?
        ";
    }
    
  
    public static function getFeedPricesQuery() {
        return "
            SELECT 
                fp_today.prices AS today_price,
                fp_yesterday.prices AS yesterday_price,
                t.name AS type_name
            FROM types t
            LEFT JOIN feed_prices fp_today 
                ON fp_today.type = t.id
                AND fp_today.date = (
                    SELECT MAX(fp1.date) 
                    FROM feed_prices fp1 
                    WHERE fp1.type = t.id
                )
            LEFT JOIN feed_prices fp_yesterday 
                ON fp_yesterday.type = t.id
                AND fp_yesterday.date = (
                    SELECT MAX(fp2.date) 
                    FROM feed_prices fp2 
                    WHERE fp2.type = t.id 
                    AND fp2.date < (
                        SELECT MAX(fp3.date) 
                        FROM feed_prices fp3 
                        WHERE fp3.type = t.id
                    )
                )
            WHERE t.main = ?
        ";
    }
    
    
    public static function getMainCategoriesQuery() {
        return "SELECT * FROM `main`";
    }
    
    
    public static function getTypesListQuery() {
        return "
            SELECT 
                t.id,
                t.name,
                m.name AS type_main_name
            FROM types t
            JOIN main m ON t.main = m.id
            WHERE m.id NOT IN (6, 7)
            ORDER BY t.id
        ";
    }
    
   
    public static function buildTypeFilterWhereClause($typeIds) {
        if (empty($typeIds)) {
            return "";
        }
        
        $placeholders = str_repeat('?,', count($typeIds) - 1) . '?';
        return "WHERE t.id IN ($placeholders)";
    }
    


    /**
     * Get tools usage record query
     */
    public static function getToolsUsageRecordQuery() {
        return "SELECT usage_count FROM tools_usage 
                WHERE usage_date = CURRENT_DATE AND tool_id = ?";
    }
    
    /**
     * Update tools usage count query
     */
    public static function updateToolsUsageCountQuery() {
        return "UPDATE tools_usage 
                SET usage_count = usage_count + 1 
                WHERE usage_date = CURRENT_DATE AND tool_id = ?";
    }
    public static function insertToolsUsageRecordQuery() {
        return "INSERT INTO tools_usage (usage_date, tool_id, usage_count)
                VALUES (CURRENT_DATE, ?, 1)";
    }
    
    /**
     * Get tools usage analytics for last 7 days
     */
    public static function getToolsUsage7DaysQuery() {
        return "SELECT tool_id, SUM(usage_count) AS total_usage
                FROM tools_usage
                WHERE usage_date >= CURDATE() - INTERVAL 6 DAY
                GROUP BY tool_id
                ORDER BY total_usage DESC";
    }
    
    /**
     * Get tools usage analytics for last 30 days
     */
    public static function getToolsUsage30DaysQuery() {
        return "SELECT tool_id, SUM(usage_count) AS total_usage
                FROM tools_usage
                WHERE usage_date >= CURDATE() - INTERVAL 29 DAY
                GROUP BY tool_id
                ORDER BY total_usage DESC";
    }
    
    /**
     * Get tools usage analytics for last year
     */
    public static function getToolsUsage1YearQuery() {
        return "SELECT tool_id, SUM(usage_count) AS total_usage
                FROM tools_usage
                WHERE usage_date >= CURDATE() - INTERVAL 1 YEAR
                GROUP BY tool_id
                ORDER BY total_usage DESC";
    }
    
    /**
     * Get tools usage analytics for all time
     */
    public static function getToolsUsageAllTimeQuery() {
        return "SELECT tool_id, SUM(usage_count) AS total_usage
                FROM tools_usage
                GROUP BY tool_id
                ORDER BY total_usage DESC";
    }
    
    /**
     * Get today prices query
     */
    public static function getTodayPricesQuery() {
        return "
            SELECT DISTINCT
                t.id,
                gp_today.higher,
                gp_today.lower,
                t.name
            FROM types t
            LEFT JOIN prices gp_today 
                ON gp_today.type = t.id
                AND gp_today.date = (
                    SELECT MAX(gp1.date) 
                    FROM prices gp1 
                    WHERE gp1.type = t.id
                )
            WHERE t.main = ?
            ORDER BY t.id
        ";
    }
    
}



?>


