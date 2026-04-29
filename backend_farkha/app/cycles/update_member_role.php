<?php
/**
 * Update Member Role API
 * تغيير دور عضو في الدورة (يسمح فقط لصاحب الدورة)
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
include __DIR__ . '/../../core/queries/queries.php';

checkAuthenticate();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$cycleId = $input['cycle_id'] ?? null;
$targetUserId = $input['target_user_id'] ?? null;
$newRole = $input['new_role'] ?? null;

if (!$token) {
    http_response_code(400);
    echo json_encode(['status' => 'fail', 'message' => 'Token is required']);
    exit;
}

if (!$cycleId || !is_numeric($cycleId) || !$targetUserId || !is_numeric($targetUserId)) {
    http_response_code(400);
    echo json_encode(['status' => 'fail', 'message' => 'cycle_id and target_user_id are required']);
    exit;
}

$allowedRoles = ['admin', 'viewer', 'member'];
if (!$newRole || !in_array($newRole, $allowedRoles)) {
    http_response_code(400);
    echo json_encode(['status' => 'fail', 'message' => 'new_role must be admin or viewer']);
    exit;
}

try {
    // 🔐 التحقق من الهوية
    $userId = getUserIdFromToken($token, $con);

    if (!$userId) {
        http_response_code(401);
        echo json_encode(['status' => 'fail', 'message' => 'Invalid token or user not found']);
        exit;
    }

    // 🛡️ التحقق من أن القائم بالعملية هو الـ Owner
    $stmt = $con->prepare(Queries::checkUserReadAccessQuery());
    $stmt->execute([
        ':cycle_id' => (int)$cycleId,
        ':user_id' => $userId
    ]);
    $requesterAccess = $stmt->fetch();

    if (!$requesterAccess || $requesterAccess['role'] !== 'owner') {
        http_response_code(403);
        echo json_encode(['status' => 'fail', 'message' => 'عذراً، صاحب الدورة فقط هو من يمكنه تغيير صلاحيات الأعضاء.']);
        exit;
    }

    // 🚫 منع تغيير دور الـ Owner
    if ((int)$targetUserId === (int)$userId) {
        http_response_code(400);
        echo json_encode(['status' => 'fail', 'message' => 'لا يمكنك تغيير دورك الخاص.']);
        exit;
    }

    // ✏️ تحديث الدور
    $stmt = $con->prepare(
        "UPDATE cycle_users SET role = :new_role WHERE cycle_id = :cycle_id AND user_id = :target_user_id AND role != 'owner'"
    );
    $stmt->execute([
        ':new_role'       => $newRole,
        ':cycle_id'       => (int)$cycleId,
        ':target_user_id' => (int)$targetUserId,
    ]);

    $rowsAffected = $stmt->rowCount();

    if ($rowsAffected === 0) {
        http_response_code(404);
        echo json_encode(['status' => 'fail', 'message' => 'العضو غير موجود في هذه الدورة أو لا يمكن تغيير دوره.']);
        exit;
    }

    // جلب اسم الدورة واسم صاحبها لإرسال الإشعار
    $stmtCycle = $con->prepare("SELECT name FROM cycles WHERE id = ?");
    $stmtCycle->execute([(int)$cycleId]);
    $cycleRow = $stmtCycle->fetch(PDO::FETCH_ASSOC);
    $cycleName = $cycleRow['name'] ?? 'الدورة';

    $stmtOwner = $con->prepare("SELECT name FROM users WHERE id = ?");
    $stmtOwner->execute([$userId]);
    $ownerRow = $stmtOwner->fetch(PDO::FETCH_ASSOC);
    $ownerName = $ownerRow['name'] ?? 'صاحب الدورة';

    $roleLabel = $newRole === 'admin' ? 'مشرف' : 'متابع';

    // 🔔 إرسال إشعار FCM للعضو المُغيَّر دوره
    require_once __DIR__ . '/../../core/fcm_sender.php';
    sendFCMToUser(
        $con,
        (int)$targetUserId,
        'تنبيه',
        "تم تغيير دورك في دورة $cycleName إلى \"$roleLabel\" بواسطة $ownerName",
        [
            'type'     => 'role_changed',
            'cycle_id' => (string)$cycleId,
            'new_role' => $newRole,
        ]
    );

    echo json_encode([
        'status'  => 'success',
        'message' => 'تم تغيير صلاحية العضو بنجاح',
        'new_role' => $newRole,
    ]);

} catch (\Kreait\Firebase\Exception\Auth\FailedToVerifyToken $e) {
    http_response_code(401);
    echo json_encode(['status' => 'fail', 'message' => 'Invalid or expired token']);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['status' => 'fail', 'message' => 'Database error']);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['status' => 'fail', 'message' => 'Server error']);
}
