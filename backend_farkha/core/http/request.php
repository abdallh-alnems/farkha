<?php

function filterRequest($key, $default = null) {
    $value = $_POST[$key] ?? $_GET[$key] ?? $default;
    return ApiValidator::sanitizeInput($value);
}

class RequestHelper {
    public static function getField($field, $default = null) {
        if (isset($_POST[$field])) {
            return filterRequest($field);
        } elseif (isset($_GET[$field])) {
            return filterRequest($field);
        }
        return $default;
    }

    public static function getFields($fields) {
        $result = [];
        foreach ($fields as $field) {
            $result[$field] = self::getField($field);
        }
        return $result;
    }

    public static function hasField($field) {
        return isset($_POST[$field]) || isset($_GET[$field]);
    }
}

?>


