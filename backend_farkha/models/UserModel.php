<?php

final class UserModel {
    public static function findByFirebaseUid(string $uid): ?array {
        return Database::fetchOne(
            "SELECT * FROM users WHERE firebase_uid = :uid AND deleted_at IS NULL LIMIT 1",
            [':uid' => $uid]
        );
    }

    public static function findById(int $id): ?array {
        return Database::fetchOne(
            "SELECT * FROM users WHERE id = :id AND deleted_at IS NULL LIMIT 1",
            [':id' => $id]
        );
    }

    public static function create(string $firebaseUid, string $name, ?string $phone = null): int {
        Database::execute(
            "INSERT INTO users (firebase_uid, name, phone) VALUES (:uid, :name, :phone)",
            [':uid' => $firebaseUid, ':name' => $name, ':phone' => $phone]
        );
        return (int) Database::lastInsertId();
    }

    public static function updateName(string $firebaseUid, string $name): void {
        Database::execute(
            "UPDATE users SET name = :name WHERE firebase_uid = :uid",
            [':name' => $name, ':uid' => $firebaseUid]
        );
    }

    public static function updatePhoneVerified(int $userId, string $phone): void {
        Database::execute(
            "UPDATE users SET phone = :phone WHERE id = :id",
            [':phone' => $phone, ':id' => $userId]
        );
    }

    public static function updateFcmToken(string $firebaseUid, string $token): void {
        Database::execute(
            "UPDATE users SET fcm_token = :token WHERE firebase_uid = :uid",
            [':token' => $token, ':uid' => $firebaseUid]
        );
    }

    public static function clearPhoneForOtherUsers(string $phone, int $userId): void {
        Database::execute(
            "UPDATE users SET phone = NULL WHERE phone = :phone AND id != :id",
            [':phone' => $phone, ':id' => $userId]
        );
    }

    public static function deleteByFirebaseUid(string $uid): void {
        Database::execute(
            "UPDATE users SET deleted_at = NOW(), fcm_token = NULL WHERE firebase_uid = :uid",
            [':uid' => $uid]
        );
    }

    public static function searchByPhone(string $searchTerm, string $excludeUid): array {
        return Database::fetchAll(
            "SELECT id, name, phone FROM users WHERE phone LIKE :search AND firebase_uid != :uid AND deleted_at IS NULL LIMIT 10",
            [':search' => $searchTerm, ':uid' => $excludeUid]
        );
    }

    public static function findByPhone(string $phone): ?array {
        return Database::fetchOne(
            "SELECT * FROM users WHERE phone = :phone AND deleted_at IS NULL LIMIT 1",
            [':phone' => $phone]
        );
    }
}
