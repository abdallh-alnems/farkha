<?php

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
include __DIR__ . '/../../core/queries/queries.php';

checkAuthenticate();

$input = $_POST;
if (empty($input)) {
    $raw = file_get_contents('php://input');
    $input = json_decode($raw, true);
    if (!is_array($input)) {
        parse_str($raw, $input);
    }
}

$token = $input['token'] ?? null;
$deviceId = $input['device_id'] ?? null;

if (!$token && !$deviceId) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Token or device_id is required'
    ]);
    exit;
}

try {
    $userId = null;

    if ($token) {
        try {
            $userId = getUserIdFromToken($token, $con);
        } catch (Exception $e) {
            $userId = null;
        }
    }

    if ($userId) {
        $stmt = $con->prepare(Queries::fetchAppReviewByUserIdQuery());
        $stmt->execute([':user_id' => $userId]);
    } else {
        if (!$deviceId) {
            echo json_encode([
                'status' => 'success',
                'data' => ['review' => null]
            ]);
            exit;
        }
        $stmt = $con->prepare(Queries::fetchAppReviewByDeviceIdQuery());
        $stmt->execute([':device_id' => $deviceId]);
    }

    $row = $stmt->fetch();

    if (!$row) {
        echo json_encode([
            'status' => 'success',
            'data' => ['review' => null]
        ]);
    } else {
        echo json_encode([
            'status' => 'success',
            'data' => [
                'review' => [
                    'id' => (int)$row['id'],
                    'user_id' => $row['user_id'] ? (int)$row['user_id'] : null,
                    'device_id' => $row['device_id'],
                    'rating' => (int)$row['rating'],
                    'issue' => $row['issue'],
                    'suggestion' => $row['suggestion'],
                    'app_version' => $row['app_version'],
                    'platform' => $row['platform'],
                    'created_at' => $row['created_at'],
                    'updated_at' => $row['updated_at'],
                ]
            ]
        ]);
    }

} catch (PDOException $e) {
    error_log('get_my_review error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Database error'
    ]);
} catch (Exception $e) {
    error_log('get_my_review error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Server error'
    ]);
}
