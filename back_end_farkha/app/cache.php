<?php

class CacheManager {
    private static $instance = null;
    private $cache = [];
    private $cacheDir;
    private $defaultTTL = 300; // 5 minutes
    
    private function __construct() {
        $this->cacheDir = __DIR__ . '/cache/';
        if (!is_dir($this->cacheDir)) {
            mkdir($this->cacheDir, 0755, true);
        }
    }
    
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    public function get($key) {
        // Check memory cache first
        if (isset($this->cache[$key])) {
            $data = $this->cache[$key];
            if ($data['expires'] > time()) {
                return $data['value'];
            } else {
                unset($this->cache[$key]);
            }
        }
        
        // Check file cache
        $filePath = $this->cacheDir . md5($key) . '.cache';
        if (file_exists($filePath)) {
            $data = unserialize(file_get_contents($filePath));
            if ($data['expires'] > time()) {
                $this->cache[$key] = $data; // Store in memory
                return $data['value'];
            } else {
                unlink($filePath); // Remove expired file
            }
        }
        
        return null;
    }
    
    public function set($key, $value, $ttl = null) {
        $ttl = $ttl ?? $this->defaultTTL;
        $data = [
            'value' => $value,
            'expires' => time() + $ttl,
            'created' => time()
        ];
        
        // Store in memory
        $this->cache[$key] = $data;
        
        // Store in file
        $filePath = $this->cacheDir . md5($key) . '.cache';
        file_put_contents($filePath, serialize($data), LOCK_EX);
        
        return true;
    }
    
    public function delete($key) {
        unset($this->cache[$key]);
        $filePath = $this->cacheDir . md5($key) . '.cache';
        if (file_exists($filePath)) {
            unlink($filePath);
        }
        return true;
    }
    
    public function clear() {
        $this->cache = [];
        $files = glob($this->cacheDir . '*.cache');
        foreach ($files as $file) {
            unlink($file);
        }
        return true;
    }
    
    public function getStats() {
        $files = glob($this->cacheDir . '*.cache');
        $totalSize = 0;
        $expiredCount = 0;
        
        foreach ($files as $file) {
            $totalSize += filesize($file);
            $data = unserialize(file_get_contents($file));
            if ($data['expires'] <= time()) {
                $expiredCount++;
            }
        }
        
        return [
            'memory_items' => count($this->cache),
            'file_items' => count($files),
            'total_size' => $totalSize,
            'expired_files' => $expiredCount
        ];
    }
}
?>
