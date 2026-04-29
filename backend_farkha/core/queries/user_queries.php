<?php

final class UserQueries {
    public static function findByFirebaseUid(): string {
        return "SELECT * FROM users WHERE firebase_uid = :firebase_uid LIMIT 1";
    }

    public static function insert(): string {
        return "INSERT INTO users (firebase_uid, name)
                VALUES (:firebase_uid, :name)";
    }

    public static function updateName(): string {
        return "UPDATE users SET name = :name WHERE firebase_uid = :firebase_uid";
    }

    public static function updatePhone(): string {
        return "UPDATE users SET phone = :phone WHERE firebase_uid = :firebase_uid";
    }

    public static function deleteByFirebaseUid(): string {
        return "DELETE FROM users WHERE firebase_uid = :firebase_uid";
    }

    public static function findByPhone(): string {
        return "SELECT * FROM users WHERE phone = :phone LIMIT 1";
    }

    public static function searchByPhone(): string {
        return "SELECT id, name, phone FROM users WHERE phone LIKE :search_term LIMIT 10";
    }

    public static function searchByPhoneExcludeUid(): string {
        return "SELECT id, phone FROM users WHERE phone LIKE :search_term AND firebase_uid != :firebase_uid LIMIT 10";
    }

    public static function updatePhoneVerified(): string {
        return "UPDATE users SET phone = :phone WHERE id = :user_id";
    }

    public static function clearPhoneForOtherUsers(): string {
        return "UPDATE users SET phone = NULL WHERE phone = :phone AND id != :user_id";
    }

    public static function insertPhoneVerification(): string {
        return "INSERT INTO phone_verifications (user_id, phone, otp_hash, session_token, expires_at, attempts_remaining, resend_count, status)
                VALUES (:user_id, :phone, :otp_hash, :session_token, DATE_ADD(NOW(), INTERVAL :expiry_minutes MINUTE), 5, 0, 'pending')";
    }

    public static function findLatestPendingByUserPhone(): string {
        return "SELECT pv.id, pv.session_token, pv.resend_count, pv.expires_at, TIMESTAMPDIFF(SECOND, pv.updated_at, NOW()) AS seconds_since_update, TIMESTAMPDIFF(SECOND, NOW(), pv.expires_at) AS seconds_until_expiry FROM phone_verifications pv WHERE pv.user_id = :user_id AND pv.phone = :phone AND pv.status = 'pending' ORDER BY pv.id DESC LIMIT 1 FOR UPDATE";
    }

    public static function findLatestPendingByUser(): string {
        return "SELECT pv.id, pv.phone, pv.session_token, pv.resend_count, pv.expires_at, TIMESTAMPDIFF(SECOND, pv.updated_at, NOW()) AS seconds_since_update, TIMESTAMPDIFF(SECOND, NOW(), pv.expires_at) AS seconds_until_expiry FROM phone_verifications pv WHERE pv.user_id = :user_id AND pv.status = 'pending' ORDER BY pv.id DESC LIMIT 1";
    }

    public static function findActivePhoneVerificationBySession(): string {
        return "SELECT pv.*, u.firebase_uid, TIMESTAMPDIFF(SECOND, pv.updated_at, NOW()) AS seconds_since_update, TIMESTAMPDIFF(SECOND, NOW(), pv.expires_at) AS seconds_until_expiry, TIMESTAMPDIFF(SECOND, NOW(), pv.locked_until) AS seconds_until_lock_expiry FROM phone_verifications pv JOIN users u ON pv.user_id = u.id WHERE pv.session_token = :session_token AND pv.status = 'pending' LIMIT 1 FOR UPDATE";
    }

    public static function findPhoneVerificationByVerifiedToken(): string {
        return "SELECT pv.*, u.firebase_uid FROM phone_verifications pv JOIN users u ON pv.user_id = u.id WHERE pv.verified_token = :verified_token AND pv.verified_token_expires_at > NOW() LIMIT 1";
    }

    public static function updatePhoneVerificationAttempts(): string {
        return "UPDATE phone_verifications SET attempts_remaining = :attempts_remaining, status = :status, locked_until = :locked_until WHERE id = :id";
    }

    public static function updatePhoneVerificationStatus(): string {
        return "UPDATE phone_verifications SET status = :status, verified_token = :verified_token, verified_token_expires_at = DATE_ADD(NOW(), INTERVAL 5 MINUTE) WHERE id = :id";
    }

    public static function updatePhoneVerificationResend(): string {
        return "UPDATE phone_verifications SET otp_hash = :otp_hash, expires_at = DATE_ADD(NOW(), INTERVAL :expiry_minutes MINUTE), attempts_remaining = 5, resend_count = resend_count + 1, updated_at = NOW() WHERE id = :id";
    }

    public static function expireStalePhoneVerifications(): string {
        return "UPDATE phone_verifications SET status = 'expired' WHERE user_id = :user_id AND phone = :phone AND status = 'pending' AND id != :exclude_id";
    }

    public static function countPendingVerificationsByUser(): string {
        return "SELECT COUNT(*) as cnt FROM phone_verifications WHERE user_id = :user_id AND status = 'pending' AND created_at > DATE_SUB(NOW(), INTERVAL 15 MINUTE)";
    }

    public static function consumeVerifiedToken(): string {
        return "UPDATE phone_verifications SET verified_token = NULL WHERE id = :id";
    }
}

?>
