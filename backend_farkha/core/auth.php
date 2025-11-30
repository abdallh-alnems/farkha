<?php

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


