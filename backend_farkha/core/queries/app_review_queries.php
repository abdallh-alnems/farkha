<?php

final class AppReviewQueries {
    public static function insert(): string {
        return "INSERT INTO app_reviews
                    (rating, issue, suggestion, app_version, platform)
                VALUES
                    (:rating, :issue, :suggestion, :app_version, :platform)";
    }

    public static function fetchByUserId(): string {
        return "SELECT * FROM app_reviews WHERE user_id = :user_id ORDER BY created_at DESC LIMIT 1";
    }

    public static function fetchByDeviceId(): string {
        return "SELECT * FROM app_reviews WHERE device_id = :device_id ORDER BY created_at DESC LIMIT 1";
    }
}
