<?php
/**
 * الانضمام إلى دورة بكود الدعوة
 * Join Cycle by Invitation Code
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
require_once __DIR__ . '/../../core/queries/cycle_queries.php';

checkAuthenticate();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$code = $input['code'] ?? null;

if (!$token || !$code) {
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
    $user = $stmt->fetch();

    if (!$user) {
        throw new Exception("User not found");
    }

    // 2. البحث عن الكود
    $stmt = $con->prepare(
        "SELECT * FROM cycle_invitations WHERE code = ? LIMIT 1"
    );
    $stmt->execute([$code]);
    $invitation = $stmt->fetch();

    if (!$invitation) {
        http_response_code(404);
        echo json_encode(['status' => 'fail', 'message' => 'كود الدعوة غير صالح']);
        exit;
    }

    // 3. التحقق من الصلاحية
    if ($invitation['expires_at'] && strtotime($invitation['expires_at']) < time()) {
        http_response_code(410);
        echo json_encode(['status' => 'fail', 'message' => 'كود الدعوة منتهي الصلاحية']);
        exit;
    }

    // 4. التحقق من أن المستخدم ليس عضواً بالفعل
    $stmt = $con->prepare("SELECT id FROM cycle_users WHERE cycle_id = ? AND user_id = ?");
    $stmt->execute([$invitation['cycle_id'], $user['id']]);
    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode(['status' => 'fail', 'message' => 'أنت عضو بالفعل في هذه الدورة']);
        exit;
    }

    // 5. إضافة المستخدم كعضو
    $stmt = $con->prepare(CycleQueries::insertCycleUser());
    $stmt->execute([
        'user_id' => $user['id'],
        'cycle_id' => $invitation['cycle_id'],
        'role' => 'member'
    ]);

    // 6. جلب اسم الدورة للعرض
    $stmt = $con->prepare("SELECT name FROM cycles WHERE id = ?");
    $stmt->execute([$invitation['cycle_id']]);
    $cycle = $stmt->fetch();

    echo json_encode([
        'status' => 'success',
        'message' => 'تم الانضمام للدورة بنجاح',
        'cycle_name' => $cycle['name'] ?? ''
    ]);

} catch (\Kreait\Firebase\Exception\Auth\FailedToVerifyToken $e) {
    http_response_code(401);
    echo json_encode(['status' => 'fail', 'message' => 'Invalid or expired token']);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['status' => 'fail', 'message' => $e->getMessage()]);
}
