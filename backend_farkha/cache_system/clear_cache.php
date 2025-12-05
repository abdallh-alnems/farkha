<?php
require_once __DIR__ . '/../core/connect.php';

// Require authentication
checkAuthenticate();

// Clear cache files
$cacheDir = __DIR__ . '/cache_storage/';
$files = glob($cacheDir . '*.cache');
$count = 0;

foreach ($files as $file) {
    if (unlink($file)) {
        $count++;
    }
}

echo "Cache cleared! Deleted " . $count . " files.";
?>