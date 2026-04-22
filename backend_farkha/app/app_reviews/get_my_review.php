<?php

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
include __DIR__ . '/../../core/queries/queries.php';

checkAuthenticate();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;

if (!$token) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Token is required'
    ]);
    exit;
}

try {
    $userId = getUserIdFromToken($token, $con);

    if (!$userId) {
        http_response_code(401);
        echo json_encode([
            'status' => 'fail',
            'message' => 'Invalid or expired token'
        ]);
        exit;
    }

    $stmt = $con->prepare(Queries::fetchAppReviewByUserIdQuery());
    $stmt->execute([':user_id' => $userId]);
    $row = $stmt->fetch();

    if (!$row) {
        echo json_encode([
            'status' => 'success',
            'data' => [
                'review' => null
            ]
        ]);
    } else {
        echo json_encode([
            'status' => 'success',
            'data' => [
                'review' => [
                    'id' => (int)$row['id'],
                    'user_id' => (int)$row['user_id'],
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
