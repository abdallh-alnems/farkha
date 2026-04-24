<?php

final class AppReviewQueries {
    public static function insert(): string {
        return "INSERT INTO app_reviews
                    (rating, issue, suggestion, app_version, platform)
                VALUES
                    (:rating, :issue, :suggestion, :app_version, :platform)";
    }
}
?>
