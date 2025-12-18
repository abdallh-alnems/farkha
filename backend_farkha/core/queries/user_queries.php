<?php

final class UserQueries {
    public static function findByFirebaseUid(): string {
        return "SELECT * FROM users WHERE firebase_uid = :firebase_uid LIMIT 1";
    }

    public static function insert(): string {
        return "INSERT INTO users (firebase_uid, name)
                VALUES (:firebase_uid, :name)";
    }

    public static function updateName(): string {
        return "UPDATE users SET name = :name WHERE firebase_uid = :firebase_uid";
    }

    public static function updatePhone(): string {
        return "UPDATE users SET phone = :phone WHERE firebase_uid = :firebase_uid";
    }

    public static function deleteByFirebaseUid(): string {
        return "DELETE FROM users WHERE firebase_uid = :firebase_uid";
    }
}

?>
