<?php

// CGI/FastCGI compatibility: parse Authorization header manually if PHP_AUTH_USER is not set
if (!isset($_SERVER['PHP_AUTH_USER'])) {
    $authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
    if (preg_match('/Basic\s+(.*)$/i', $authHeader, $matches)) {
        $decoded = base64_decode($matches[1]);
        if ($decoded !== false && strpos($decoded, ':') !== false) {
            list($_SERVER['PHP_AUTH_USER'], $_SERVER['PHP_AUTH_PW']) = explode(':', $decoded, 2);
        }
    }
}

function checkAuthenticate() {
    if (!isset($_SERVER['PHP_AUTH_USER']) || !isset($_SERVER['PHP_AUTH_PW'])) {
        header('WWW-Authenticate: Basic realm="Farkha API"');
        ApiResponse::error('Authentication required', 401);
    }

    if ($_SERVER['PHP_AUTH_USER'] !== PHP_USER || $_SERVER['PHP_AUTH_PW'] !== PHP_PASS) {
        header('WWW-Authenticate: Basic realm="Farkha API"');
        ApiResponse::error('Invalid credentials', 401);
    }
}

?>


