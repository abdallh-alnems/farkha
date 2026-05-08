<?php

final class WhatsAppService {
    public static function send(string $phone, string $text): array {
        $apiKey = getenv('WASENDER_API_KEY');
        $apiUrl = getenv('WASENDER_API_URL') ?: 'https://wasenderapi.com/api/send-message';

        if (empty($apiKey)) {
            return ['ok' => false, 'error' => 'WASENDER_API_KEY not configured'];
        }

        $payload = json_encode(['to' => $phone, 'text' => $text]);

        for ($attempt = 0; $attempt < 2; $attempt++) {
            $ch = curl_init($apiUrl);
            curl_setopt_array($ch, [
                CURLOPT_POST => true,
                CURLOPT_POSTFIELDS => $payload,
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_TIMEOUT => 5,
                CURLOPT_HTTPHEADER => [
                    'Content-Type: application/json',
                    'Authorization: Bearer ' . $apiKey,
                ],
            ]);

            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $curlError = curl_errno($ch);
            $curlMsg = curl_error($ch);
            curl_close($ch);

            if ($curlError === CURLE_OPERATION_TIMEDOUT || $curlError !== 0) {
                if ($attempt < 1) {
                    usleep(2000000);
                    continue;
                }
                return ['ok' => false, 'error' => 'Network error: ' . $curlMsg];
            }

            if ($httpCode >= 200 && $httpCode < 300) {
                return ['ok' => true, 'status' => $httpCode];
            }

            return ['ok' => false, 'status' => $httpCode, 'error' => "HTTP {$httpCode}"];
        }

        return ['ok' => false, 'error' => 'Max retries exceeded'];
    }
}
