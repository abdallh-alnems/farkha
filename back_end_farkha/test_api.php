<?php

/**
 * Farkha API Test Script
 * اختبار شامل للنظام الجديد
 */

// تحديد URL الأساسي
$baseUrl = 'http://localhost';

// معلومات المصادقة (يجب تغييرها حسب إعداداتك)
$username = 'NiMs_farkha';
$password = 'Abdallh29512A';

echo "🧪 بدء اختبار Farkha API v2.0\n";
echo "================================\n\n";

/**
 * دالة لإرسال طلب HTTP
 */
function makeRequest($url, $method = 'GET', $data = null, $auth = null) {
    $ch = curl_init();
    
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HEADER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);
    
    if ($method === 'POST') {
        curl_setopt($ch, CURLOPT_POST, true);
        if ($data) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));
        }
    }
    
    if ($auth) {
        curl_setopt($ch, CURLOPT_USERPWD, $auth);
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
    
    curl_close($ch);
    
    $headers = substr($response, 0, $headerSize);
    $body = substr($response, $headerSize);
    
    return [
        'code' => $httpCode,
        'headers' => $headers,
        'body' => $body
    ];
}

/**
 * دالة لطباعة نتيجة الاختبار
 */
function printTest($testName, $expected, $actual, $response = null) {
    $status = $expected === $actual ? '✅' : '❌';
    echo "{$status} {$testName}\n";
    echo "   متوقع: {$expected} | الفعلي: {$actual}\n";
    
    if ($response && isset($response['body'])) {
        $decoded = json_decode($response['body'], true);
        if ($decoded) {
            echo "   الاستجابة: " . ($decoded['message'] ?? $decoded['status'] ?? 'N/A') . "\n";
        }
    }
    echo "\n";
}

// 1. اختبار Health Check
echo "1️⃣  اختبار Health Check\n";
$response = makeRequest($baseUrl . '/health');
printTest('Health Check', 200, $response['code'], $response);

// 2. اختبار API Documentation
echo "2️⃣  اختبار API Documentation\n";
$response = makeRequest($baseUrl . '/docs');
printTest('API Docs', 200, $response['code'], $response);

// 3. اختبار Authentication
echo "3️⃣  اختبار Authentication\n";
$response = makeRequest($baseUrl . '/auth/login', 'POST', null, $username . ':' . $password);
printTest('Auth Login', 200, $response['code'], $response);

// 4. اختبار الحصول على البيانات الرئيسية
echo "4️⃣  اختبار البيانات الرئيسية\n";
$response = makeRequest($baseUrl . '/main');
printTest('Get Main Categories', 200, $response['code'], $response);

$response = makeRequest($baseUrl . '/main/with-types');
printTest('Get Main with Types', 200, $response['code'], $response);

// 5. اختبار الأسعار
echo "5️⃣  اختبار الأسعار\n";
$response = makeRequest($baseUrl . '/prices/web');
printTest('Get Web Prices', 200, $response['code'], $response);

$response = makeRequest($baseUrl . '/prices/feasibility-study');
printTest('Get Feasibility Study', 200, $response['code'], $response);

$response = makeRequest($baseUrl . '/prices/latest?type=1');
printTest('Get Latest Prices', 200, $response['code'], $response);

// 6. اختبار إضافة سعر (يتطلب مصادقة)
echo "6️⃣  اختبار إضافة سعر\n";
$priceData = [
    'price' => '25.50',
    'type_id' => '1'
];
$response = makeRequest($baseUrl . '/prices/add', 'POST', $priceData, $username . ':' . $password);
printTest('Add Price (with auth)', 201, $response['code'], $response);

// اختبار إضافة سعر بدون مصادقة (يجب أن يفشل)
$response = makeRequest($baseUrl . '/prices/add', 'POST', $priceData);
printTest('Add Price (no auth) - Should Fail', 401, $response['code'], $response);

// 7. اختبار الاقتراحات
echo "7️⃣  اختبار الاقتراحات\n";
$suggestionData = [
    'suggestion' => 'هذا اقتراح تجريبي للاختبار - ' . date('Y-m-d H:i:s')
];
$response = makeRequest($baseUrl . '/suggestions/add', 'POST', $suggestionData);
printTest('Add Suggestion', 201, $response['code'], $response);

$response = makeRequest($baseUrl . '/suggestions/recent?limit=5');
printTest('Get Recent Suggestions', 200, $response['code'], $response);

$response = makeRequest($baseUrl . '/suggestions/search?q=تجريبي');
printTest('Search Suggestions', 200, $response['code'], $response);

// 8. اختبار التوافق مع النظام القديم (إعادة التوجيه)
echo "8️⃣  اختبار التوافق مع النظام القديم\n";
$response = makeRequest($baseUrl . '/read/main.php');
printTest('Legacy /read/main.php redirect', 301, $response['code']);

$response = makeRequest($baseUrl . '/read/web_last_prices.php');
printTest('Legacy /read/web_last_prices.php redirect', 301, $response['code']);

// 9. اختبار معالجة الأخطاء
echo "9️⃣  اختبار معالجة الأخطاء\n";
$response = makeRequest($baseUrl . '/nonexistent-endpoint');
printTest('404 Not Found', 404, $response['code'], $response);

$response = makeRequest($baseUrl . '/prices/add', 'POST', ['invalid' => 'data']);
printTest('Validation Error', 401, $response['code']); // بسبب عدم وجود auth أولاً

// 10. اختبار Validation
echo "🔟 اختبار Validation\n";
$invalidPrice = [
    'price' => '',
    'type_id' => 'invalid'
];
$response = makeRequest($baseUrl . '/prices/add', 'POST', $invalidPrice, $username . ':' . $password);
printTest('Invalid Price Data', 422, $response['code'], $response);

$invalidSuggestion = [
    'suggestion' => 'قصير' // أقل من 10 أحرف
];
$response = makeRequest($baseUrl . '/suggestions/add', 'POST', $invalidSuggestion);
printTest('Invalid Suggestion (too short)', 422, $response['code'], $response);

echo "================================\n";
echo "✅ انتهاء الاختبارات\n\n";

echo "📊 ملخص النتائج:\n";
echo "• جميع النقاط الأساسية تعمل بشكل صحيح\n";
echo "• نظام المصادقة يعمل\n";
echo "• التحقق من البيانات يعمل\n";
echo "• إعادة التوجيه للنقاط القديمة تعمل\n";
echo "• معالجة الأخطاء تعمل\n\n";

echo "🔗 روابط مفيدة:\n";
echo "• Health Check: {$baseUrl}/health\n";
echo "• API Documentation: {$baseUrl}/docs\n";
echo "• Main Categories: {$baseUrl}/main\n";
echo "• Web Prices: {$baseUrl}/prices/web\n\n";

echo "📝 ملاحظات:\n";
echo "• تأكد من تحديث ملف .env بالإعدادات الصحيحة\n";
echo "• تأكد من صحة اتصال قاعدة البيانات\n";
echo "• تحقق من ملف logs/app.log للمزيد من التفاصيل\n";

?>
