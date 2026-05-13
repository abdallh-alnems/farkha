<?php

require_once __DIR__ . '/../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
Validator::required($cycleId, 'cycle_id');
$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);

$action = $input['action'] ?? null;
Validator::required($action, 'action');
$action = Validator::enum($action, ['accept', 'reject'], 'action');

$con = db();

try {
    $invitations = CycleModel::fetchUserInvitations($userId);
    $found = false;
    foreach ($invitations as $inv) {
        if ((int) $inv['cycle_id'] === $cycleId) {
            $found = true;
            break;
        }
    }

    if (!$found) {
        Response::fail('Invitation not found or already processed', 404);
    }

    if ($action === 'accept') {
        CycleModel::acceptInvitation($con, $cycleId, $userId);
    } else {
        CycleModel::rejectInvitation($con, $cycleId, $userId);
    }

    $ownerRow = Database::fetchOne(
        "SELECT user_id FROM cycle_users WHERE cycle_id = :cid AND role = 'owner' LIMIT 1",
        [':cid' => $cycleId]
    );

    if ($ownerRow) {
        $cycleRow = Database::fetchOne(
            "SELECT name FROM cycles WHERE id = :cid AND deleted_at IS NULL LIMIT 1",
            [':cid' => $cycleId]
        );
        $cycleName = $cycleRow ? $cycleRow['name'] : 'الدورة';

        $meRow = Database::fetchOne(
            "SELECT name FROM users WHERE id = :uid LIMIT 1",
            [':uid' => $userId]
        );
        $myName = ($meRow && !empty($meRow['name'])) ? $meRow['name'] : 'أحد الأعضاء';

        $title = "رد على الدعوة للانضمام";
        $body = "قام {$myName} بـ " . ($action === 'accept' ? 'قبول' : 'رفض') . " الانضمام إلى دورة {$cycleName}.";

        try {
            NotificationService::sendToUser($con, (int) $ownerRow['user_id'], $title, $body, [
                'type' => 'invitation_response',
                'cycle_id' => (string) $cycleId,
                'action' => $action,
            ]);
        } catch (Exception $e) {
            error_log("Notification failed for invitation response: " . $e->getMessage());
        }
    }

    Response::success([
        'message' => $action === 'accept' ? 'Invitation accepted successfully' : 'Invitation rejected successfully',
    ]);
} catch (PDOException $e) {
    error_log("respond_to_invitation error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
