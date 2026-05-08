<?php

require_once __DIR__ . '/app_check_verifier.php';

function checkAuthenticate() {
    enforceIpRateLimit(100, 3600);
    $appCheckToken = $_SERVER['HTTP_X_FIREBASE_APPCHECK'] ?? null;
    if ($appCheckToken) {
        verifyAppCheckToken($appCheckToken);
    }
}

function checkAppCheckRequired() {
    enforceIpRateLimit(100, 3600);
    $appCheckToken = $_SERVER['HTTP_X_FIREBASE_APPCHECK'] ?? null;
    verifyAppCheckToken($appCheckToken);
}

function requirePostMethod() {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['status' => 'fail', 'message' => 'Method not allowed. Use POST.']);
        exit;
    }
}

function enforceIpRateLimit(int $maxRequests, int $windowSeconds): void {
    $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $cacheDir = sys_get_temp_dir() . '/farkha_rate_limit';

    if (!is_dir($cacheDir)) {
        @mkdir($cacheDir, 0700, true);
    }

    $key = md5($ip);
    $file = $cacheDir . '/' . $key;
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
        http_response_code(429);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['status' => 'fail', 'message' => 'Rate limit exceeded. Try again later.']);
        exit;
    }

    $data[] = $now;
    ftruncate($fp, 0);
    rewind($fp);
    fwrite($fp, json_encode($data));
    flock($fp, LOCK_UN);
    fclose($fp);
}
