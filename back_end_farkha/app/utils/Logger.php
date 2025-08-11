<?php

/**
 * Simple Logger Class
 * Handles application logging
 */
class Logger
{
    private static $logFile = null;

    /**
     * Initialize logger
     */
    private static function init()
    {
        if (self::$logFile === null) {
            $logDir = __DIR__ . '/../../logs';
            if (!is_dir($logDir)) {
                mkdir($logDir, 0755, true);
            }
            self::$logFile = $logDir . '/app.log';
        }
    }

    /**
     * Log info message
     */
    public static function info($message, $context = [])
    {
        self::log('INFO', $message, $context);
    }

    /**
     * Log warning message
     */
    public static function warning($message, $context = [])
    {
        self::log('WARNING', $message, $context);
    }

    /**
     * Log error message
     */
    public static function error($message, $context = [])
    {
        self::log('ERROR', $message, $context);
    }

    /**
     * Log debug message
     */
    public static function debug($message, $context = [])
    {
        self::log('DEBUG', $message, $context);
    }

    /**
     * Write log entry
     */
    private static function log($level, $message, $context = [])
    {
        self::init();
        
        $timestamp = date('Y-m-d H:i:s');
        $contextStr = !empty($context) ? ' ' . json_encode($context) : '';
        $logEntry = "[$timestamp] [$level] $message$contextStr" . PHP_EOL;
        
        // Write to file
        file_put_contents(self::$logFile, $logEntry, FILE_APPEND | LOCK_EX);
        
        // Also log to PHP error log for critical errors
        if ($level === 'ERROR') {
            error_log("[$level] $message$contextStr");
        }
    }

    /**
     * Get log file path
     */
    public static function getLogFile()
    {
        self::init();
        return self::$logFile;
    }

    /**
     * Clear log file
     */
    public static function clear()
    {
        self::init();
        if (file_exists(self::$logFile)) {
            file_put_contents(self::$logFile, '');
        }
    }

    /**
     * Get recent log entries
     */
    public static function getRecentLogs($lines = 50)
    {
        self::init();
        if (!file_exists(self::$logFile)) {
            return [];
        }
        
        $file = file(self::$logFile);
        return array_slice($file, -$lines);
    }
}
