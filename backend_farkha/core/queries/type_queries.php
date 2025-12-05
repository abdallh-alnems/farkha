<?php

final class TypeQueries {
    public static function fetchMainCategories(): string {
        return "SELECT * FROM `main`";
    }

    public static function fetchTypesList(): string {
        return "
            SELECT 
                t.id,
                t.name,
                m.name AS type_main_name
            FROM types t
            JOIN main m ON t.main = m.id
            ORDER BY t.id
        ";
    }
}

?>


