<?php
/**
 * إضافة عضو إلى دورة بواسطة رقم الهاتف
 * Add Member to Cycle by Phone Number
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
require_once __DIR__ . '/../../core/queries/user_queries.php';
require_once __DIR__ . '/../../core/queries/cycle_queries.php';
require_once __DIR__ . '/../../core/fcm_sender.php';

checkAuthenticate();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$cycle_id = $input['cycle_id'] ?? null;
$phone = $input['phone'] ?? null;
$roleInput = $input['role'] ?? 'admin'; // 'admin' أو 'viewer'

if (!$token || !$cycle_id || !$phone) {
    http_response_code(400);
    echo json_encode(['status' => 'fail', 'message' => 'Missing required fields']);
    exit;
}

// التأكد من أن الدور صحيح
$allowedRoles = ['admin', 'viewer'];
if (!in_array($roleInput, $allowedRoles)) {
    $roleInput = 'admin';
}

try {
    $verifiedToken = verifyToken($token);
    $uid = $verifiedToken->claims()->get('sub');

    // 1. الحصول على بيانات المستخدم الطالب
    $stmt = $con->prepare("SELECT id, name FROM users WHERE firebase_uid = ?");
    $stmt->execute([$uid]);
    $requester = $stmt->fetch();

    if (!$requester) {
        throw new Exception("Requester user not found");
    }

    // الحصول على اسم الدورة
    $stmt = $con->prepare("SELECT name FROM cycles WHERE id = ?");
    $stmt->execute([$cycle_id]);
    $cycleData = $stmt->fetch();
    $cycleName = $cycleData ? $cycleData['name'] : 'دورة الدواجن';

    // 2. التحقق من أن الطالب هو مالك الدورة
    $stmt = $con->prepare("SELECT role FROM cycle_users WHERE cycle_id = ? AND user_id = ?");
    $stmt->execute([$cycle_id, $requester['id']]);
    $role = $stmt->fetch();

    if (!$role || $role['role'] !== 'owner') {
        http_response_code(403);
        echo json_encode(['status' => 'fail', 'message' => 'غير مصرح لك بإضافة أعضاء']);
        exit;
    }

    // 3. البحث عن المستخدم بالهاتف
    $stmt = $con->prepare(UserQueries::findByPhone());
    $stmt->execute(['phone' => $phone]);
    $targetUser = $stmt->fetch();

    if (!$targetUser) {
        http_response_code(404);
        echo json_encode(['status' => 'fail', 'message' => 'لم يتم العثور على مستخدم بهذا الرقم']);
        exit;
    }

    // 4. التحقق من أنه ليس عضواً بالفعل
    $stmt = $con->prepare("SELECT id FROM cycle_users WHERE cycle_id = ? AND user_id = ?");
    $stmt->execute([$cycle_id, $targetUser['id']]);
    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode(['status' => 'fail', 'message' => 'المستخدم عضو بالفعل في هذه الدورة']);
        exit;
    }

    // 5. إضافة العضو بحالة معلقة (إرسال دعوة)
    $stmt = $con->prepare(CycleQueries::insertCycleUser('pending'));
    $stmt->execute([
        'user_id' => $targetUser['id'],
        'cycle_id' => $cycle_id,
        'role' => $roleInput
    ]);

    // 6. إرسال إشعار للمستخدم المضاف
    $title = "لديك دعوة جديدة للانضمام لدورة";
    $requesterName = !empty($requester['name']) ? $requester['name'] : 'أحد أصحاب المزارع';
    $body = "دعاك {$requesterName} للانضمام لدورته {$cycleName} بصلاحية " . ($roleInput === 'admin' ? 'مدير' : 'مشاهد') . ".";
    try {
        sendFCMToUser($con, (int) $targetUser['id'], $title, $body, [
            'type' => 'cycle_invitation',
            'cycle_id' => $cycle_id
        ]);
    } catch (Exception $ex) {
        // Ignore error
    }

    echo json_encode([
        'status' => 'success',
        'message' => 'تم إرسال طلب الإضافة، في انتظار موافقة العضو',
        'user' => [
            'id' => $targetUser['id'],
            'name' => $targetUser['name'],
        ]
    ]);

} catch (\Kreait\Firebase\Exception\Auth\FailedToVerifyToken $e) {
    http_response_code(401);
    echo json_encode(['status' => 'fail', 'message' => 'Invalid or expired token']);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['status' => 'fail', 'message' => $e->getMessage()]);
}
