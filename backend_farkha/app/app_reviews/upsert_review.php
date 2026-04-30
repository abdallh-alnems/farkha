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

$userId = null;
if ($token) {
    try {
        $userId = getUserIdFromToken($token, $con);
    } catch (Exception $e) {
        $userId = null;
    }
}

$rating = $input['rating'] ?? null;
if ($rating !== null && is_string($rating)) {
    $rating = (int) $rating;
}
if ($rating !== null && (!is_int($rating) || $rating < 1 || $rating > 5)) {
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

$issueValue = (is_string($issue) && trim($issue) !== '') ? trim($issue) : null;
$suggestionValue = (is_string($suggestion) && trim($suggestion) !== '') ? trim($suggestion) : null;

if ($rating === null && $issueValue === null && $suggestionValue === null) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'At least one of rating, issue, or suggestion is required'
    ]);
    exit;
}

try {
    $stmt = $con->prepare(Queries::insertAppReviewQuery());
    $stmt->execute([
        ':rating' => $rating,
        ':issue' => $issueValue,
        ':suggestion' => $suggestionValue,
        ':app_version' => $appVersion,
        ':platform' => $platform,
    ]);

    $reviewId = (int)$con->lastInsertId();

    echo json_encode([
        'status' => 'success',
        'data' => [
            'review_id' => $reviewId,
            'message' => 'App review saved successfully'
        ]
    ]);

} catch (PDOException $e) {
    error_log('upsert_review error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Database error'
    ]);
} catch (Exception $e) {
    error_log('upsert_review error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Server error'
    ]);
}
