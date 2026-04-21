<?php

function send_whatsapp(string $phone, string $text): array {
    $apiKey = getenv('WASENDER_API_KEY') ?: ($_ENV['WASENDER_API_KEY'] ?? '');
    $apiUrl = getenv('WASENDER_API_URL') ?: ($_ENV['WASENDER_API_URL'] ?? 'https://wasenderapi.com/api/send-message');

    if (empty($apiKey)) {
        return ['ok' => false, 'provider_status' => 0, 'error' => 'WASENDER_API_KEY not configured'];
    }

    $payload = json_encode([
        'to' => $phone,
        'text' => $text,
    ]);

    $attempt = 0;
    $maxAttempts = 2;
    $response = false;
    $httpCode = 0;

    while ($attempt < $maxAttempts) {
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
        $curlErrorMsg = curl_error($ch);
        curl_close($ch);

        if ($curlError === CURLE_OPERATION_TIMEDOUT || $curlError !== 0) {
            $attempt++;
            if ($attempt < $maxAttempts) {
                usleep(2000000);
                continue;
            }
            return ['ok' => false, 'provider_status' => $httpCode, 'error' => 'Network error: ' . $curlErrorMsg];
        }

        break;
    }

    if ($httpCode >= 200 && $httpCode < 300) {
        return ['ok' => true, 'provider_status' => $httpCode, 'error' => null];
    }

    return ['ok' => false, 'provider_status' => $httpCode, 'error' => 'HTTP ' . $httpCode . ': ' . $response];
}
