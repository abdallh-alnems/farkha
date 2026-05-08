-- ============================================
-- Migration: Phase 2 — Limited Backend Impact
-- Date: 2026-05-06
-- Prerequisite: Phase 1 must be applied first
-- ============================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 2.1 — phone UNIQUE constraint on users
-- ============================================================
-- ⚠️ Run this check first (should return empty):
-- SELECT phone, COUNT(*) as cnt FROM users
-- WHERE phone IS NOT NULL GROUP BY phone HAVING cnt > 1;

START TRANSACTION;

ALTER TABLE `users`
    DROP INDEX `idx_phone`,
    ADD UNIQUE KEY `uk_phone` (`phone`);

COMMIT;

-- ============================================================
-- 2.2 — cycles.owner_user_id
-- ============================================================
START TRANSACTION;

ALTER TABLE `cycles`
    ADD COLUMN `owner_user_id` INT DEFAULT NULL AFTER `name`;

UPDATE `cycles` c
JOIN `cycle_users` cu
    ON cu.cycle_id = c.id AND cu.role = 'owner' AND cu.status = 'accepted'
SET c.owner_user_id = cu.user_id
WHERE c.owner_user_id IS NULL;

-- ⚠️ Verify: SELECT COUNT(*) FROM cycles WHERE owner_user_id IS NULL;
-- Must return 0 before proceeding

ALTER TABLE `cycles`
    MODIFY COLUMN `owner_user_id` INT NOT NULL,
    ADD CONSTRAINT `fk_cycles_owner`
        FOREIGN KEY (`owner_user_id`) REFERENCES `users`(`id`)
        ON DELETE RESTRICT;

COMMIT;

-- ============================================================
-- 2.3 — Improve cycle_invitations
-- ============================================================
START TRANSACTION;

ALTER TABLE `cycle_invitations`
    ADD COLUMN `created_by_user_id` INT DEFAULT NULL AFTER `cycle_id`,
    ADD COLUMN `used_by_user_id` INT DEFAULT NULL,
    ADD COLUMN `used_at` DATETIME DEFAULT NULL,
    ADD COLUMN `status` ENUM('active','used','expired','revoked')
        NOT NULL DEFAULT 'active',
    ADD INDEX `idx_ci_status` (`status`),
    ADD CONSTRAINT `fk_ci_creator`
        FOREIGN KEY (`created_by_user_id`) REFERENCES `users`(`id`)
        ON DELETE SET NULL,
    ADD CONSTRAINT `fk_ci_user`
        FOREIGN KEY (`used_by_user_id`) REFERENCES `users`(`id`)
        ON DELETE SET NULL;

COMMIT;

-- ============================================================
-- 2.4 — Rename main → product_categories, column main → category_id
-- ============================================================
START TRANSACTION;

ALTER TABLE `types` DROP FOREIGN KEY `fk_types_main`;

RENAME TABLE `main` TO `product_categories`;

ALTER TABLE `types` CHANGE COLUMN `main` `category_id` INT NOT NULL;

ALTER TABLE `types`
    ADD CONSTRAINT `fk_types_category`
        FOREIGN KEY (`category_id`) REFERENCES `product_categories`(`id`)
        ON DELETE RESTRICT;

ALTER TABLE `types` DROP INDEX `idx_main`;
ALTER TABLE `types` ADD INDEX `idx_category` (`category_id`);

COMMIT;

-- ============================================
-- Rollback for Phase 2
-- ============================================
-- START TRANSACTION;
-- -- 2.4 rollback
-- ALTER TABLE `types` DROP INDEX `idx_category`;
-- ALTER TABLE `types` ADD INDEX `idx_main` (`category_id`);
-- ALTER TABLE `types` DROP FOREIGN KEY `fk_types_category`;
-- ALTER TABLE `types` CHANGE COLUMN `category_id` `main` INT NOT NULL;
-- RENAME TABLE `product_categories` TO `main`;
-- ALTER TABLE `types` ADD CONSTRAINT `fk_types_main`
--     FOREIGN KEY (`main`) REFERENCES `main`(`id`) ON DELETE RESTRICT;
--
-- -- 2.3 rollback
-- ALTER TABLE `cycle_invitations`
--     DROP FOREIGN KEY `fk_ci_user`,
--     DROP FOREIGN KEY `fk_ci_creator`,
--     DROP INDEX `idx_ci_status`,
--     DROP COLUMN `status`,
--     DROP COLUMN `used_at`,
--     DROP COLUMN `used_by_user_id`,
--     DROP COLUMN `created_by_user_id`;
--
-- -- 2.2 rollback
-- ALTER TABLE `cycles`
--     DROP FOREIGN KEY `fk_cycles_owner`,
--     DROP COLUMN `owner_user_id`;
--
-- -- 2.1 rollback
-- ALTER TABLE `users`
--     DROP INDEX `uk_phone`,
--     ADD INDEX `idx_phone` (`phone`);
--
-- COMMIT;
