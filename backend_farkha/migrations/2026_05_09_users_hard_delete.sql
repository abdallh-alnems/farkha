-- ============================================================================
-- Users Hard Delete Migration
-- Date: 2026-05-09
-- Goal: Replace soft-delete on users (deleted_at) with hard delete + anonymized
--       audit table (account_deletions) for analytics.
-- Scope: users table only. cycles.deleted_at and articles.deleted_at are
--        intentionally kept (used as archive/draft state).
-- Target: MySQL 8.0.44 (MAMP) — DB: farkha
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PRE-CHECKS
-- ----------------------------------------------------------------------------

SELECT 'PRE-CHECK: existing soft-deleted users (will be hard-deleted)' AS chk,
       COUNT(*) AS got
FROM users WHERE deleted_at IS NOT NULL;

SELECT 'PRE-CHECK: users.deleted_at column exists' AS chk,
       COUNT(*) AS got
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'farkha' AND TABLE_NAME = 'users' AND COLUMN_NAME = 'deleted_at';

START TRANSACTION;

-- ----------------------------------------------------------------------------
-- 1. Create account_deletions audit table (anonymized, no PII)
-- ----------------------------------------------------------------------------

CREATE TABLE `account_deletions` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `deleted_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `account_age_days` INT DEFAULT NULL,
  `cycles_owned_count` INT NOT NULL DEFAULT 0,
  `cycles_member_count` INT NOT NULL DEFAULT 0,
  `last_platform` ENUM('android','ios') DEFAULT NULL,
  `reason` VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ad_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 2. Backfill: any rows currently soft-deleted should be hard-deleted now,
--    while recording an anonymized audit row for each.
-- ----------------------------------------------------------------------------

INSERT INTO account_deletions
  (deleted_at, account_age_days, cycles_owned_count, cycles_member_count, last_platform)
SELECT
  u.deleted_at,
  TIMESTAMPDIFF(DAY, u.created_at, u.deleted_at),
  (SELECT COUNT(*) FROM cycle_users cu WHERE cu.user_id = u.id AND cu.role = 'owner'),
  (SELECT COUNT(*) FROM cycle_users cu WHERE cu.user_id = u.id AND cu.role <> 'owner'),
  (SELECT ud.platform FROM user_devices ud WHERE ud.user_id = u.id ORDER BY ud.last_active DESC LIMIT 1)
FROM users u
WHERE u.deleted_at IS NOT NULL;

-- Hard-delete the rows that were soft-deleted. FKs handle related data:
--   cycle_users, cycle_feedbacks, cycle_invitations(created_by), phone_verifications,
--   tool_usage_events, user_devices  → ON DELETE CASCADE
--   articles.user_id, cycle_invitations.used_by_user_id → ON DELETE SET NULL
-- cycles.owner_user_id is RESTRICT — but a soft-deleted user shouldn't own
-- any cycle (delete_account.php removes owned cycles first). Verify:

SELECT 'PRE-DELETE CHECK: soft-deleted users still owning cycles (must be 0)' AS chk,
       COUNT(*) AS got
FROM users u JOIN cycles c ON c.owner_user_id = u.id
WHERE u.deleted_at IS NOT NULL;

DELETE FROM users WHERE deleted_at IS NOT NULL;

-- ----------------------------------------------------------------------------
-- 3. Drop the deleted_at column and its index
-- ----------------------------------------------------------------------------

ALTER TABLE `users` DROP INDEX `idx_users_deleted_at`;
ALTER TABLE `users` DROP COLUMN `deleted_at`;

COMMIT;

-- ----------------------------------------------------------------------------
-- POST-CHECKS
-- ----------------------------------------------------------------------------

SELECT 'POST-CHECK: account_deletions table exists' AS chk, COUNT(*) AS got
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'farkha' AND TABLE_NAME = 'account_deletions';

SELECT 'POST-CHECK: users.deleted_at column removed (expected: 0)' AS chk, COUNT(*) AS got
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'farkha' AND TABLE_NAME = 'users' AND COLUMN_NAME = 'deleted_at';

SELECT 'POST-CHECK: backfilled audit rows' AS chk, COUNT(*) AS got
FROM account_deletions;
