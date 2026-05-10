-- ============================================================================
-- Farkha Database Overhaul — ROLLBACK
-- Date: 2026-05-08
-- Reverses: 2026_05_08_full_overhaul.sql (Groups I -> A)
-- Target: MySQL 8.0.44 (MAMP)
-- DB: farkha (test database)
-- WARNING: Data backfill is NOT reversed — only schema changes are undone.
--           Restore from backup if full data recovery is needed.
-- ============================================================================

-- ============================================================================
-- GROUP H ROLLBACK: Restore users.fcm_token, rename product_categories -> main
-- ============================================================================

START TRANSACTION;

-- Restore users.fcm_token column
ALTER TABLE users
  ADD COLUMN fcm_token VARCHAR(255) DEFAULT NULL;

-- Restore fcm_token data from user_devices (pick first device per user)
UPDATE users u
JOIN (
  SELECT user_id, fcm_token
  FROM user_devices
  WHERE id = (SELECT MIN(id) FROM user_devices ud WHERE ud.user_id = user_devices.user_id)
) ud ON ud.user_id = u.id
SET u.fcm_token = ud.fcm_token;

-- Drop FK on types before rename
ALTER TABLE types
  DROP FOREIGN KEY fk_types_category;

-- Rename category_id -> main
ALTER TABLE types
  CHANGE COLUMN category_id main TINYINT NOT NULL;

-- Rename product_categories -> main
RENAME TABLE product_categories TO main;

-- Re-add FK on types referencing main
ALTER TABLE types
  ADD CONSTRAINT types_ibfk_1
  FOREIGN KEY (main) REFERENCES main(id);

COMMIT;

-- ============================================================================
-- GROUP G ROLLBACK: Restore cycle_data label/value columns
-- ============================================================================

START TRANSACTION;

-- Re-add old columns
ALTER TABLE cycle_data
  ADD COLUMN label VARCHAR(100) DEFAULT NULL AFTER cycle_id,
  ADD COLUMN value VARCHAR(255) DEFAULT NULL AFTER label;

-- Backfill from metric_type to label/value
UPDATE cycle_data SET label = 'متوسط وزن القطيع', value = CAST(numeric_value AS CHAR) WHERE metric_type = 'weight';
UPDATE cycle_data SET label = 'عدد النافق', value = CAST(numeric_value AS CHAR) WHERE metric_type = 'mortality';
UPDATE cycle_data SET label = 'استهلاك العلف', value = CAST(numeric_value AS CHAR) WHERE metric_type = 'feed';
UPDATE cycle_data SET label = 'التحصينات', value = text_value WHERE metric_type = 'vaccination';

-- Drop new columns
ALTER TABLE cycle_data
  DROP COLUMN metric_type,
  DROP COLUMN numeric_value,
  DROP COLUMN text_value;

-- Drop new indexes
ALTER TABLE cycle_data
  DROP KEY idx_cd_cycle_metric_date;

COMMIT;

-- ============================================================================
-- GROUP F ROLLBACK: Drop performance indexes
-- ============================================================================

START TRANSACTION;

ALTER TABLE cycle_data DROP KEY idx_cd_cycle_date;
ALTER TABLE cycle_expenses DROP KEY idx_ce_cycle_date;
ALTER TABLE cycle_sales DROP KEY idx_cs_cycle_date;
ALTER TABLE cycle_inventory DROP KEY idx_ci_cycle_date;
ALTER TABLE app_reviews DROP KEY idx_ar_created_at;
ALTER TABLE cycle_feedbacks DROP KEY idx_cf_created_at;
ALTER TABLE phone_verifications DROP KEY idx_pv_phone_status;
ALTER TABLE phone_verifications DROP KEY idx_pv_expires_at;
ALTER TABLE tools_usage DROP KEY idx_tu_tool_id;

COMMIT;

-- ============================================================================
-- GROUP E ROLLBACK: Revert invitation tracking columns
-- ============================================================================

START TRANSACTION;

-- Drop new FKs and indexes
ALTER TABLE cycle_invitations DROP FOREIGN KEY fk_ci_used_by;
ALTER TABLE cycle_invitations DROP KEY idx_ci_status;
ALTER TABLE cycle_invitations DROP KEY idx_ci_expires_at;

-- Drop new columns
ALTER TABLE cycle_invitations
  DROP COLUMN used_by_user_id,
  DROP COLUMN used_at,
  DROP COLUMN status;

-- Rename created_by_user_id -> created_by
ALTER TABLE cycle_invitations
  DROP FOREIGN KEY fk_ci_created_by;

ALTER TABLE cycle_invitations
  CHANGE COLUMN created_by_user_id created_by INT NOT NULL;

-- Re-add original FK
ALTER TABLE cycle_invitations
  ADD CONSTRAINT cycle_invitations_ibfk_2
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE;

COMMIT;

-- ============================================================================
-- GROUP D ROLLBACK: Drop audit columns
-- ============================================================================

START TRANSACTION;

-- cycle_notes: drop updated_at
ALTER TABLE cycle_notes DROP COLUMN updated_at;

-- cycle_inventory: drop created_at, updated_at
ALTER TABLE cycle_inventory DROP COLUMN created_at, DROP COLUMN updated_at;

-- articles: drop created_at, updated_at, deleted_at, revert title width
ALTER TABLE articles
  DROP COLUMN created_at,
  DROP COLUMN updated_at,
  DROP COLUMN deleted_at,
  DROP KEY idx_articles_deleted_at,
  MODIFY COLUMN title VARCHAR(100) NOT NULL;

-- cycles: drop updated_at, deleted_at
ALTER TABLE cycles
  DROP COLUMN updated_at,
  DROP COLUMN deleted_at,
  DROP KEY idx_cycles_deleted_at;

COMMIT;

-- ============================================================================
-- GROUP C ROLLBACK: Drop FKs and owner_user_id
-- ============================================================================

START TRANSACTION;

-- Drop UNIQUE on cycle_users
ALTER TABLE cycle_users DROP INDEX uk_cycle_users_user_cycle;

-- Drop owner_user_id from cycles
ALTER TABLE cycles DROP FOREIGN KEY fk_cycles_owner;
ALTER TABLE cycles DROP COLUMN owner_user_id;

-- Drop FK on app_reviews
ALTER TABLE app_reviews DROP FOREIGN KEY fk_ar_user;

-- Drop FK on cycle_feedbacks
ALTER TABLE cycle_feedbacks DROP FOREIGN KEY fk_cf_user;

-- Drop FK on cycle_inventory
ALTER TABLE cycle_inventory DROP FOREIGN KEY fk_inventory_cycle;

COMMIT;

-- ============================================================================
-- GROUP B ROLLBACK: Revert collation (optional — skip if not needed)
-- ============================================================================

-- NOTE: Collation rollback is typically unnecessary for test databases.
-- The original collations were mixed (utf8mb4_general_ci, utf8mb4_unicode_ci, etc).
-- Skipping to avoid unnecessary table rebuilds.

-- ============================================================================
-- GROUP A ROLLBACK: Orphan cleanup (cannot be reversed — data was deleted)
-- ============================================================================

-- NOTE: Orphan records were permanently deleted in the migration.
-- Restore from backup if needed.

-- ============================================================================
-- ROLLBACK COMPLETE
-- ============================================================================
