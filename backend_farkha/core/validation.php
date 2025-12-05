<?php

class ApiValidator {
    public static function sanitizeInput($input) {
        if (is_array($input)) {
            return array_map([self::class, 'sanitizeInput'], $input);
        }
        return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
    }
}

class ValidationHelper {
    public static function validateNumeric($value, $min = 0) {
        return !empty($value) && is_numeric($value) && $value >= $min;
    }

    public static function validateRequired($value, $fieldName) {
        if (empty($value)) {
            throw new Exception("{$fieldName} is required");
        }
        return $value;
    }

    public static function sanitizeTypeIds($input) {
        if (empty($input)) return [];

        $type_ids = is_array($input) ? $input : explode(',', $input);
        $sanitized = array_unique(array_filter(array_map('trim', $type_ids), function($id) {
            return is_numeric($id) && $id > 0;
        }));

        return array_slice($sanitized, 0, 50);
    }

    public static function validateMainType($type) {
        if (empty($type)) return null;
        $type = (int) $type;
        return $type > 0 ? $type : null;
    }
}

?>


