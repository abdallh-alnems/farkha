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

    $rating = $input['rating'] ?? null;
    if ($rating === null || !is_int($rating) || $rating < 1 || $rating > 5) {
        http_response_code(400);
        echo json_encode([
            'status' => 'fail',
            'message' => 'rating must be between 1 and 5'
        ]);
        exit;
    }

    $issue = $input['issue'] ?? null;
    $suggestion = $input['suggestion'] ?? null;
    $appVersion = $input['app_version'] ?? null;
    $platform = $input['platform'] ?? null;

    if ($issue !== null && is_string($issue) && mb_strlen(trim($issue)) > 500) {
        http_response_code(400);
        echo json_encode([
            'status' => 'fail',
            'message' => 'issue must not exceed 500 characters'
        ]);
        exit;
    }

    if ($suggestion !== null && is_string($suggestion) && mb_strlen(trim($suggestion)) > 500) {
        http_response_code(400);
        echo json_encode([
            'status' => 'fail',
            'message' => 'suggestion must not exceed 500 characters'
        ]);
        exit;
    }

    if ($platform !== null && !in_array($platform, ['android', 'ios'], true)) {
        http_response_code(400);
        echo json_encode([
            'status' => 'fail',
            'message' => 'platform must be android or ios'
        ]);
        exit;
    }

    $issueValue = (is_string($issue) && trim($issue) !== '') ? trim($issue) : null;
    $suggestionValue = (is_string($suggestion) && trim($suggestion) !== '') ? trim($suggestion) : null;

    $stmt = $con->prepare(Queries::upsertAppReviewQuery());
    $stmt->execute([
        ':user_id' => $userId,
        ':rating' => $rating,
        ':issue' => $issueValue,
        ':suggestion' => $suggestionValue,
        ':app_version' => $appVersion,
        ':platform' => $platform,
    ]);

    $rowCount = $stmt->rowCount();
    $wasCreated = $rowCount === 1;

    $reviewId;
    if ($wasCreated) {
        $reviewId = (int)$con->lastInsertId();
    } else {
        $idStmt = $con->prepare(Queries::fetchAppReviewIdByUserIdQuery());
        $idStmt->execute([':user_id' => $userId]);
        $row = $idStmt->fetch();
        $reviewId = (int)$row['id'];
    }

    echo json_encode([
        'status' => 'success',
        'data' => [
            'review_id' => $reviewId,
            'was_created' => $wasCreated,
            'message' => 'App review saved successfully'
        ]
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
