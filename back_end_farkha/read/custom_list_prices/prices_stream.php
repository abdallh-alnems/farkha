<?php
// إعدادات الأمان والأداء
ini_set('max_execution_time', 0);
ini_set('memory_limit', '256M');
error_reporting(E_ALL);
ini_set('display_errors', 0);

include "../../connect.php";

// التحقق من الاتصال بقاعدة البيانات
if (!isset($con) || !$con) {
    http_response_code(500);
    die(json_encode(['error' => 'Database connection failed']));
}

// إعداد SSE headers
header('Content-Type: text/event-stream');
header('Cache-Control: no-cache');
header('Connection: keep-alive');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Cache-Control');
header('X-Accel-Buffering: no'); // لـ Nginx

/**
 * تنظيف وتصحيح معاملات الإدخال
 */
function sanitizeTypeIds($input) {
    if (empty($input)) {
        return [];
    }
    
    $type_ids = is_array($input) ? $input : explode(',', $input);
    $type_ids = array_map('trim', $type_ids);
    $type_ids = array_filter($type_ids, function($id) {
        return is_numeric($id) && $id > 0;
    });
    
    return array_unique($type_ids);
}

/**
 * إنشاء مفتاح فريد للأسعار
 */
function createPriceKey($data) {
    if (empty($data)) {
        return '';
    }
    
    $key_parts = [];
    foreach ($data as $row) {
        $key_parts[] = sprintf(
            '%d_%s_%s',
            $row['type_id'],
            $row['higher_today'] ?? '0',
            $row['lower_today'] ?? '0'
        );
    }
    
    return md5(implode('|', $key_parts));
}

/**
 * إرسال بيانات SSE
 */
function sendSSEData($data) {
    echo "data: " . json_encode($data, JSON_UNESCAPED_UNICODE) . "\n\n";
    ob_flush();
    flush();
}

/**
 * الحصول على البيانات من قاعدة البيانات
 */
function fetchPriceData($con, $type_ids) {
    try {
        // بناء WHERE clause
        if (empty($type_ids)) {
            $where_clause = "";
            $params = [];
        } else {
            $placeholders = str_repeat('?,', count($type_ids) - 1) . '?';
            $where_clause = "WHERE t.type_id IN ($placeholders)";
            $params = $type_ids;
        }
        
        $query = "
            SELECT
                today.higher_general_prices AS higher_today,
                today.lower_general_prices AS lower_today,
                yesterday.higher_general_prices AS higher_yesterday,
                yesterday.lower_general_prices AS lower_yesterday,
                t.type_name,
                t.type_id
            FROM
                (
                    SELECT gp.*
                    FROM general_prices gp
                    WHERE gp.general_prices_date = (
                        SELECT MAX(gp2.general_prices_date)
                        FROM general_prices gp2
                        WHERE gp2.general_prices_type = gp.general_prices_type
                    )
                ) AS today
            JOIN
                (
                    SELECT gp.*
                    FROM general_prices gp
                    WHERE gp.general_prices_date = (
                        SELECT gp2.general_prices_date
                        FROM general_prices gp2
                        WHERE gp2.general_prices_type = gp.general_prices_type
                        ORDER BY gp2.general_prices_date DESC
                        LIMIT 1 OFFSET 1
                    )
                ) AS yesterday
            ON today.general_prices_type = yesterday.general_prices_type
            JOIN types AS t
            ON today.general_prices_type = t.type_id
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

// الحصول على type IDs من المعاملات
$type_ids = [];
if (isset($_GET['type_ids'])) {
    $type_ids = sanitizeTypeIds($_GET['type_ids']);
} elseif (isset($_POST['type_ids'])) {
    $type_ids = sanitizeTypeIds($_POST['type_ids']);
}

// متغيرات لتتبع التغييرات
$previous_prices_key = null;
$first_run = true;
$error_sent = false;
$check_interval = 3; // 5 دقائق

// إرسال البيانات فقط عند التغيير
while (true) {
    try {
        // التحقق من اتصال العميل
        if (connection_aborted()) {
            break;
        }
        
        $data = fetchPriceData($con, $type_ids);
        
        if ($data === false) {  
            if (!$error_sent) {
                sendSSEData([
                    "status" => "error",
                    "message" => "خطأ في قاعدة البيانات"
                ]);
                $error_sent = true;
            }
            sleep($check_interval);
            continue;
        }
        
        if (empty($data)) {
            if ($first_run) {
                sendSSEData([
                    "status" => "fail",
                    "message" => "لا توجد بيانات للأنواع المطلوبة"
                ]);
            }
            sleep($check_interval);
            continue;
        }
        
        // إنشاء مفتاح فريد للأسعار الحالية
        $current_prices_key = createPriceKey($data);
        
        // إرسال البيانات في كل مرة لضمان رؤية التغييرات
        if ($first_run || $current_prices_key !== $previous_prices_key) {
            $response = [
                "status" => "success",
                "data" => $data,
                "total_records" => count($data)
            ];
            
            sendSSEData($response);
            $previous_prices_key = $current_prices_key;
        }
        
        $first_run = false;
        $error_sent = false;
        
    } catch (Exception $e) {
        error_log("Error in price monitoring: " . $e->getMessage());
        if (!$error_sent) {
            sendSSEData([
                "status" => "error",
                "message" => "خطأ في النظام"
            ]);
            $error_sent = true;
        }
    }
    
    // انتظار 5 دقائق قبل الفحص التالي
    sleep($check_interval);
}
?>
