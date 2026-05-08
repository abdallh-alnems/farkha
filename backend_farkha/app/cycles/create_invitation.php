<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();
Auth::requirePost();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$cycleId = $input['cycle_id'] ?? null;
Validator::required($cycleId, 'cycle_id');
$cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);

$con = db();

try {
    $access = CycleModel::checkReadAccess($cycleId, $userId);
    if (!$access || $access['role'] !== 'owner') {
        Response::forbidden('Unauthorized');
    }

    $code = strtoupper(substr(bin2hex(random_bytes(3)), 0, 6));

    $existing = Database::fetchOne("SELECT id FROM cycle_invitations WHERE code = ?", [$code]);
    while ($existing) {
        $code = strtoupper(substr(bin2hex(random_bytes(3)), 0, 6));
        $existing = Database::fetchOne("SELECT id FROM cycle_invitations WHERE code = ?", [$code]);
    }

    CycleModel::createInvitation($con, $cycleId, $code, $userId);

    $link = "https://api.nims-farkha.com/backend_farkha/join/?code=$code";
    $expiresAt = date('Y-m-d H:i:s', strtotime('+7 days'));

    Response::success([
        'code' => $code,
        'link' => $link,
        'expires_at' => $expiresAt,
    ]);
} catch (PDOException $e) {
    error_log("create_invitation error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
