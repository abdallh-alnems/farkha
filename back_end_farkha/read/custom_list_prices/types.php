<?php

include "../../connect.php";

function getTypesList($con) {
    try {
        $query = "
            SELECT 
                t.type_id,
                t.type_name,
                m.main_id,
                m.main_name AS type_main_name
            FROM types t
            JOIN main m ON t.type_main = m.main_id
            WHERE m.main_id NOT IN (6, 7)
            ORDER BY t.type_id
        ";
        
        $stmt = $con->prepare($query);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
        
    } catch (PDOException $e) {
        error_log("Database error: " . $e->getMessage());
        return false;
    }
}

$data = getTypesList($con);

if ($data === false) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'خطأ في قاعدة البيانات'], JSON_UNESCAPED_UNICODE);
    exit;
}

echo json_encode([
    'status' => 'success',
    'total_records' => count($data),
    'data' => $data
], JSON_UNESCAPED_UNICODE);
?>
