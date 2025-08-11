<?php

/**
 * Application Configuration
 */

class AppConfig
{
    public static function getConfig()
    {
        return [
            'name' => $_ENV['APP_NAME'] ?? 'Farkha API',
            'version' => '2.0',
            'debug' => filter_var($_ENV['APP_DEBUG'] ?? false, FILTER_VALIDATE_BOOLEAN),
            'timezone' => $_ENV['APP_TIMEZONE'] ?? 'Asia/Riyadh',
            'cors' => [
                'allowed_origins' => explode(',', $_ENV['CORS_ALLOWED_ORIGINS'] ?? '*'),
                'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
                'allowed_headers' => [
                    'Content-Type',
                    'Authorization',
                    'X-Requested-With',
                    'Access-Control-Allow-Origin'
                ]
            ],
            'auth' => [
                'jwt_secret' => $_ENV['JWT_SECRET'] ?? 'your-secret-key-change-this',
                'jwt_algorithm' => 'HS256',
                'jwt_expiration' => 3600, // 1 hour
                'basic_auth_user' => $_ENV['BASIC_AUTH_USER'] ?? 'NiMs_farkha',
                'basic_auth_pass' => $_ENV['BASIC_AUTH_PASS'] ?? 'Abdallh29512A'
            ]
        ];
    }
}
