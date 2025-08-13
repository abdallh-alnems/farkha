<?php
// إعدادات الأمان والأداء
ini_set('max_execution_time', 30);
ini_set('memory_limit', '128M');
error_reporting(E_ALL);
ini_set('display_errors', 0);

include "../../connect.php";

// التحقق من الاتصال بقاعدة البيانات
if (!isset($con) || !$con) {
    http_response_code(500);
    die(json_encode(['error' => 'Database connection failed']));
}

// إعداد headers
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

/**
 * جلب قائمة الأنواع مع الفئات الرئيسية
 */
function getTypesList($con) {
    try {
        $query = "
            SELECT 
                t.type_id,
                t.type_name,
                m.main_id,
                m.main_name AS type_main_name
            FROM types t
            JOIN main m 
                ON t.type_main = m.main_id
            WHERE m.main_id NOT IN (6, 7)
            ORDER BY t.type_id
        ";
        
        $stmt = $con->prepare($query);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
        
    } catch (PDOException $e) {
        error_log("Database error in getTypesList: " . $e->getMessage());
        return false;
    }
}

// الحصول على البيانات
$data = getTypesList($con);

if ($data === false) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'خطأ في قاعدة البيانات'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($data)) {
    echo json_encode([
        'status' => 'success',
        'message' => 'لا توجد بيانات',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// إرجاع البيانات
echo json_encode([
    'status' => 'success',
    'message' => 'تم جلب البيانات بنجاح',
    'total_records' => count($data),
    'data' => $data
], JSON_UNESCAPED_UNICODE);
?>
