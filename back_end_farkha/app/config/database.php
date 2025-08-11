<?php

/**
 * Database Configuration
 * Uses environment variables for security
 */

class DatabaseConfig
{
    private static $config = null;

    public static function getConfig()
    {
        if (self::$config === null) {
            self::$config = [
                'host' => $_ENV['DB_HOST'] ?? 'localhost',
                'database' => $_ENV['DB_NAME'] ?? 'farkha',
                'username' => $_ENV['DB_USER'] ?? 'root',
                'password' => $_ENV['DB_PASS'] ?? '',
                'charset' => 'utf8mb4',
                'options' => [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4"
                ]
            ];
        }
        return self::$config;
    }

    public static function getDsn()
    {
        $config = self::getConfig();
        return "mysql:host={$config['host']};dbname={$config['database']};charset={$config['charset']}";
    }
}
