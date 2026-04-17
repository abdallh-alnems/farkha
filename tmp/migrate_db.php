<?php
require_once __DIR__ . '/../backend_farkha/core/connect.php';

try {
    $stmt = $con->prepare("SHOW COLUMNS FROM cycles LIKE 'end_date_raw'");
    $stmt->execute();
    $column = $stmt->fetch();

    if (!$column) {
        $con->exec("ALTER TABLE cycles ADD COLUMN end_date_raw DATE DEFAULT NULL AFTER start_date_raw");
        echo "Column 'end_date_raw' added successfully to 'cycles' table.\n";
    } else {
        echo "Column 'end_date_raw' already exists.\n";
    }
} catch (PDOException $e) {
    echo "Database error: " . $e->getMessage() . "\n";
}
?>
