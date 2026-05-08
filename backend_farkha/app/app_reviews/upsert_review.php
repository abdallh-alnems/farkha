<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::checkAppCheck();
Auth::requirePost();

$input = Validator::getJsonBody();
$token = $input['token'] ?? null;

if (!$token) {
    Response::fail('Firebase token is required', 401);
}

$verifiedToken = Auth::verifyFirebaseToken($token);
$uid = $verifiedToken->claims()->get('sub');

$user = UserModel::findByFirebaseUid($uid);
if (!$user) {
    Response::fail('User not found', 404);
}

$userId = (int) $user['id'];

$rating = $input['rating'] ?? null;
if ($rating !== null && is_string($rating)) {
    $rating = (int) $rating;
}
if ($rating !== null && (!is_int($rating) || $rating < 1 || $rating > 5)) {
    Response::fail('rating must be between 1 and 5', 400);
}

$issue = $input['issue'] ?? null;
$suggestion = $input['suggestion'] ?? null;
$appVersion = $input['app_version'] ?? null;
$platform = $input['platform'] ?? null;

$issueValue = (is_string($issue) && trim($issue) !== '') ? trim($issue) : null;
$suggestionValue = (is_string($suggestion) && trim($suggestion) !== '') ? trim($suggestion) : null;

if ($issueValue !== null) {
    $issueValue = Validator::maxLength($issueValue, 500, 'issue');
}
if ($suggestionValue !== null) {
    $suggestionValue = Validator::maxLength($suggestionValue, 500, 'suggestion');
}

if ($rating === null && $issueValue === null && $suggestionValue === null) {
    Response::fail('At least one of rating, issue, or suggestion is required', 400);
}

try {
    $reviewId = ReviewModel::insert($userId, null, $rating, $issueValue, $suggestionValue, $appVersion, $platform);

    Response::success([
        'review_id' => $reviewId,
        'message' => 'App review saved successfully',
    ]);
} catch (PDOException $e) {
    error_log("upsert_review error: " . $e->getMessage());
    Response::fail('Database error', 500);
}
