<?php
/**
 * البحث عن مستخدمين بأرقام الهواتف (بحث جزئي)
 * Search Users by Phone Number (Live Search)
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
require_once __DIR__ . '/../../core/queries/user_queries.php';

checkAuthenticate();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$search_term = $input['search_term'] ?? null;

if (!$token || !$search_term) {
    http_response_code(400);
    echo json_encode(['status' => 'fail', 'message' => 'Missing required fields']);
    exit;
}

// Require at least 8 digits to prevent enumeration
if (strlen($search_term) < 8) {
    echo json_encode(['status' => 'success', 'data' => []]);
    exit;
}

try {
    $verifiedToken = verifyToken($token);
    $firebase_uid = $verifiedToken->claims()->get('sub');

    // ابحث عن المستخدمين بالرقم الجزئي واستبعد المستخدم الحالي
    $stmt = $con->prepare(UserQueries::searchByPhoneExcludeUid());
    $searchTermLike = '%' . $search_term . '%';
    $stmt->execute([
        'search_term' => $searchTermLike,
        'firebase_uid' => $firebase_uid
    ]);
    
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'status' => 'success',
        'data' => $results
    ]);

} catch (\Kreait\Firebase\Exception\Auth\FailedToVerifyToken $e) {
    http_response_code(401);
    echo json_encode(['status' => 'fail', 'message' => 'Invalid or expired token']);
} catch (Exception $e) {
    error_log('search_users error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['status' => 'fail', 'message' => 'Server error']);
}
