<?php

require_once __DIR__ . '/../config/database.php';

/**
 * Database Connection Singleton
 */
class Database
{
    private static $instance = null;
    private $connection = null;

    private function __construct()
    {
        try {
            $config = DatabaseConfig::getConfig();
            $dsn = DatabaseConfig::getDsn();
            
            $this->connection = new PDO(
                $dsn,
                $config['username'],
                $config['password'],
                $config['options']
            );
        } catch (PDOException $e) {
            error_log("Database connection failed: " . $e->getMessage());
            throw new Exception("Database connection failed");
        }
    }

    public static function getInstance()
    {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function getConnection()
    {
        return $this->connection;
    }

    public function beginTransaction()
    {
        return $this->connection->beginTransaction();
    }

    public function commit()
    {
        return $this->connection->commit();
    }

    public function rollback()
    {
        return $this->connection->rollback();
    }

    // Prevent cloning
    private function __clone() {}

    // Prevent unserializing
    public function __wakeup()
    {
        throw new Exception("Cannot unserialize singleton");
    }
}
