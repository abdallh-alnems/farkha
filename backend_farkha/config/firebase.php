<?php

require_once __DIR__ . '/../vendor/autoload.php';

use Kreait\Firebase\Factory;
use Kreait\Firebase\Auth;
use Kreait\Firebase\Messaging;

class FirebaseInit {
    private static ?Factory $factory = null;
    private static ?Auth $auth = null;
    private static ?Messaging $messaging = null;

    private static function getFactory(): Factory {
        if (self::$factory === null) {
            $credentialsPath = __DIR__ . '/../core/firebase_credentials.json';
            if (!file_exists($credentialsPath)) {
                throw new RuntimeException('Firebase credentials file not found');
            }
            self::$factory = (new Factory)->withServiceAccount($credentialsPath);
        }
        return self::$factory;
    }

    public static function getAuth(): Auth {
        if (self::$auth === null) {
            self::$auth = self::getFactory()->createAuth();
        }
        return self::$auth;
    }

    public static function getMessaging(): Messaging {
        if (self::$messaging === null) {
            self::$messaging = self::getFactory()->createMessaging();
        }
        return self::$messaging;
    }
}
