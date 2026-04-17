<?php
require_once __DIR__ . '/backend_farkha/core/connect.php';
try {
    $stmt = $con->query("SHOW TABLES LIKE 'cycle_invitations'");
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
    print_r($result);
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
