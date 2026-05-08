<?php

require_once __DIR__ . '/../config/bootstrap.php';

Auth::requireAppCheck();

$count = Cache::getInstance()->clear();
Response::success(['message' => 'Cache cleared', 'files_deleted' => $count]);
