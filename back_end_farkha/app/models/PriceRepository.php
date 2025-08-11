<?php

require_once __DIR__ . '/../core/BaseRepository.php';

/**
 * Price Repository
 * Handles price-related database operations
 */
class PriceRepository extends BaseRepository
{
    protected $table = 'prices';

    /**
     * Get latest prices for specific type
     */
    public function getLatestPricesByType($typeId, $limit = 2)
    {
        $sql = "SELECT price FROM {$this->table} 
                WHERE price_type = ? 
                ORDER BY date_price DESC 
                LIMIT ?";
        
        $stmt = $this->query($sql, [$typeId, $limit]);
        return $stmt->fetchAll();
    }

    /**
     * Get feasibility study data
     */
    public function getFeasibilityStudyData()
    {
        $sql = "SELECT prices.price 
                FROM prices 
                WHERE prices.price_type IN (1, 3, 8, 9, 10) 
                AND prices.date_price = (
                    SELECT MAX(p2.date_price) 
                    FROM prices AS p2 
                    WHERE p2.price_type = prices.price_type
                ) 
                ORDER BY prices.price_type";
        
        $stmt = $this->query($sql);
        return $stmt->fetchAll();
    }

    /**
     * Get prices with types for specific main category
     */
    public function getPricesWithTypes($mainId)
    {
        $sql = "SELECT 
                    types.type_id AS type_id,
                    types.type_name AS type,
                    MAX(CASE WHEN ranked_prices.rank = 1 THEN ranked_prices.price END) AS price,
                    MAX(CASE WHEN ranked_prices.rank = 2 THEN ranked_prices.price END) AS lastPrice
                FROM main
                JOIN types ON main.main_id = types.main_type
                JOIN (
                    SELECT 
                        price_type, 
                        price, 
                        ROW_NUMBER() OVER (PARTITION BY price_type ORDER BY date_price DESC) AS rank
                    FROM prices
                ) AS ranked_prices ON types.type_id = ranked_prices.price_type
                WHERE main.main_id = ?
                GROUP BY types.type_id
                ORDER BY types.type_id";
        
        $stmt = $this->query($sql, [$mainId]);
        return $stmt->fetchAll();
    }

    /**
     * Get web prices for main categories
     */
    public function getWebPrices($mainIds = [1, 2, 3])
    {
        $placeholders = str_repeat('?,', count($mainIds) - 1) . '?';
        
        $sql = "SELECT
                    types.type_name AS type,
                    MAX(CASE WHEN ranked_prices.rank = 1 THEN ranked_prices.price END) AS price,
                    MAX(CASE WHEN ranked_prices.rank = 2 THEN ranked_prices.price END) AS lastPrice
                FROM main
                JOIN types ON main.main_id = types.main_type
                JOIN (
                    SELECT
                        price_type,
                        price,
                        ROW_NUMBER() OVER (PARTITION BY price_type ORDER BY date_price DESC) AS rank
                    FROM prices
                ) AS ranked_prices ON types.type_id = ranked_prices.price_type
                WHERE main.main_id IN ({$placeholders})
                GROUP BY types.type_name
                ORDER BY main.main_id, types.type_id";
        
        $stmt = $this->query($sql, $mainIds);
        return $stmt->fetchAll();
    }

    /**
     * Add new price
     */
    public function addPrice($price, $typeId)
    {
        $data = [
            'price' => $price,
            'price_type' => $typeId,
            'date_price' => date('Y-m-d H:i:s')
        ];
        
        return $this->create($data);
    }

    /**
     * Get price statistics
     */
    public function getPriceStatistics($typeId, $days = 30)
    {
        $sql = "SELECT 
                    AVG(price) as avg_price,
                    MIN(price) as min_price,
                    MAX(price) as max_price,
                    COUNT(*) as count
                FROM {$this->table} 
                WHERE price_type = ? 
                AND date_price >= DATE_SUB(NOW(), INTERVAL ? DAY)";
        
        $stmt = $this->query($sql, [$typeId, $days]);
        return $stmt->fetch();
    }
}
