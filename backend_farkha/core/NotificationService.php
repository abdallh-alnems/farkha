<?php

require_once __DIR__ . '/../config/firebase.php';

use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

final class NotificationService {
    public static function sendToUser(PDO $con, int $userId, string $title, string $body, array $data = []): bool {
        try {
            $stmt = $con->prepare("SELECT fcm_token FROM user_devices WHERE user_id = ?");
            $stmt->execute([$userId]);
            $rows = $stmt->fetchAll();

            if (empty($rows)) {
                $stmt2 = $con->prepare("SELECT fcm_token FROM users WHERE id = ?");
                $stmt2->execute([$userId]);
                $fallback = $stmt2->fetch();
                if (!$fallback || empty($fallback['fcm_token'])) {
                    return false;
                }
                $rows = [['fcm_token' => $fallback['fcm_token']]];
            }

            $stringData = array_map('strval', $data);
            $allOk = true;

            foreach ($rows as $row) {
                if (empty($row['fcm_token'])) continue;
                try {
                    $message = CloudMessage::withTarget('token', $row['fcm_token'])
                        ->withNotification(Notification::create($title, $body))
                        ->withData($stringData);

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

    public static function broadcastToTopic(string $title, string $body, string $topic, string $pageId, string $pageName): ?string {
        $credentialsPath = __DIR__ . '/firebase_credentials.json';
        if (!file_exists($credentialsPath)) {
            error_log('Firebase credentials not found for topic broadcast');
            return null;
        }

        $sa = json_decode(file_get_contents($credentialsPath), true);

        $jwtHeader = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
        $jwtClaim = base64_encode(json_encode([
            'iss' => $sa['client_email'],
            'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
            'aud' => $sa['token_uri'],
            'iat' => time(),
            'exp' => time() + 3600,
        ]));

        $jwtSig = '';
        openssl_sign("{$jwtHeader}.{$jwtClaim}", $jwtSig, $sa['private_key'], 'sha256');
        $jwt = "{$jwtHeader}.{$jwtClaim}." . base64_encode($jwtSig);

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
        $tokenResp = json_decode(curl_exec($ch), true);
        curl_close($ch);
        $accessToken = $tokenResp['access_token'] ?? null;

        if (!$accessToken) {
            error_log('Failed to get OAuth2 access token for FCM');
            return null;
        }

        $projectId = $sa['project_id'] ?? 'farkha-c7248';
        $url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";

        $fields = [
            'message' => [
                'topic' => $topic,
                'notification' => ['title' => $title, 'body' => $body],
                'data' => ['pageid' => (string) $pageId, 'pagename' => $pageName],
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
        curl_close($ch);

        return $result;
    }
}
