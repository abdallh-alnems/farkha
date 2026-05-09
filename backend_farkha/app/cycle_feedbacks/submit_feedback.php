<?php

require_once __DIR__ . '/../../config/bootstrap.php';

RateLimiter::enforceIpLimit();

$auth = Auth::authenticateUser(db());
$userId = $auth['user_id'];
$input = $auth['input'];

$rating = $input['rating'] ?? null;
if ($rating !== null && is_string($rating)) {
    $rating = (int) $rating;
}
if ($rating === null || !is_int($rating) || $rating < 1 || $rating > 5) {
    Response::fail('rating must be between 1 and 5', 400);
}

$issue = $input['issue'] ?? null;
$suggestion = $input['suggestion'] ?? null;
$appVersion = $input['app_version'] ?? null;
$platform = $input['platform'] ?? null;
$cycleId = $input['cycle_id'] ?? null;
if ($cycleId !== null) {
    $cycleId = (int) Validator::numeric($cycleId, 'cycle_id', 1);
}

$issueValue = (is_string($issue) && trim($issue) !== '') ? trim($issue) : null;
if ($issueValue !== null) {
    $issueValue = Validator::maxLength($issueValue, 500, 'issue');
}

$suggestionValue = (is_string($suggestion) && trim($suggestion) !== '') ? trim($suggestion) : null;
if ($suggestionValue !== null) {
    $suggestionValue = Validator::maxLength($suggestionValue, 500, 'suggestion');
}

if ($appVersion !== null) {
    Validator::maxLength((string) $appVersion, 20, 'app_version');
}

if ($platform !== null) {
    Validator::enum($platform, ['android', 'ios'], 'platform');
}

try {
    $feedbackId = FeedbackModel::insert($userId, $rating, $issueValue, $suggestionValue, $appVersion, $platform, $cycleId);

    Response::success([
        'feedback_id' => $feedbackId,
        'message' => 'Feedback saved successfully',
    ]);
} catch (PDOException $e) {
    error_log("submit_feedback error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
