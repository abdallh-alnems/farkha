<?php

function setCorsHeaders() {
    header("Access-Control-Allow-Origin: " . CORS_ALLOWED_ORIGINS);
    header("Access-Control-Allow-Headers: " . CORS_ALLOWED_HEADERS);
    header("Access-Control-Allow-Methods: " . CORS_ALLOWED_METHODS);

    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }
}

?>


