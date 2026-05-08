<?php

abstract class BaseApi {
    protected bool $requireAuth = true;
    protected bool $requirePost = false;
    protected PDO $db;

    public function __construct() {
        $this->db = Database::getInstance();

        if ($this->requirePost) {
            Auth::requirePost();
        }

        if ($this->requireAuth) {
            Auth::checkAppCheck();
        }

        RateLimiter::enforceIpLimit();
    }

    protected function success($data = null, ?string $source = null): void {
        Response::success($data, 200, $source);
    }

    protected function error(string $message, int $code = 400): void {
        Response::fail($message, $code);
    }

    protected function notFound(string $item = 'Item'): void {
        Response::notFound($item);
    }

    protected function getField(string $field, $default = null) {
        return Validator::getCombinedField($field, $default);
    }

    protected function requireField(string $field): void {
        $value = $this->getField($field);
        Validator::required($value, $field);
    }

    protected function requireNumeric(string $field, float $min = 0): float {
        return Validator::numeric($this->getField($field), $field, $min);
    }

    protected function getValidatedMainType(string $field = 'type'): ?int {
        return Validator::mainType($this->getField($field));
    }

    protected function getSanitizedTypeIds(string $field = 'type_ids'): array {
        return Validator::sanitizeTypeIds($this->getField($field));
    }

    protected function handleRequest(callable $callback, string $context = 'api'): void {
        try {
            $callback();
        } catch (PDOException $e) {
            error_log("DB Error [{$context}]: " . $e->getMessage());
            Response::error('Database error', 500);
        } catch (Exception $e) {
            error_log("Error [{$context}]: " . $e->getMessage());
            Response::error('Server error', 500);
        }
    }
}
