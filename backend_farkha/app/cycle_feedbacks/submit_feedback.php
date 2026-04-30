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

if (!$token) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Token is required'
    ]);
    exit;
}

$userId = getUserIdFromToken($token, $con);
if (!$userId) {
    http_response_code(401);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Invalid token or user not found'
    ]);
    exit;
}

$rating = $input['rating'] ?? null;
if ($rating !== null && is_string($rating)) {
    $rating = (int) $rating;
}
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

$issueValue = (is_string($issue) && trim($issue) !== '') ? trim($issue) : null;
if ($issueValue !== null && mb_strlen($issueValue) > 500) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'issue must be 500 characters or less'
    ]);
    exit;
}

$suggestionValue = (is_string($suggestion) && trim($suggestion) !== '') ? trim($suggestion) : null;
if ($suggestionValue !== null && mb_strlen($suggestionValue) > 500) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'suggestion must be 500 characters or less'
    ]);
    exit;
}

if ($appVersion !== null && mb_strlen((string)$appVersion) > 20) {
    http_response_code(400);
    echo json_encode([
        'status' => 'fail',
        'message' => 'app_version must be 20 characters or less'
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

try {
    $stmt = $con->prepare(Queries::insertCycleFeedbackQuery());
    $stmt->execute([
        ':rating' => $rating,
        ':issue' => $issueValue,
        ':suggestion' => $suggestionValue,
        ':app_version' => $appVersion,
        ':platform' => $platform,
    ]);

    $feedbackId = (int)$con->lastInsertId();

    echo json_encode([
        'status' => 'success',
        'data' => [
            'feedback_id' => $feedbackId,
            'message' => 'Feedback saved successfully'
        ]
    ]);

} catch (PDOException $e) {
    error_log('submit_feedback error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Database error'
    ]);
} catch (Exception $e) {
    error_log('submit_feedback error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'status' => 'fail',
        'message' => 'Server error'
    ]);
}
