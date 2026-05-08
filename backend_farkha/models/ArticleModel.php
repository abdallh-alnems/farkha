<?php

final class ArticleModel {
    public static function fetchDetail(int $id): ?array {
        return Database::fetchOne(
            "SELECT * FROM articles WHERE id = :id AND deleted_at IS NULL LIMIT 1",
            [':id' => $id]
        );
    }

    public static function fetchList(): array {
        return Database::fetchAll("SELECT id, title FROM articles WHERE deleted_at IS NULL ORDER BY id DESC");
    }

    public static function create(string $title, string $content): int {
        Database::execute(
            "INSERT INTO articles (title, content) VALUES (:title, :content)",
            [':title' => $title, ':content' => $content]
        );
        return (int) Database::lastInsertId();
    }

    public static function update(int $id, string $title, string $content): int {
        return Database::execute(
            "UPDATE articles SET title = :title, content = :content WHERE id = :id",
            [':title' => $title, ':content' => $content, ':id' => $id]
        );
    }
}
