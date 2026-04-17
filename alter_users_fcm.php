<?php
require_once __DIR__ . '/backend_farkha/core/connect.php';

try {
    $stmt = $con->prepare("ALTER TABLE users ADD COLUMN fcm_token VARCHAR(255) DEFAULT NULL");
    $stmt->execute();
    echo "Column 'fcm_token' added successfully to 'users' table!\n";
} catch (PDOException $e) {
    if (strpos($e->getMessage(), 'Duplicate column name') !== false) {
        echo "Column 'fcm_token' already exists. Skipping.\n";
    } else {
        echo "Error: " . $e->getMessage() . "\n";
    }
}
