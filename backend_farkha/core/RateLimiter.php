<?php

final class RateLimiter {
    private static string $cacheDir;

    private static function getCacheDir(): string {
        if (!isset(self::$cacheDir)) {
            self::$cacheDir = sys_get_temp_dir() . '/farkha_rate_limit';
            if (!is_dir(self::$cacheDir)) {
                @mkdir(self::$cacheDir, 0700, true);
            }
        }
        return self::$cacheDir;
    }

    public static function enforceIpLimit(int $maxRequests = API_RATE_LIMIT, int $windowSeconds = API_RATE_WINDOW): void {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $file = self::getCacheDir() . '/' . md5($ip);
        $now = time();

        $fp = fopen($file, 'c+');
        if (!$fp) return;

        flock($fp, LOCK_EX);
        $data = [];
        $content = stream_get_contents($fp);
        if ($content) {
            $data = json_decode($content, true) ?: [];
        }

        $data = array_filter($data, function ($ts) use ($now, $windowSeconds) {
            return ($now - $ts) < $windowSeconds;
        });

        if (count($data) >= $maxRequests) {
            flock($fp, LOCK_UN);
            fclose($fp);
            Response::rateLimited($windowSeconds);
        }

        $data[] = $now;
        ftruncate($fp, 0);
        rewind($fp);
        fwrite($fp, json_encode($data));
        flock($fp, LOCK_UN);
        fclose($fp);
    }

    public static function checkLimit(string $identifier, int $limit = API_RATE_LIMIT, int $window = API_RATE_WINDOW): bool {
        $file = self::getCacheDir() . '/' . md5($identifier);
        $now = time();

        $fp = fopen($file, 'c+');
        if (!$fp) return true;

        flock($fp, LOCK_EX);
        $content = stream_get_contents($fp);
        $data = $content ? (json_decode($content, true) ?: []) : [];

        $data = array_filter($data, function ($ts) use ($now, $window) {
            return ($now - $ts) < $window;
        });

        if (count($data) >= $limit) {
            flock($fp, LOCK_UN);
            fclose($fp);
            return false;
        }

        $data[] = $now;
        ftruncate($fp, 0);
        rewind($fp);
        fwrite($fp, json_encode($data));
        flock($fp, LOCK_UN);
        fclose($fp);
        return true;
    }
}
