<?php

function _get_otp_secret(): string {
    $secret = getenv('OTP_HMAC_SECRET') ?: ($_ENV['OTP_HMAC_SECRET'] ?? '');
    if (empty($secret)) {
        throw new RuntimeException('OTP_HMAC_SECRET is not configured. Generate with: openssl rand -hex 32');
    }
    return $secret;
}

function generate_otp(): string {
    return (string) random_int(100000, 999999);
}

function hash_otp(string $otp): string {
    return hash_hmac('sha256', $otp, _get_otp_secret());
}

function verify_otp_hash(string $otp, string $hash): bool {
    return hash_equals(hash_otp($otp), $hash);
}

function normalize_egypt_phone(string $raw): ?string {
    $arabicDigits = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    $englishDigits = ['0','1','2','3','4','5','6','7','8','9'];
    $cleaned = str_replace($arabicDigits, $englishDigits, $raw);
    $cleaned = preg_replace('/[^0-9+]/', '', $cleaned);

    if (preg_match('/^01[0-9]{9}$/', $cleaned)) {
        return '+20' . substr($cleaned, 1);
    }

    if (preg_match('/^\+201[0-9]{9}$/', $cleaned)) {
        return $cleaned;
    }

    if (preg_match('/^201[0-9]{9}$/', $cleaned)) {
        return '+' . $cleaned;
    }

    return null;
}
