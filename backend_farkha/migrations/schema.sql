-- ============================================
-- Farkha Database - Complete Schema
-- Updated: 2026-05-06 (After all phases)
-- ============================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------
-- Users
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `firebase_uid` VARCHAR(128) NOT NULL,
    `name` VARCHAR(100) NOT NULL DEFAULT 'مستخدم',
    `phone` VARCHAR(20) DEFAULT NULL,
    `fcm_token` TEXT DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` DATETIME DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_firebase_uid` (`firebase_uid`),
    UNIQUE KEY `uk_phone` (`phone`),
    INDEX `idx_users_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- User Devices (Multi-device FCM)
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `user_devices` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `fcm_token` VARCHAR(255) NOT NULL,
    `platform` ENUM('android','ios') NOT NULL,
    `device_id` VARCHAR(100) DEFAULT NULL,
    `last_active` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_token` (`fcm_token`),
    INDEX `idx_ud_user_id` (`user_id`),
    CONSTRAINT `fk_ud_user` FOREIGN KEY (`user_id`)
        REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Phone Verifications (OTP)
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `phone_verifications` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `phone` VARCHAR(20) NOT NULL,
    `otp_hash` VARCHAR(64) NOT NULL,
    `session_token` CHAR(32) NOT NULL UNIQUE,
    `verified_token` CHAR(32) DEFAULT NULL UNIQUE,
    `verified_token_expires_at` DATETIME DEFAULT NULL,
    `attempts_remaining` TINYINT UNSIGNED NOT NULL DEFAULT 5,
    `resend_count` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `status` ENUM('pending','verified','expired','locked') NOT NULL DEFAULT 'pending',
    `locked_until` DATETIME DEFAULT NULL,
    `expires_at` DATETIME NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_pv_user_id` (`user_id`),
    INDEX `idx_pv_phone` (`phone`),
    INDEX `idx_pv_status` (`status`),
    INDEX `idx_pv_phone_status` (`phone`, `status`),
    INDEX `idx_pv_expires_at` (`expires_at`),
    CONSTRAINT `fk_phone_verifications_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Product Categories (renamed from `main`)
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `product_categories` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Product Types
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `types` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `category_id` INT NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_category` (`category_id`),
    CONSTRAINT `fk_types_category`
        FOREIGN KEY (`category_id`) REFERENCES `product_categories`(`id`)
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Prices
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `prices` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `higher` DECIMAL(10,2) NOT NULL,
    `lower` DECIMAL(10,2) DEFAULT NULL,
    `type` INT NOT NULL,
    `date` DATE NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (`id`),
    INDEX `idx_type_date` (`type`, `date`),
    INDEX `idx_prices_date` (`date`),
    CONSTRAINT `fk_prices_type`
        FOREIGN KEY (`type`) REFERENCES `types`(`id`)
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Articles
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `articles` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    `content` TEXT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` DATETIME DEFAULT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_articles_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Cycles (Farm tracking)
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `cycles` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `owner_user_id` INT NOT NULL,
    `chick_count` INT DEFAULT NULL,
    `space` VARCHAR(50) DEFAULT NULL,
    `breed` VARCHAR(50) DEFAULT NULL,
    `system_type` VARCHAR(50) DEFAULT NULL,
    `start_date_raw` DATE DEFAULT NULL,
    `end_date_raw` DATE DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` DATETIME DEFAULT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_cycles_deleted_at` (`deleted_at`),
    CONSTRAINT `fk_cycles_owner`
        FOREIGN KEY (`owner_user_id`) REFERENCES `users`(`id`)
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Cycle Users (membership)
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `cycle_users` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `cycle_id` INT NOT NULL,
    `role` ENUM('owner','admin','member','viewer') NOT NULL DEFAULT 'member',
    `status` ENUM('pending','accepted','rejected') NOT NULL DEFAULT 'accepted',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_cycle` (`user_id`, `cycle_id`),
    INDEX `idx_cycle_id` (`cycle_id`),
    CONSTRAINT `fk_cycle_users_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_cycle_users_cycle` FOREIGN KEY (`cycle_id`) REFERENCES `cycles`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Cycle Data (weight, mortality, feed, etc.)
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `cycle_data` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cycle_id` INT NOT NULL,
    `metric_type` ENUM('weight','mortality','feed','water','temperature','humidity','medicine','other')
        NOT NULL DEFAULT 'other',
    `label` VARCHAR(100) NOT NULL,
    `value` VARCHAR(255) NOT NULL,
    `numeric_value` DECIMAL(10,2) DEFAULT NULL,
    `text_value` VARCHAR(255) DEFAULT NULL,
    `entry_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_cycle_id` (`cycle_id`),
    INDEX `idx_label` (`label`),
    INDEX `idx_cd_entry_date` (`entry_date`),
    INDEX `idx_cd_cycle_date` (`cycle_id`, `entry_date`),
    INDEX `idx_cd_cycle_metric_date` (`cycle_id`, `metric_type`, `entry_date`),
    CONSTRAINT `fk_cycle_data_cycle` FOREIGN KEY (`cycle_id`) REFERENCES `cycles`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Cycle Expenses
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `cycle_expenses` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cycle_id` INT NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `value` DECIMAL(10,2) NOT NULL,
    `entry_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_cycle_id` (`cycle_id`),
    INDEX `idx_ce_cycle_date` (`cycle_id`, `entry_date`),
    CONSTRAINT `fk_cycle_expenses_cycle` FOREIGN KEY (`cycle_id`) REFERENCES `cycles`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Cycle Sales
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `cycle_sales` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cycle_id` INT NOT NULL,
    `quantity` INT DEFAULT NULL,
    `total_weight` DECIMAL(10,2) DEFAULT NULL,
    `price_per_kg` DECIMAL(10,2) DEFAULT NULL,
    `total_price` DECIMAL(10,2) DEFAULT NULL,
    `sale_date` DATE DEFAULT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_cycle_id` (`cycle_id`),
    INDEX `idx_cs_cycle_date` (`cycle_id`, `sale_date`),
    CONSTRAINT `fk_cycle_sales_cycle` FOREIGN KEY (`cycle_id`) REFERENCES `cycles`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Cycle Notes
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `cycle_notes` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cycle_id` INT NOT NULL,
    `content` TEXT NOT NULL,
    `entry_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_cycle_id` (`cycle_id`),
    CONSTRAINT `fk_cycle_notes_cycle` FOREIGN KEY (`cycle_id`) REFERENCES `cycles`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Cycle Inventory
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `cycle_inventory` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cycle_id` INT NOT NULL,
    `item_name` VARCHAR(100) NOT NULL,
    `category` VARCHAR(50) DEFAULT NULL,
    `unit` VARCHAR(20) DEFAULT NULL,
    `quantity` DECIMAL(10,2) NOT NULL DEFAULT 0,
    `transaction_type` ENUM('in','out') NOT NULL DEFAULT 'in',
    `notes` TEXT DEFAULT NULL,
    `entry_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_cycle_id` (`cycle_id`),
    CONSTRAINT `fk_cycle_inventory_cycle` FOREIGN KEY (`cycle_id`) REFERENCES `cycles`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Cycle Invitations
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `cycle_invitations` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cycle_id` INT NOT NULL,
    `created_by_user_id` INT DEFAULT NULL,
    `code` CHAR(6) NOT NULL,
    `used_by_user_id` INT DEFAULT NULL,
    `used_at` DATETIME DEFAULT NULL,
    `status` ENUM('active','used','expired','revoked') NOT NULL DEFAULT 'active',
    `expires_at` DATETIME NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_code` (`code`),
    INDEX `idx_ci_expires_at` (`expires_at`),
    INDEX `idx_ci_status` (`status`),
    CONSTRAINT `fk_cycle_invitations_cycle` FOREIGN KEY (`cycle_id`) REFERENCES `cycles`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_ci_creator` FOREIGN KEY (`created_by_user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_ci_user` FOREIGN KEY (`used_by_user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Tools Usage Analytics
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `tools_usage` (
    `usage_date` DATE NOT NULL,
    `tool_id` INT NOT NULL,
    `usage_count` INT NOT NULL DEFAULT 1,
    PRIMARY KEY (`usage_date`, `tool_id`),
    INDEX `idx_tu_tool_name` (`tool_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Tools Usage Events (Temporal tracking)
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `tools_usage_events` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `tool_name` VARCHAR(100) NOT NULL,
    `used_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_tue_user` (`user_id`),
    INDEX `idx_tue_tool` (`tool_name`),
    INDEX `idx_tue_used_at` (`used_at`),
    CONSTRAINT `fk_tue_user` FOREIGN KEY (`user_id`)
        REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- App Reviews
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `app_reviews` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user_id` INT DEFAULT NULL,
    `device_id` VARCHAR(100) DEFAULT NULL,
    `rating` TINYINT DEFAULT NULL,
    `issue` VARCHAR(500) DEFAULT NULL,
    `suggestion` VARCHAR(500) DEFAULT NULL,
    `app_version` VARCHAR(20) DEFAULT NULL,
    `platform` ENUM('android','ios') DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_device_id` (`device_id`),
    INDEX `idx_ar_created_at` (`created_at`),
    CONSTRAINT `fk_ar_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    CONSTRAINT `chk_app_reviews_rating` CHECK (`rating` BETWEEN 1 AND 5 OR `rating` IS NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------
-- Cycle Feedbacks
-- -------------------------------------------
CREATE TABLE IF NOT EXISTS `cycle_feedbacks` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user_id` INT DEFAULT NULL,
    `cycle_id` INT DEFAULT NULL,
    `rating` TINYINT NOT NULL,
    `issue` VARCHAR(500) DEFAULT NULL,
    `suggestion` VARCHAR(500) DEFAULT NULL,
    `app_version` VARCHAR(20) DEFAULT NULL,
    `platform` ENUM('android','ios') DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_cf_user_id` (`user_id`),
    INDEX `idx_cf_cycle_id` (`cycle_id`),
    CONSTRAINT `chk_cycle_feedbacks_rating` CHECK (`rating` BETWEEN 1 AND 5),
    CONSTRAINT `fk_cf_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_cf_cycle` FOREIGN KEY (`cycle_id`) REFERENCES `cycles`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
