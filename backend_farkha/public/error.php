<?php

require_once __DIR__ . '/../config/env.php';

$errorCode = isset($_GET['code']) ? (int) $_GET['code'] : 500;
$customMessage = isset($_GET['message']) ? htmlspecialchars($_GET['message'], ENT_QUOTES, 'UTF-8') : null;

$errors = [
    400 => ['title' => 'Bad Request', 'message' => 'الطلب غير صالح'],
    401 => ['title' => 'Unauthorized', 'message' => 'يجب تسجيل الدخول'],
    403 => ['title' => 'Forbidden', 'message' => 'الوصول مرفوض'],
    404 => ['title' => 'Not Found', 'message' => 'الصفحة غير موجودة'],
    405 => ['title' => 'Method Not Allowed', 'message' => 'طريقة الطلب غير مسموحة'],
    429 => ['title' => 'Too Many Requests', 'message' => 'تم تجاوز عدد الطلبات المسموح'],
    500 => ['title' => 'Internal Server Error', 'message' => 'خطأ في الخادم'],
    503 => ['title' => 'Service Unavailable', 'message' => 'الخدمة غير متاحة حالياً'],
];

$error = $errors[$errorCode] ?? $errors[500];
if ($customMessage) {
    $error['message'] = $customMessage;
}

http_response_code($errorCode);
header('Content-Type: application/json; charset=utf-8');

if ($errorCode >= 500) {
    error_log("Farkha API Error {$errorCode}: " . json_encode([
        'message' => $error['message'],
        'uri' => $_SERVER['REQUEST_URI'] ?? 'unknown',
        'method' => $_SERVER['REQUEST_METHOD'] ?? 'unknown',
    ]));
}

echo json_encode([
    'status' => 'error',
    'code' => $errorCode,
    'message' => $error['message'],
    'timestamp' => date('c'),
    'version' => API_VERSION,
], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
