-- ============================================================================
-- Rollback: 2026_05_09_users_hard_delete.sql
-- WARNING: hard-deleted user rows (and their cascaded data) cannot be
--          recovered by this rollback. Only schema is restored.
-- ============================================================================

START TRANSACTION;

ALTER TABLE `users`
  ADD COLUMN `deleted_at` DATETIME DEFAULT NULL AFTER `updated_at`;

ALTER TABLE `users`
  ADD INDEX `idx_users_deleted_at` (`deleted_at`);

COMMIT;
