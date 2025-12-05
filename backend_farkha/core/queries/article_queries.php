<?php

final class ArticleQueries {
    public static function fetchDetail(): string {
        return "SELECT content FROM articles WHERE id = :id LIMIT 1";
    }

    public static function fetchList(): string {
        return "SELECT id, title FROM articles ORDER BY id DESC";
    }

    public static function insert(): string {
        return "INSERT INTO articles (title, content) VALUES (:title, :content)";
    }

    public static function updateWithValidation(): string {
        return "UPDATE articles 
                SET title = :title, content = :content 
                WHERE id = :id 
                AND EXISTS (
                    SELECT 1 FROM articles a 
                    WHERE a.id = :id2
                )";
    }
}

?>


