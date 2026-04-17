<?php
/**
 * Remove Member API
 * حذف عضو من الدورة (يسمح فقط لصاحب الدورة)
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
include __DIR__ . '/../../core/queries/queries.php';

checkAuthenticate();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$cycleId = $input['cycle_id'] ?? null;
$targetUserId = $input['target_user_id'] ?? null;

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

try {
    // 🔐 التحقق من الهوية
    $userId = getUserIdFromToken($token, $con);
    
    if (!$userId) {
        http_response_code(401);
        echo json_encode(['status' => 'fail', 'message' => 'Invalid token or user not found']);
        exit;
    }

    // 🛡️ التحقق من أن القائم بالعملية هو الـ Owner
    $stmt = $con->prepare(Queries::checkUserAccessQuery());
    $stmt->execute([
        ':cycle_id' => (int)$cycleId,
        ':user_id' => $userId
    ]);
    $requesterAccess = $stmt->fetch();

    if (!$requesterAccess || $requesterAccess['role'] !== 'owner') {
        http_response_code(403);
        echo json_encode(['status' => 'fail', 'message' => 'عذراً، صاحب الدورة فقط هو من يمكنه حذف الأعضاء.']);
        exit;
    }

    // 🚫 منع حذف الـ Owner نفسة من هنا (يجب استخدام حذف الدورة بالكامل)
    if ((int)$targetUserId === (int)$userId) {
        http_response_code(400);
        echo json_encode(['status' => 'fail', 'message' => 'لا يمكنك حذف نفسك. إذا كنت تريد مغادرة الدورة، يجب حذفها بالكامل لأنك المالك.']);
        exit;
    }

    // جلب اسم الدورة واسم من قام بالإزالة
    $stmtCycle = $con->prepare("SELECT name FROM cycles WHERE id = ?");
    $stmtCycle->execute([(int)$cycleId]);
    $cycleRow = $stmtCycle->fetch(PDO::FETCH_ASSOC);
    $cycleName = $cycleRow['name'] ?? 'الدورة';

    $stmtOwner = $con->prepare("SELECT name FROM users WHERE id = ?");
    $stmtOwner->execute([$userId]);
    $ownerRow = $stmtOwner->fetch(PDO::FETCH_ASSOC);
    $ownerName = $ownerRow['name'] ?? 'صاحب الدورة';

    // 🗑️ تنفيذ الحذف
    $stmt = $con->prepare(Queries::leaveCycleQuery());
    $stmt->execute([
        ':cycle_id' => (int)$cycleId,
        ':user_id' => (int)$targetUserId
    ]);

    // 🔔 إرسال إشعار FCM للعضو المحذوف
    require_once __DIR__ . '/../../core/fcm_sender.php';
    sendFCMToUser(
        $con,
        (int)$targetUserId,
        'تنبيه',
        "تم ازالتك من دورة $cycleName بواسطة $ownerName",
        [
            'type'     => 'member_removed',
            'cycle_id' => (string)$cycleId,
        ]
    );

    echo json_encode([
        'status' => 'success',
        'message' => 'تم حذف العضو من الدورة بنجاح'
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