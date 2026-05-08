-- ============================================
-- Migration: Phase 3 — Wide Impact
-- Date: 2026-05-06
-- Prerequisite: Phase 1 and Phase 2 must be applied first
-- ⚠️ Do NOT run without explicit user approval
-- ============================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 3.1 — Soft Delete (deleted_at)
-- ============================================================
START TRANSACTION;

ALTER TABLE `users`
    ADD COLUMN `deleted_at` DATETIME DEFAULT NULL,
    ADD INDEX `idx_users_deleted_at` (`deleted_at`);

ALTER TABLE `cycles`
    ADD COLUMN `deleted_at` DATETIME DEFAULT NULL,
    ADD INDEX `idx_cycles_deleted_at` (`deleted_at`);

ALTER TABLE `articles`
    ADD COLUMN `deleted_at` DATETIME DEFAULT NULL,
    ADD INDEX `idx_articles_deleted_at` (`deleted_at`);

COMMIT;

-- ============================================================
-- 3.2 — user_devices table (Multi-device FCM)
-- ============================================================
START TRANSACTION;

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

-- Backfill from users.fcm_token
INSERT INTO user_devices (user_id, fcm_token, platform)
SELECT id, fcm_token, 'android' FROM users
WHERE fcm_token IS NOT NULL AND fcm_token != '' AND deleted_at IS NULL;

COMMIT;

-- ⚠️ After verifying backfill, drop old column:
-- ALTER TABLE users DROP COLUMN fcm_token;

-- ============================================================
-- 3.3 — EAV Refactor for cycle_data
-- ============================================================
START TRANSACTION;

ALTER TABLE `cycle_data`
    ADD COLUMN `metric_type` ENUM('weight','mortality','feed','water','temperature','humidity','medicine','other')
        NOT NULL DEFAULT 'other' AFTER `cycle_id`,
    ADD COLUMN `numeric_value` DECIMAL(10,2) DEFAULT NULL,
    ADD COLUMN `text_value` VARCHAR(255) DEFAULT NULL,
    ADD INDEX `idx_cd_cycle_metric_date` (`cycle_id`, `metric_type`, `entry_date`);

-- Backfill based on existing labels
UPDATE cycle_data SET metric_type='weight', numeric_value=CAST(value AS DECIMAL(10,2))
    WHERE label LIKE '%وزن%';
UPDATE cycle_data SET metric_type='mortality', numeric_value=CAST(value AS DECIMAL(10,2))
    WHERE label LIKE '%نفوق%' OR label LIKE '%نافق%';
UPDATE cycle_data SET metric_type='feed', numeric_value=CAST(value AS DECIMAL(10,2))
    WHERE label LIKE '%علف%' OR label LIKE '%استهلاك%';
UPDATE cycle_data SET metric_type='medicine', text_value=value
    WHERE label LIKE '%تحصين%' OR label LIKE '%دواء%';
UPDATE cycle_data SET metric_type='water', numeric_value=CAST(value AS DECIMAL(10,2))
    WHERE label LIKE '%ماء%' OR label LIKE '%water%';
UPDATE cycle_data SET metric_type='temperature', numeric_value=CAST(value AS DECIMAL(10,2))
    WHERE label LIKE '%حرار%' OR label LIKE '%temperature%';
UPDATE cycle_data SET metric_type='humidity', numeric_value=CAST(value AS DECIMAL(10,2))
    WHERE label LIKE '%رطوب%' OR label LIKE '%humidity%';
UPDATE cycle_data SET numeric_value=CAST(value AS DECIMAL(10,2))
    WHERE metric_type IN ('weight','mortality','feed','water','temperature','humidity')
      AND numeric_value IS NULL AND value REGEXP '^[0-9]+\\.?[0-9]*$';
UPDATE cycle_data SET text_value=value
    WHERE metric_type IN ('medicine','other')
      AND text_value IS NULL;

COMMIT;

-- ⚠️ After verifying backfill, can drop old columns:
-- ALTER TABLE cycle_data DROP COLUMN label, DROP COLUMN value;

-- ============================================================
-- 3.4 — tools_usage_events table
-- ============================================================
START TRANSACTION;

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

COMMIT;

-- ============================================
-- Rollback for Phase 3
-- ============================================
-- START TRANSACTION;
-- DROP TABLE IF EXISTS `tools_usage_events`;
-- ALTER TABLE `cycle_data`
--     DROP INDEX `idx_cd_cycle_metric_date`,
--     DROP COLUMN `text_value`,
--     DROP COLUMN `numeric_value`,
--     DROP COLUMN `metric_type`;
-- DROP TABLE IF EXISTS `user_devices`;
-- ALTER TABLE `articles` DROP INDEX `idx_articles_deleted_at`, DROP COLUMN `deleted_at`;
-- ALTER TABLE `cycles` DROP INDEX `idx_cycles_deleted_at`, DROP COLUMN `deleted_at`;
-- ALTER TABLE `users` DROP INDEX `idx_users_deleted_at`, DROP COLUMN `deleted_at`;
-- COMMIT;
