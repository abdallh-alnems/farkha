<?php

require_once __DIR__ . '/../core/BaseRepository.php';

/**
 * Main Repository
 * Handles main category operations
 */
class MainRepository extends BaseRepository
{
    protected $table = 'main';

    /**
     * Get all main categories with their types
     */
    public function getMainWithTypes()
    {
        $sql = "SELECT 
                    m.main_id,
                    m.main_name,
                    t.type_id,
                    t.type_name
                FROM {$this->table} m
                LEFT JOIN types t ON m.main_id = t.main_type
                ORDER BY m.main_id, t.type_id";
        
        $stmt = $this->query($sql);
        return $stmt->fetchAll();
    }

    /**
     * Get main category by ID with types
     */
    public function getMainByIdWithTypes($mainId)
    {
        $sql = "SELECT 
                    m.main_id,
                    m.main_name,
                    t.type_id,
                    t.type_name
                FROM {$this->table} m
                LEFT JOIN types t ON m.main_id = t.main_type
                WHERE m.main_id = ?
                ORDER BY t.type_id";
        
        $stmt = $this->query($sql, [$mainId]);
        return $stmt->fetchAll();
    }

    /**
     * Get main categories statistics
     */
    public function getMainStats()
    {
        $sql = "SELECT 
                    m.main_id,
                    m.main_name,
                    COUNT(t.type_id) as types_count,
                    COUNT(p.price) as prices_count
                FROM {$this->table} m
                LEFT JOIN types t ON m.main_id = t.main_type
                LEFT JOIN prices p ON t.type_id = p.price_type
                GROUP BY m.main_id, m.main_name
                ORDER BY m.main_id";
        
        $stmt = $this->query($sql);
        return $stmt->fetchAll();
    }
}
