<?php

function setCorsHeaders() {
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    $allowed = CORS_ALLOWED_ORIGINS;

    if (empty($allowed)) {
        if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
            http_response_code(204);
            exit;
        }
        return;
    }

    $allowedOrigins = array_map('trim', explode(',', $allowed));
    if (in_array($origin, $allowedOrigins) || in_array('*', $allowedOrigins)) {
        header("Access-Control-Allow-Origin: " . ($origin ?: '*'));
    }

    header("Access-Control-Allow-Headers: " . CORS_ALLOWED_HEADERS);
    header("Access-Control-Allow-Methods: " . CORS_ALLOWED_METHODS);

    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(204);
        exit;
    }
}
