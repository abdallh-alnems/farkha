<?php

final class AppReviewQueries {
    public static function upsert(): string {
        return "INSERT INTO app_reviews
                    (user_id, rating, issue, suggestion, app_version, platform)
                VALUES
                    (:user_id, :rating, :issue, :suggestion, :app_version, :platform)
                ON DUPLICATE KEY UPDATE
                    rating      = VALUES(rating),
                    issue       = VALUES(issue),
                    suggestion  = VALUES(suggestion),
                    app_version = VALUES(app_version),
                    platform    = VALUES(platform)";
    }

    public static function fetchByUserId(): string {
        return "SELECT id, user_id, rating, issue, suggestion,
                       app_version, platform, created_at, updated_at
                FROM app_reviews
                WHERE user_id = :user_id
                LIMIT 1";
    }

    public static function fetchIdByUserId(): string {
        return "SELECT id FROM app_reviews WHERE user_id = :user_id LIMIT 1";
    }
}

?>
