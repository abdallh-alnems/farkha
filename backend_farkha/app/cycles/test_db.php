<?php
require_once __DIR__ . '/../../core/connect.php';
try {
    $stmt = $con->query("DESCRIBE cycle_sales");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($columns);
} catch (Exception $e) {
    echo $e->getMessage();
}
?>
