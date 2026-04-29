<?php

final class CycleFeedbackQueries {
    public static function insert(): string {
        return "INSERT INTO cycle_feedbacks
                    (rating, issue, suggestion, app_version, platform)
                VALUES
                    (:rating, :issue, :suggestion, :app_version, :platform)";
    }
}
?>
