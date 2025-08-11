<?php

require_once __DIR__ . '/../core/BaseRepository.php';

/**
 * Suggestion Repository
 * Handles suggestion-related database operations
 */
class SuggestionRepository extends BaseRepository
{
    protected $table = 'suggestion';

    /**
     * Add new suggestion
     */
    public function addSuggestion($suggestionText)
    {
        $data = [
            'suggestion_text' => $suggestionText,
            'created_at' => date('Y-m-d H:i:s')
        ];
        
        return $this->create($data);
    }

    /**
     * Get recent suggestions
     */
    public function getRecentSuggestions($limit = 10)
    {
        return $this->findAll('*', 'created_at DESC', $limit);
    }

    /**
     * Get suggestions by date range
     */
    public function getSuggestionsByDateRange($startDate, $endDate)
    {
        $sql = "SELECT * FROM {$this->table} 
                WHERE created_at BETWEEN ? AND ? 
                ORDER BY created_at DESC";
        
        $stmt = $this->query($sql, [$startDate, $endDate]);
        return $stmt->fetchAll();
    }

    /**
     * Search suggestions
     */
    public function searchSuggestions($keyword)
    {
        $sql = "SELECT * FROM {$this->table} 
                WHERE suggestion_text LIKE ? 
                ORDER BY created_at DESC";
        
        $stmt = $this->query($sql, ["%{$keyword}%"]);
        return $stmt->fetchAll();
    }

    /**
     * Get suggestion statistics
     */
    public function getSuggestionStats()
    {
        $sql = "SELECT 
                    COUNT(*) as total_suggestions,
                    COUNT(CASE WHEN DATE(created_at) = CURDATE() THEN 1 END) as today_suggestions,
                    COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 1 END) as week_suggestions,
                    COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as month_suggestions
                FROM {$this->table}";
        
        $stmt = $this->query($sql);
        return $stmt->fetch();
    }
}
