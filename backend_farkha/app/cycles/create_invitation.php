<?php
/**
 * إنشاء كود دعوة للانضمام إلى دورة
 * Create Invitation Code for Cycle
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';

checkAuthenticate();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$cycle_id = $input['cycle_id'] ?? null;

if (!$token || !$cycle_id) {
    http_response_code(400);
    echo json_encode(['status' => 'fail', 'message' => 'Missing required fields']);
    exit;
}

try {
    $verifiedToken = verifyToken($token);
    $uid = $verifiedToken->claims()->get('sub');

    // 1. الحصول على معرف المستخدم
    $stmt = $con->prepare("SELECT id FROM users WHERE firebase_uid = ?");
    $stmt->execute([$uid]);
    $requester = $stmt->fetch();

    if (!$requester) {
        throw new Exception("User not found");
    }

    // 2. التحقق من أنه مالك الدورة
    $stmt = $con->prepare("SELECT role FROM cycle_users WHERE cycle_id = ? AND user_id = ?");
    $stmt->execute([$cycle_id, $requester['id']]);
    $role = $stmt->fetch();

    if (!$role || $role['role'] !== 'owner') {
        http_response_code(403);
        echo json_encode(['status' => 'fail', 'message' => 'غير مصرح لك بإنشاء دعوة']);
        exit;
    }

    // 3. إنشاء كود فريد
    $code = strtoupper(substr(bin2hex(random_bytes(3)), 0, 6));

    // التأكد من عدم وجود كود مكرر
    $stmt = $con->prepare("SELECT id FROM cycle_invitations WHERE code = ?");
    $stmt->execute([$code]);
    while ($stmt->fetch()) {
        $code = strtoupper(substr(bin2hex(random_bytes(3)), 0, 6));
        $stmt->execute([$code]);
    }

    // 4. حفظ الكود (ينتهي بعد 7 أيام)
    $expires_at = date('Y-m-d H:i:s', strtotime('+7 days'));
    $stmt = $con->prepare(
        "INSERT INTO cycle_invitations (cycle_id, code, created_by, expires_at)
         VALUES (:cycle_id, :code, :created_by, :expires_at)"
    );
    $stmt->execute([
        'cycle_id' => $cycle_id,
        'code' => $code,
        'created_by' => $requester['id'],
        'expires_at' => $expires_at
    ]);

    // 5. إعادة الكود والرابط
    $link = "https://api.nims-farkha.com/backend_farkha/join/?code=$code";

    echo json_encode([
        'status' => 'success',
        'code' => $code,
        'link' => $link,
        'expires_at' => $expires_at
    ]);

} catch (\Kreait\Firebase\Exception\Auth\FailedToVerifyToken $e) {
    http_response_code(401);
    echo json_encode(['status' => 'fail', 'message' => 'Invalid or expired token']);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['status' => 'fail', 'message' => $e->getMessage()]);
}
