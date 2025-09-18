<?php
include "../../connect.php";

function sanitizeTypeIds($input) {
    if (empty($input)) return [];
    
    $type_ids = is_array($input) ? $input : explode(',', $input);
    return array_unique(array_filter(array_map('trim', $type_ids), function($id) {
        return is_numeric($id) && $id > 0;
    }));
}

function sendSSEData($data) {
    echo "data: " . json_encode($data, JSON_UNESCAPED_UNICODE) . "\n\n";
    ob_flush();
    flush();
}

function fetchPriceData($con, $type_ids) {
    try {
        $where_clause = empty($type_ids) ? "" : "WHERE t.type_id IN (" . str_repeat('?,', count($type_ids) - 1) . "?)";
        $params = $type_ids;
        
        $query = "
            SELECT
                today.higher_general_prices AS higher_today,
                today.lower_general_prices AS lower_today,
                yesterday.higher_general_prices AS higher_yesterday,
                yesterday.lower_general_prices AS lower_yesterday,
                t.type_name,
                t.type_id
            FROM (
                SELECT gp.*
                FROM general_prices gp
                WHERE gp.general_prices_date = (
                    SELECT MAX(gp2.general_prices_date)
                    FROM general_prices gp2
                    WHERE gp2.general_prices_type = gp.general_prices_type
                )
            ) AS today
            JOIN (
                SELECT gp.*
                FROM general_prices gp
                WHERE gp.general_prices_date = (
                    SELECT gp2.general_prices_date
                    FROM general_prices gp2
                    WHERE gp2.general_prices_type = gp.general_prices_type
                    ORDER BY gp2.general_prices_date DESC
                    LIMIT 1 OFFSET 1
                )
            ) AS yesterday ON today.general_prices_type = yesterday.general_prices_type
            JOIN types AS t ON today.general_prices_type = t.type_id
            $where_clause
            ORDER BY t.type_id
        ";
        
        $stmt = $con->prepare($query);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
        
    } catch (PDOException $e) {
        error_log("Database error: " . $e->getMessage());
        return false;
    }
}
$type_ids = sanitizeTypeIds($_GET['type_ids'] ?? $_POST['type_ids'] ?? []);

$check_interval = 600;

while (true) {
    if (connection_aborted()) break;
    
    $data = fetchPriceData($con, $type_ids);
    
    if ($data === false) {
        sendSSEData(["status" => "error", "message" => "خطأ في قاعدة البيانات"]);
        sleep($check_interval);
        continue;
    }
    
    if (empty($data)) {
        sendSSEData(["status" => "fail", "message" => "لا توجد بيانات للأنواع المطلوبة"]);
        sleep($check_interval);
        continue;
    }
    
    sendSSEData([
        "status" => "success",
        "data" => $data,
        "total_records" => count($data)
    ]);
    
    sleep($check_interval);
}
?>
