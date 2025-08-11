<?php

/**
 * Input Validation Utility
 */
class Validator
{
    private $errors = [];
    private $data = [];

    public function __construct($data = [])
    {
        $this->data = $data;
    }

    /**
     * Validate required field
     */
    public function required($field, $message = null)
    {
        if (!isset($this->data[$field]) || empty(trim($this->data[$field]))) {
            $this->errors[$field][] = $message ?: "Field {$field} is required";
        }
        return $this;
    }

    /**
     * Validate numeric field
     */
    public function numeric($field, $message = null)
    {
        if (isset($this->data[$field]) && !is_numeric($this->data[$field])) {
            $this->errors[$field][] = $message ?: "Field {$field} must be numeric";
        }
        return $this;
    }

    /**
     * Validate minimum length
     */
    public function minLength($field, $min, $message = null)
    {
        if (isset($this->data[$field]) && strlen(trim($this->data[$field])) < $min) {
            $this->errors[$field][] = $message ?: "Field {$field} must be at least {$min} characters";
        }
        return $this;
    }

    /**
     * Validate maximum length
     */
    public function maxLength($field, $max, $message = null)
    {
        if (isset($this->data[$field]) && strlen(trim($this->data[$field])) > $max) {
            $this->errors[$field][] = $message ?: "Field {$field} must not exceed {$max} characters";
        }
        return $this;
    }

    /**
     * Validate positive number
     */
    public function positive($field, $message = null)
    {
        if (isset($this->data[$field]) && is_numeric($this->data[$field]) && $this->data[$field] <= 0) {
            $this->errors[$field][] = $message ?: "Field {$field} must be a positive number";
        }
        return $this;
    }

    /**
     * Validate integer
     */
    public function integer($field, $message = null)
    {
        if (isset($this->data[$field]) && !filter_var($this->data[$field], FILTER_VALIDATE_INT)) {
            $this->errors[$field][] = $message ?: "Field {$field} must be an integer";
        }
        return $this;
    }

    /**
     * Custom validation
     */
    public function custom($field, $callback, $message = null)
    {
        if (isset($this->data[$field]) && !call_user_func($callback, $this->data[$field])) {
            $this->errors[$field][] = $message ?: "Field {$field} validation failed";
        }
        return $this;
    }

    /**
     * Check if validation passed
     */
    public function passes()
    {
        return empty($this->errors);
    }

    /**
     * Check if validation failed
     */
    public function fails()
    {
        return !$this->passes();
    }

    /**
     * Get validation errors
     */
    public function getErrors()
    {
        return $this->errors;
    }

    /**
     * Get first error for field
     */
    public function getFirstError($field)
    {
        return isset($this->errors[$field]) ? $this->errors[$field][0] : null;
    }

    /**
     * Sanitize input data
     */
    public static function sanitize($data)
    {
        if (is_array($data)) {
            return array_map([self::class, 'sanitize'], $data);
        }
        return htmlspecialchars(strip_tags(trim($data)), ENT_QUOTES, 'UTF-8');
    }

    /**
     * Filter request data
     */
    public static function filterRequest($keys)
    {
        $data = [];
        foreach ($keys as $key) {
            if (isset($_POST[$key])) {
                $data[$key] = self::sanitize($_POST[$key]);
            }
        }
        return $data;
    }
}
