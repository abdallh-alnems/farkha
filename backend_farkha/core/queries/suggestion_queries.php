<?php

final class SuggestionQueries {
    public static function insert(): string {
        return "INSERT INTO suggestions (suggestions_text) VALUES (:suggestions_text)";
    }

    public static function fetchList(): string {
        return "SELECT suggestions_text, date FROM suggestions ORDER BY date DESC";
    }
}

?>

