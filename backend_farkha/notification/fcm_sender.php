<?php

/**
 * Firebase Cloud Messaging (FCM) Sender
 * 
 * This file contains functions for sending push notifications via Firebase Cloud Messaging.
 * Handles FCM authentication and message sending.
 */

/**
 * Send Firebase Cloud Messaging notification
 * 
 * @param string $title Notification title
 * @param string $message Notification message body
 * @param string $topic FCM topic to send notification to
 * @param string $pageid Page ID for navigation data
 * @param string $pagename Page name for navigation data
 * @return string JSON response from FCM API
 */
function sendFCM($title, $message, $topic, $pageid, $pagename)
{
    // Load Firebase credentials from secure config file
    $configPath = __DIR__ . '/firebase_config.php';
    
    if (!file_exists($configPath)) {
        error_log("Firebase config file not found. Please create firebase_config.php with your Firebase credentials");
        return json_encode([
            'error' => 'Firebase configuration not found',
            'message' => 'Server configuration error'
        ]);
    }
    
    $serviceAccount = require $configPath;

    // 1️⃣ إنشاء JWT
    $jwtHeader = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
    $jwtClaim = base64_encode(json_encode([
        'iss' => $serviceAccount['client_email'],
        'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
        'aud' => $serviceAccount['token_uri'],
        'iat' => time(),
        'exp' => time() + 3600
    ]));

    $jwtSignature = '';
    openssl_sign("$jwtHeader.$jwtClaim", $jwtSignature, $serviceAccount['private_key'], 'sha256');
    $jwt = "$jwtHeader.$jwtClaim." . base64_encode($jwtSignature);

    // 2️⃣ جلب Access Token
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $serviceAccount['token_uri']);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
        'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion' => $jwt
    ]));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    $token = json_decode($response, true)['access_token'];
    curl_close($ch);

    // 3️⃣ إرسال الإشعار
    $projectId = $serviceAccount['project_id'] ?? 'farkha-c7248';
    $url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";

    $fields = [
        "message" => [
            "topic" => $topic,
            "notification" => [
                "title" => $title,
                "body" => $message,
            ],
            "data" => [
                "pageid" => $pageid,
                "pagename" => $pagename,
            ],
        ]
    ];

    $headers = [
        'Authorization: Bearer ' . $token,
        'Content-Type: application/json'
    ];

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));

    $result = curl_exec($ch);
    curl_close($ch);

    return $result;
}

?>
