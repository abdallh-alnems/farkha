<?php

final class OtpService {
    public static function generate(): string {
        return (string) random_int(100000, 999999);
    }

    public static function hash(string $otp): string {
        $secret = getenv('OTP_HMAC_SECRET');
        if (empty($secret)) {
            throw new RuntimeException('OTP_HMAC_SECRET is not configured');
        }
        return hash_hmac('sha256', $otp, $secret);
    }

    public static function verify(string $otp, string $hash): bool {
        return hash_equals(self::hash($otp), $hash);
    }

    public static function generateSessionToken(): string {
        return bin2hex(random_bytes(16));
    }

    public static function generateVerifiedToken(): string {
        return bin2hex(random_bytes(16));
    }
}
