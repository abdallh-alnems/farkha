<?php

require_once __DIR__ . '/env.php';
require_once __DIR__ . '/database.php';
require_once __DIR__ . '/cors.php';
require_once __DIR__ . '/firebase.php';

require_once __DIR__ . '/../core/Response.php';
require_once __DIR__ . '/../core/Auth.php';
require_once __DIR__ . '/../core/RateLimiter.php';
require_once __DIR__ . '/../core/Cache.php';
require_once __DIR__ . '/../core/Validator.php';
require_once __DIR__ . '/../core/OtpService.php';
require_once __DIR__ . '/../core/WhatsAppService.php';
require_once __DIR__ . '/../core/NotificationService.php';
require_once __DIR__ . '/../core/TopicManager.php';
require_once __DIR__ . '/../core/BaseApi.php';
require_once __DIR__ . '/../core/AdminAuth.php';
require_once __DIR__ . '/../core/AdminBaseApi.php';

require_once __DIR__ . '/../models/UserModel.php';
require_once __DIR__ . '/../models/CycleModel.php';
require_once __DIR__ . '/../models/PriceModel.php';
require_once __DIR__ . '/../models/ArticleModel.php';
require_once __DIR__ . '/../models/ReviewModel.php';
require_once __DIR__ . '/../models/AnalyticsModel.php';
require_once __DIR__ . '/../models/FeedbackModel.php';

setCorsHeaders();

if (!defined('FARKHA_BOOTSTRAPPED')) {
    define('FARKHA_BOOTSTRAPPED', true);
}
