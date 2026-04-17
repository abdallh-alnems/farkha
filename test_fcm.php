<?php
require_once __DIR__ . '/backend_farkha/core/connect.php';
$stmt = $db->query("SELECT phone, name, fcm_token FROM users WHERE fcm_token IS NOT NULL AND fcm_token != ''");
$result = $stmt->fetchAll();
print_r($result);
?>
