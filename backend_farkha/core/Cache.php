<?php

final class Cache {
    private static ?Cache $instance = null;
    private array $memory = [];
    private string $cacheDir;
    private int $ttl;

    private function __construct() {
        $this->cacheDir = __DIR__ . '/../cache_system/cache_storage/';
        $this->ttl = 86400;
        if (!is_dir($this->cacheDir)) {
            mkdir($this->cacheDir, 0755, true);
        }
    }

    public static function getInstance(): self {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function get(string $key) {
        if (isset($this->memory[$key])) {
            if ($this->memory[$key]['expires'] > time()) {
                return $this->memory[$key]['value'];
            }
            unset($this->memory[$key]);
        }

        $filePath = $this->cacheDir . md5($key) . '.cache';
        if (!file_exists($filePath)) {
            return null;
        }

        $content = file_get_contents($filePath);
        if ($content === false) {
            return null;
        }

        $data = json_decode($content, true);
        if (!$data || !isset($data['expires'])) {
            @unlink($filePath);
            return null;
        }

        if ($data['expires'] <= time()) {
            @unlink($filePath);
            return null;
        }

        $this->memory[$key] = $data;
        return $data['value'];
    }

    public function set(string $key, $value, ?int $ttl = null): void {
        $data = [
            'value' => $value,
            'expires' => time() + ($ttl ?? $this->ttl),
            'created' => time(),
        ];

        $this->memory[$key] = $data;
        $filePath = $this->cacheDir . md5($key) . '.cache';
        file_put_contents($filePath, json_encode($data, JSON_UNESCAPED_UNICODE), LOCK_EX);
    }

    public function delete(string $key): void {
        unset($this->memory[$key]);
        $filePath = $this->cacheDir . md5($key) . '.cache';
        if (file_exists($filePath)) {
            @unlink($filePath);
        }
    }

    public function clear(): int {
        $this->memory = [];
        $count = 0;
        foreach (glob($this->cacheDir . '*.cache') as $file) {
            if (@unlink($file)) {
                $count++;
            }
        }
        return $count;
    }

    public static function remember(string $key, callable $callback, ?int $ttl = null) {
        $instance = self::getInstance();
        $cached = $instance->get($key);
        if ($cached !== null) {
            return $cached;
        }
        $value = $callback();
        $instance->set($key, $value, $ttl);
        return $value;
    }
}
