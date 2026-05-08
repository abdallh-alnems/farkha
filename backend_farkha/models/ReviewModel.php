<?php

final class ReviewModel {
    public static function insert(?int $userId, ?string $deviceId, ?int $rating, ?string $issue, ?string $suggestion, ?string $appVersion, ?string $platform): int {
        Database::execute(
            "INSERT INTO app_reviews (user_id, device_id, rating, issue, suggestion, app_version, platform)
             VALUES (:uid, :did, :rating, :issue, :suggestion, :ver, :platform)",
            [
                ':uid' => $userId,
                ':did' => $deviceId,
                ':rating' => $rating,
                ':issue' => $issue,
                ':suggestion' => $suggestion,
                ':ver' => $appVersion,
                ':platform' => $platform,
            ]
        );
        return (int) Database::lastInsertId();
    }

    public static function fetchByUserId(int $userId): ?array {
        return Database::fetchOne(
            "SELECT * FROM app_reviews WHERE user_id = :uid ORDER BY created_at DESC LIMIT 1",
            [':uid' => $userId]
        );
    }

    public static function fetchByDeviceId(string $deviceId): ?array {
        return Database::fetchOne(
            "SELECT * FROM app_reviews WHERE device_id = :did ORDER BY created_at DESC LIMIT 1",
            [':did' => $deviceId]
        );
    }
}
