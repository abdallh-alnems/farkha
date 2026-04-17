<?php
/**
 * Respond to Invitation API
 * قبول أو رفض دعوة للانضمام لدورة
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
include __DIR__ . '/../../core/queries/queries.php';
require_once __DIR__ . '/../../core/fcm_sender.php';

// 🔒 حماية الـ API endpoint
checkAuthenticate();

// قراءة البيانات المرسلة
$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$cycle_id = $input['cycle_id'] ?? null;
$action = $input['action'] ?? null; // 'accept' or 'reject'

// التحقق من البيانات المطلوبة
if (!$token || !$cycle_id || !$action) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Missing required fields: token, cycle_id, action'
    ]);
    exit;
}

if (!in_array($action, ['accept', 'reject'])) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Invalid action. Must be accept or reject'
    ]);
    exit;
}

try {
    // 🔐 التحقق من Firebase Token والحصول على user_id
    $userId = getUserIdFromToken($token, $con);
    
    if (!$userId) {
        http_response_code(401);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Invalid token or user not found'
        ]);
        exit;
    }

    if ($action === 'accept') {
        $stmt = $con->prepare(Queries::acceptInvitationQuery());
    } else {
        $stmt = $con->prepare(Queries::rejectInvitationQuery());
    }

    $stmt->execute([
        ':cycle_id' => $cycle_id,
        ':user_id' => $userId
    ]);

    if ($stmt->rowCount() === 0) {
        http_response_code(404);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Invitation not found or already processed'
        ]);
        exit;
    }

    // إشعار صاحب الدورة بالرد
    $stmtOwner = $con->prepare("SELECT user_id FROM cycle_users WHERE cycle_id = ? AND role = 'owner'");
    $stmtOwner->execute([$cycle_id]);
    $ownerRow = $stmtOwner->fetch();
    
    // إحضار اسم الدورة
    $stmtCycle = $con->prepare("SELECT name FROM cycles WHERE id = ?");
    $stmtCycle->execute([$cycle_id]);
    $cycleRow = $stmtCycle->fetch();
    $cycleName = $cycleRow ? $cycleRow['name'] : 'الدورة';

    if ($ownerRow) {
        $stmtMe = $con->prepare("SELECT name FROM users WHERE id = ?");
        $stmtMe->execute([$userId]);
        $meRow = $stmtMe->fetch();
        $myName = $meRow && !empty($meRow['name']) ? $meRow['name'] : 'أحد الأعضاء';
        
        $title = "رد على الدعوة للانضمام";
        $body = "قام {$myName} بـ " . ($action === 'accept' ? 'قبول' : 'رفض') . " الانضمام إلى دورة {$cycleName}.";
        try {
            sendFCMToUser($con, (int) $ownerRow['user_id'], $title, $body, [
                'type' => 'invitation_response',
                'cycle_id' => $cycle_id,
                'action' => $action
            ]);
        } catch (Exception $e) {}
    }

    // ✅ إرسال الرد
    echo json_encode([
        'status' => 'success',
        'message' => 'Invitation ' . ($action === 'accept' ? 'accepted' : 'rejected') . ' successfully'
    ]);

} catch (\Kreait\Firebase\Exception\Auth\FailedToVerifyToken $e) {
    http_response_code(401);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Invalid or expired token'
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Database error'
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Server error'
    ]);
}
?>
