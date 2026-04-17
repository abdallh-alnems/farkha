<?php
require_once __DIR__ . '/backend_farkha/core/connect.php';
$stmt = $con->query("DESCRIBE users");
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
print_r($rows);
