<?php

require_once __DIR__ . '/../config/firebase.php';

use Kreait\Firebase\Exception\Auth\FailedToVerifyToken;

final class Auth {
    public static function verifyFirebaseToken(string $token) {
        if (empty($token)) {
            Response::fail('Token is required', 400);
        }

        try {
            return FirebaseInit::getAuth()->verifyIdToken($token, false, 60);
        } catch (FailedToVerifyToken $e) {
            Response::fail('Invalid or expired token', 401);
        } catch (Exception $e) {
            error_log('Token verification error: ' . $e->getMessage());
            Response::fail('Authentication failed', 500);
        }
    }

    public static function getUserIdFromToken(string $token, PDO $con): ?int {
        try {
            $verifiedToken = self::verifyFirebaseToken($token);
            $uid = $verifiedToken->claims()->get('sub');
            $stmt = $con->prepare("SELECT id FROM users WHERE firebase_uid = ? LIMIT 1");
            $stmt->execute([$uid]);
            $user = $stmt->fetch();
            return $user ? (int) $user['id'] : null;
        } catch (Exception $e) {
            return null;
        }
    }

    public static function authenticateUser(PDO $con): array {
        $input = json_decode(file_get_contents('php://input'), true);
        $token = $input['token'] ?? null;
        if (!$token) {
            Response::fail('Token is required', 400);
        }
        $verifiedToken = self::verifyFirebaseToken($token);
        $uid = $verifiedToken->claims()->get('sub');
        $userId = self::getUserIdFromToken($token, $con);
        if (!$userId) {
            Response::fail('User not found', 404);
        }
        return ['user_id' => $userId, 'uid' => $uid, 'input' => $input];
    }

    public static function requirePost(): void {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            Response::fail('Method not allowed. Use POST.', 405);
        }
    }

    public static function checkAppCheck(): void {
        RateLimiter::enforceIpLimit();
        $appCheckToken = $_SERVER['HTTP_X_FIREBASE_APPCHECK'] ?? null;
        if ($appCheckToken) {
            self::verifyAppCheckToken($appCheckToken);
        }
    }

    public static function requireAppCheck(): void {
        RateLimiter::enforceIpLimit();
        $appCheckToken = $_SERVER['HTTP_X_FIREBASE_APPCHECK'] ?? null;
        if (!$appCheckToken) {
            Response::fail('App Check token required', 401);
        }
        self::verifyAppCheckToken($appCheckToken);
    }

    private static function verifyAppCheckToken(string $token): void {
        try {
            $appCheck = \Kreait\Firebase\AppCheck::createFromAppComponent(FirebaseInit::getAuth()->getApp());
            $appCheck->verifyToken($token);
        } catch (Exception $e) {
            error_log('App Check verification failed: ' . $e->getMessage());
            Response::fail('Invalid App Check token', 401);
        }
    }

    public static function deleteFirebaseUser(string $uid): bool {
        try {
            FirebaseInit::getAuth()->deleteUser($uid);
            return true;
        } catch (Exception $e) {
            error_log('Firebase delete user error: ' . $e->getMessage());
            return false;
        }
    }
}
