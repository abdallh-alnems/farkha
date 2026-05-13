-- ============================================================================
-- Users Hard Delete Migration
-- Date: 2026-05-09
-- Goal: Replace soft-delete on users (deleted_at) with hard delete.
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

-- Hard-delete soft-deleted rows. FKs handle related data:
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
-- 2. Drop the deleted_at column and its index
-- ----------------------------------------------------------------------------

ALTER TABLE `users` DROP INDEX `idx_users_deleted_at`;
ALTER TABLE `users` DROP COLUMN `deleted_at`;

COMMIT;

-- ----------------------------------------------------------------------------
-- POST-CHECKS
-- ----------------------------------------------------------------------------

SELECT 'POST-CHECK: users.deleted_at column removed (expected: 0)' AS chk, COUNT(*) AS got
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'farkha' AND TABLE_NAME = 'users' AND COLUMN_NAME = 'deleted_at';


