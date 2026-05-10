<?php

require_once __DIR__ . '/../config/bootstrap.php';

if (php_sapi_name() !== 'cli') {
    http_response_code(403);
    echo "This script must be run from CLI only.\n";
    exit(1);
}

$username = $argv[1] ?? 'nims';
$password = $argv[2] ?? null;

if (!$password) {
    echo "Usage: php seed_first_admin.php <username> <password>\n";
    exit(1);
}

$hash = password_hash($password, PASSWORD_BCRYPT);

try {
    Database::execute(
        "INSERT INTO admin_users (username, password_hash, role, display_name) VALUES (?, ?, 'superadmin', ?)",
        [$username, $hash, $username]
    );
    $id = Database::lastInsertId();
    echo "Superadmin created: id={$id}, username={$username}\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
