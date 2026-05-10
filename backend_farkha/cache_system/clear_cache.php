<?php

require_once __DIR__ . '/../config/bootstrap.php';

RateLimiter::enforceIpLimit();
AdminAuth::require('admin');

$count = Cache::getInstance()->clear();
AdminAuth::logAction('cache.clear', 'cache', null, ['files_deleted' => $count]);
Response::success(['message' => 'Cache cleared', 'files_deleted' => $count]);
