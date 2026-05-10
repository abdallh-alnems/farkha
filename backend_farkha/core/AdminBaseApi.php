<?php

abstract class AdminBaseApi extends BaseApi {
    protected ?string $minRole = null;
    protected bool $requireAuth = false;

    public function __construct() {
        $this->db = Database::getInstance();

        RateLimiter::enforceIpLimit();
        AdminAuth::require($this->minRole);
    }
}
