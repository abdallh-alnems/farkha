<?php

require_once __DIR__ . '/../vendor/autoload.php';

use Kreait\Firebase\Factory;
use Kreait\Firebase\AppCheck;
use Kreait\Firebase\Exception\AppCheck\FailedToVerifyAppCheckToken;

function getAppCheck(): AppCheck {
    static $instance = null;
    if ($instance === null) {
        $serviceAccountPath = __DIR__ . '/firebase_credentials.json';

        if (!file_exists($serviceAccountPath)) {
            throw new Exception('Firebase credentials not found');
        }

        $instance = (new Factory)
            ->withServiceAccount($serviceAccountPath)
            ->createAppCheck();
    }
    return $instance;
}

function verifyAppCheckToken(?string $token): void {
    if (!$token) {
        http_response_code(401);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['status' => 'fail', 'message' => 'App Check token is required']);
        exit;
    }

    try {
        $appCheck = getAppCheck();
        $appCheck->verifyToken($token);
    } catch (FailedToVerifyAppCheckToken $e) {
        error_log('App Check verification failed: ' . $e->getMessage());
        http_response_code(401);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['status' => 'fail', 'message' => 'Invalid App Check token']);
        exit;
    } catch (Exception $e) {
        error_log('App Check error: ' . $e->getMessage());
        http_response_code(401);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['status' => 'fail', 'message' => 'App Check verification failed']);
        exit;
    }
}
