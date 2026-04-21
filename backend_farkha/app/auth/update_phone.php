<?php

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
require_once __DIR__ . '/../../core/queries/queries.php';

checkAuthenticate();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;
$verifiedToken = $input['verified_token'] ?? null;
$phone = $input['phone'] ?? null;

$firebaseToken = requireValidToken($token);
$uid = $firebaseToken->claims()->get('sub');

if ($verifiedToken) {
    try {
        $con->beginTransaction();

        $stmt = $con->prepare(Queries::findPhoneVerificationByVerifiedToken());
        $stmt->execute([':verified_token' => $verifiedToken]);
        $verification = $stmt->fetch();

        if (!$verification) {
            $con->rollBack();
            http_response_code(404);
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode([
                'success' => false,
                'error' => [
                    'code' => 'verified_session_not_found',
                    'message' => 'رمز التحقق غير موجود أو منتهي الصلاحية',
                ],
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }

        if ($verification['firebase_uid'] !== $uid) {
            $con->rollBack();
            http_response_code(403);
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode([
                'success' => false,
                'error' => [
                    'code' => 'verified_token_mismatch',
                    'message' => 'رمز التحقق لا ينتمي لهذا الحساب',
                ],
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }

        $phoneToSet = $verification['phone'];

        $stmt = $con->prepare(Queries::findUserByFirebaseUidQuery());
        $stmt->execute([':firebase_uid' => $uid]);
        $user = $stmt->fetch();

        if (!$user) {
            $con->rollBack();
            ApiResponse::fail('User not found', 404);
        }

        $stmt = $con->prepare(Queries::clearPhoneForOtherUsers());
        $stmt->execute([
            ':phone' => $phoneToSet,
            ':user_id' => $user['id'],
        ]);

        $stmt = $con->prepare(Queries::updatePhoneVerified());
        $stmt->execute([
            ':phone' => $phoneToSet,
            ':user_id' => $user['id'],
        ]);

        $stmt = $con->prepare(Queries::consumeVerifiedToken());
        $stmt->execute([':id' => $verification['id']]);

        $con->commit();

        ApiResponse::success([
            'phone' => $phoneToSet,
            'message' => 'تم توثيق رقم الهاتف بنجاح',
        ]);

    } catch (PDOException $e) {
        if ($con->inTransaction()) $con->rollBack();
        error_log("update_phone DB error: " . $e->getMessage());
        ApiResponse::fail('Database error', 500);
    }
} else if ($phone) {
    try {
        $stmt = $con->prepare(Queries::findUserByFirebaseUidQuery());
        $stmt->execute([':firebase_uid' => $uid]);
        $user = $stmt->fetch();

        if (!$user) {
            ApiResponse::fail('User not found', 404);
        }

        $stmt = $con->prepare(Queries::updateUserPhoneQuery());
        $stmt->execute([
            ':phone' => $phone,
            ':firebase_uid' => $uid,
        ]);

        ApiResponse::success(['message' => 'Phone number updated successfully']);

    } catch (PDOException $e) {
        error_log("update_phone DB error: " . $e->getMessage());
        ApiResponse::fail('Database error', 500);
    }
} else {
    http_response_code(400);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'success' => false,
        'error' => [
            'code' => 'missing_verified_token',
            'message' => 'رمز التحقق مطلوب',
        ],
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
