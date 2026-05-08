<?php

final class Validator {
    public static function sanitizeInput($input) {
        if (is_array($input)) {
            return array_map([self::class, 'sanitizeInput'], $input);
        }
        return is_string($input) ? trim($input) : $input;
    }

    public static function required($value, string $fieldName): void {
        if (empty($value) && $value !== '0' && $value !== 0) {
            Response::fail("{$fieldName} is required", 400);
        }
    }

    public static function numeric($value, string $fieldName, float $min = 0): float {
        if (!is_numeric($value) || (float) $value < $min) {
            Response::fail("Valid {$fieldName} is required", 400);
        }
        return (float) $value;
    }

    public static function maxLength(string $value, int $max, string $fieldName): string {
        if (mb_strlen($value) > $max) {
            Response::fail("{$fieldName} must be at most {$max} characters", 400);
        }
        return $value;
    }

    public static function enum(string $value, array $allowed, string $fieldName): string {
        if (!in_array($value, $allowed, true)) {
            Response::fail("Invalid {$fieldName}", 400);
        }
        return $value;
    }

    public static function mainType($type): ?int {
        if (empty($type)) return null;
        $type = (int) $type;
        return $type > 0 ? $type : null;
    }

    public static function sanitizeTypeIds($input): array {
        if (empty($input)) return [];
        $ids = is_array($input) ? $input : explode(',', $input);
        return array_slice(
            array_unique(
                array_filter(
                    array_map('intval', array_map('trim', $ids)),
                    fn($id) => $id > 0
                )
            ),
            0, 50
        );
    }

    public static function phone(string $phone): ?string {
        $arabic = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
        $english = ['0','1','2','3','4','5','6','7','8','9'];
        $cleaned = str_replace($arabic, $english, $phone);
        $cleaned = preg_replace('/[^0-9+]/', '', $cleaned);

        if (preg_match('/^01[0-9]{9}$/', $cleaned)) {
            return '+20' . substr($cleaned, 1);
        }
        if (preg_match('/^\+201[0-9]{9}$/', $cleaned)) {
            return $cleaned;
        }
        if (preg_match('/^201[0-9]{9}$/', $cleaned)) {
            return '+' . $cleaned;
        }
        return null;
    }

    public static function getField(string $field, $default = null) {
        $value = $_POST[$field] ?? $_GET[$field] ?? $default;
        return self::sanitizeInput($value);
    }

    public static function getJsonBody(): array {
        static $body = null;
        if ($body === null) {
            $raw = file_get_contents('php://input');
            $body = json_decode($raw, true) ?: [];
        }
        return $body;
    }

    public static function getJsonField(string $field, $default = null) {
        return self::getJsonBody()[$field] ?? $default;
    }

    public static function getCombinedField(string $field, $default = null) {
        $jsonVal = self::getJsonField($field);
        if ($jsonVal !== null) return $jsonVal;
        return self::getField($field, $default);
    }
}
