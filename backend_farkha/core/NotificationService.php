<?php

require_once __DIR__ . '/../config/firebase.php';

use Kreait\Firebase\Messaging\AndroidConfig;
use Kreait\Firebase\Messaging\ApnsConfig;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

final class NotificationService {
    public static function sendToUser(PDO $con, int $userId, string $title, string $body, array $data = []): bool {
        try {
            $stmt = $con->prepare("SELECT fcm_token FROM user_devices WHERE user_id = ?");
            $stmt->execute([$userId]);
            $rows = $stmt->fetchAll();

            if (empty($rows)) {
                return false;
            }

            $stringData = array_map('strval', $data);
            $allOk = true;

            $apnsConfig = ApnsConfig::fromArray([
                'payload' => ['aps' => ['sound' => 'notification_sound.caf']],
            ]);
            $androidConfig = AndroidConfig::fromArray([
                'notification' => [
                    'sound' => 'notification_sound',
                    'channel_id' => 'farkha_notifications_channel',
                ],
            ]);

            foreach ($rows as $row) {
                if (empty($row['fcm_token'])) continue;
                try {
                    $message = CloudMessage::withTarget('token', $row['fcm_token'])
                        ->withNotification(Notification::create($title, $body))
                        ->withData($stringData)
                        ->withApnsConfig($apnsConfig)
                        ->withAndroidConfig($androidConfig);

                    FirebaseInit::getMessaging()->send($message);
                } catch (Exception $e) {
                    error_log("FCM send failed for token {$row['fcm_token']}: " . $e->getMessage());
                    $allOk = false;
                }
            }

            return $allOk;
        } catch (Exception $e) {
            error_log("FCM send failed for user {$userId}: " . $e->getMessage());
            return false;
        }
    }

    public static function sendDataOnlyToUser(PDO $con, int $userId, array $data): bool {
        try {
            $stmt = $con->prepare("SELECT fcm_token FROM user_devices WHERE user_id = ?");
            $stmt->execute([$userId]);
            $rows = $stmt->fetchAll();

            if (empty($rows)) {
                return false;
            }

            $stringData = array_map('strval', $data);
            $allOk = true;

            $apnsConfig = ApnsConfig::fromArray([
                'headers' => ['apns-priority' => '5'],
                'payload' => ['aps' => ['content-available' => 1]],
            ]);

            foreach ($rows as $row) {
                if (empty($row['fcm_token'])) continue;
                try {
                    $message = CloudMessage::withTarget('token', $row['fcm_token'])
                        ->withData($stringData)
                        ->withApnsConfig($apnsConfig);

                    FirebaseInit::getMessaging()->send($message);
                } catch (Exception $e) {
                    error_log("FCM data-only send failed for token {$row['fcm_token']}: " . $e->getMessage());
                    $allOk = false;
                }
            }

            return $allOk;
        } catch (Exception $e) {
            error_log("FCM data-only send failed for user {$userId}: " . $e->getMessage());
            return false;
        }
    }

    private static function base64url_encode(string $data): string {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    public static function broadcastToTopic(string $title, string $body, string $topic, string $pageId, string $pageName): ?string {
        $credentialsPath = __DIR__ . '/firebase_credentials.json';
        if (!file_exists($credentialsPath)) {
            error_log('Firebase credentials not found for topic broadcast');
            return null;
        }

        $sa = json_decode(file_get_contents($credentialsPath), true);

        $jwtHeader = self::base64url_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
        $jwtClaim = self::base64url_encode(json_encode([
            'iss' => $sa['client_email'],
            'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
            'aud' => $sa['token_uri'],
            'iat' => time(),
            'exp' => time() + 3600,
        ]));

        $jwtSig = '';
        openssl_sign("{$jwtHeader}.{$jwtClaim}", $jwtSig, $sa['private_key'], 'sha256');
        $jwt = "{$jwtHeader}.{$jwtClaim}." . self::base64url_encode($jwtSig);

        $ch = curl_init($sa['token_uri']);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => http_build_query([
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ]),
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 10,
        ]);
        $rawTokenResp = curl_exec($ch);
        $curlError = curl_error($ch);
        if ($rawTokenResp === false) {
            error_log('cURL error during OAuth2 token request: ' . $curlError);
            curl_close($ch);
            return null;
        }
        $tokenResp = json_decode($rawTokenResp, true);
        $tokenHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        $accessToken = $tokenResp['access_token'] ?? null;

        if (!$accessToken) {
            error_log('Failed to get OAuth2 access token for FCM. HTTP ' . $tokenHttpCode . ': ' . json_encode($tokenResp));
            return null;
        }

        $projectId = $sa['project_id'] ?? 'farkha-c7248';
        $url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";

        $fields = [
            'message' => [
                'topic' => $topic,
                'notification' => ['title' => $title, 'body' => $body],
                'data' => ['pageid' => (string) $pageId, 'pagename' => $pageName],
                'android' => [
                    'notification' => [
                        'sound' => 'notification_sound',
                        'channel_id' => 'farkha_notifications_channel',
                    ],
                ],
                'apns' => [
                    'payload' => [
                        'aps' => [
                            'sound' => 'notification_sound.caf',
                        ],
                    ],
                ],
            ],
        ];

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_HTTPHEADER => [
                'Authorization: Bearer ' . $accessToken,
                'Content-Type: application/json',
            ],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POSTFIELDS => json_encode($fields),
            CURLOPT_TIMEOUT => 10,
        ]);
        $result = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlError = curl_error($ch);
        curl_close($ch);

        if ($result === false) {
            error_log("FCM topic broadcast cURL error: {$curlError}");
            return null;
        }

        if ($httpCode >= 400) {
            error_log("FCM topic broadcast failed. HTTP {$httpCode}: {$result}. cURL error: {$curlError}");
            return null;
        }

        return $result;
    }

    public static function broadcastDataToTopic(string $topic, array $data): ?string {
        $credentialsPath = __DIR__ . '/firebase_credentials.json';
        if (!file_exists($credentialsPath)) {
            error_log('Firebase credentials not found for data topic broadcast');
            return null;
        }

        $sa = json_decode(file_get_contents($credentialsPath), true);

        $jwtHeader = self::base64url_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
        $jwtClaim = self::base64url_encode(json_encode([
            'iss' => $sa['client_email'],
            'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
            'aud' => $sa['token_uri'],
            'iat' => time(),
            'exp' => time() + 3600,
        ]));

        $jwtSig = '';
        openssl_sign("{$jwtHeader}.{$jwtClaim}", $jwtSig, $sa['private_key'], 'sha256');
        $jwt = "{$jwtHeader}.{$jwtClaim}." . self::base64url_encode($jwtSig);

        $ch = curl_init($sa['token_uri']);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => http_build_query([
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ]),
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 10,
        ]);
        $rawTokenResp = curl_exec($ch);
        $curlError = curl_error($ch);
        if ($rawTokenResp === false) {
            error_log('cURL error during OAuth2 token request for data broadcast: ' . $curlError);
            curl_close($ch);
            return null;
        }
        $tokenResp = json_decode($rawTokenResp, true);
        $tokenHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        $accessToken = $tokenResp['access_token'] ?? null;

        if (!$accessToken) {
            error_log('Failed to get OAuth2 access token for FCM data broadcast. HTTP ' . $tokenHttpCode . ': ' . json_encode($tokenResp));
            return null;
        }

        $projectId = $sa['project_id'] ?? 'farkha-c7248';
        $url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";

        $fields = [
            'message' => [
                'topic' => $topic,
                'data' => array_map('strval', $data),
                'android' => ['priority' => 'high'],
                'apns' => [
                    'headers' => ['apns-priority' => '5'],
                    'payload' => ['aps' => ['content-available' => 1]],
                ],
            ],
        ];

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_HTTPHEADER => [
                'Authorization: Bearer ' . $accessToken,
                'Content-Type: application/json',
            ],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POSTFIELDS => json_encode($fields),
            CURLOPT_TIMEOUT => 10,
        ]);
        $result = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlError = curl_error($ch);
        curl_close($ch);

        if ($result === false) {
            error_log("FCM data topic broadcast cURL error: {$curlError}");
            return null;
        }

        if ($httpCode >= 400) {
            error_log("FCM data topic broadcast failed. HTTP {$httpCode}: {$result}");
            return null;
        }

        return $result;
    }
}
