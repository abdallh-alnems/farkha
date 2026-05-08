<?php

final class FeedbackModel {
    public static function insert(int $userId, int $rating, ?string $issue, ?string $suggestion, ?string $appVersion, ?string $platform, ?int $cycleId = null): int {
        Database::execute(
            "INSERT INTO cycle_feedbacks (user_id, cycle_id, rating, issue, suggestion, app_version, platform)
             VALUES (:uid, :cid, :rating, :issue, :suggestion, :ver, :platform)",
            [
                ':uid' => $userId,
                ':cid' => $cycleId,
                ':rating' => $rating,
                ':issue' => $issue,
                ':suggestion' => $suggestion,
                ':ver' => $appVersion,
                ':platform' => $platform,
            ]
        );
        return (int) Database::lastInsertId();
    }
}
