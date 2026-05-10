<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class CacheStatsApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $cacheDir = __DIR__ . '/../../cache_system/cache_storage';
            $files = glob($cacheDir . '/*.cache');
            $totalSize = 0;
            $oldest = null;
            $newest = null;

            foreach ($files as $file) {
                $size = filesize($file);
                $totalSize += $size;
                $mtime = filemtime($file);
                if ($oldest === null || $mtime < $oldest) $oldest = $mtime;
                if ($newest === null || $mtime > $newest) $newest = $mtime;
            }

            $this->success([
                'file_count' => count($files),
                'total_size_bytes' => $totalSize,
                'total_size_human' => self::formatBytes($totalSize),
                'oldest' => $oldest ? date('c', $oldest) : null,
                'newest' => $newest ? date('c', $newest) : null,
            ]);
        }, 'cache_stats');
    }

    private static function formatBytes(int $bytes): string {
        if ($bytes >= 1048576) return round($bytes / 1048576, 2) . ' MB';
        if ($bytes >= 1024) return round($bytes / 1024, 2) . ' KB';
        return $bytes . ' B';
    }
}

new CacheStatsApi();
