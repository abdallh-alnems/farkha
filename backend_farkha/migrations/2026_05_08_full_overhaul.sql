-- ============================================================================
-- Farkha Database Overhaul — Full Migration
-- Date: 2026-05-08
-- Spec: specs/006-database-overhaul/spec.md
-- Quickstart: specs/006-database-overhaul/quickstart.md
-- Target: MySQL 8.0.44 (MAMP)
-- DB: farkha (test database — no backwards compatibility required)
-- ============================================================================

-- ============================================================================
-- PRE-CHECKS: Verify current state matches expectations
-- ============================================================================

SELECT 'PRE-CHECK: cycle_feedbacks orphans (expected: 5)' AS chk, COUNT(*) AS got
FROM cycle_feedbacks cf LEFT JOIN users u ON u.id=cf.user_id
WHERE u.id IS NULL;

SELECT 'PRE-CHECK: app_reviews orphans (expected: 3)' AS chk, COUNT(*) AS got
FROM app_reviews ar LEFT JOIN users u ON u.id=ar.user_id
WHERE ar.user_id IS NOT NULL AND u.id IS NULL;

SELECT 'PRE-CHECK: cycles without owner (expected: 1)' AS chk, COUNT(*) AS got
FROM cycles c LEFT JOIN cycle_users cu
  ON cu.cycle_id=c.id AND cu.role='owner' AND cu.status='accepted'
WHERE cu.id IS NULL;

SELECT 'PRE-CHECK: cycle_data labels (expected: 4 distinct)' AS chk, COUNT(DISTINCT label) AS got
FROM cycle_data;

SELECT 'PRE-CHECK: tables not unicode_ci (expected: 6)' AS chk, COUNT(*) AS got
FROM information_schema.TABLES
WHERE TABLE_SCHEMA='farkha' AND TABLE_COLLATION != 'utf8mb4_unicode_ci';

-- ============================================================================
-- GROUP A: Pre-cleanup — Remove orphans and garbage data
-- ============================================================================

START TRANSACTION;

-- Remove 5 orphan cycle_feedbacks (user_id references non-existent users)
DELETE cf FROM cycle_feedbacks cf
LEFT JOIN users u ON u.id = cf.user_id
WHERE u.id IS NULL;

-- Remove 3 orphan app_reviews (user_id references non-existent users)
DELETE ar FROM app_reviews ar
LEFT JOIN users u ON u.id = ar.user_id
WHERE ar.user_id IS NOT NULL AND u.id IS NULL;

-- Remove cycle without owner and all its dependent data
-- Use a temporary table to avoid MySQL's self-reference limitation
CREATE TEMPORARY TABLE tmp_orphan_cycles AS
SELECT c.id FROM cycles c
LEFT JOIN cycle_users cu ON cu.cycle_id=c.id AND cu.role='owner' AND cu.status='accepted'
WHERE cu.id IS NULL;

DELETE FROM cycle_data WHERE cycle_id IN (SELECT id FROM tmp_orphan_cycles);
DELETE FROM cycle_expenses WHERE cycle_id IN (SELECT id FROM tmp_orphan_cycles);
DELETE FROM cycle_sales WHERE cycle_id IN (SELECT id FROM tmp_orphan_cycles);
DELETE FROM cycle_inventory WHERE cycle_id IN (SELECT id FROM tmp_orphan_cycles);
DELETE FROM cycle_notes WHERE cycle_id IN (SELECT id FROM tmp_orphan_cycles);
DELETE FROM cycle_users WHERE cycle_id IN (SELECT id FROM tmp_orphan_cycles);
DELETE FROM cycle_invitations WHERE cycle_id IN (SELECT id FROM tmp_orphan_cycles);
DELETE FROM cycles WHERE id IN (SELECT id FROM tmp_orphan_cycles);

DROP TEMPORARY TABLE tmp_orphan_cycles;

COMMIT;

-- ============================================================================
-- GROUP B: Collation Unification — Convert all tables to utf8mb4_unicode_ci
-- ============================================================================

START TRANSACTION;

ALTER DATABASE farkha COLLATE utf8mb4_unicode_ci;

ALTER TABLE users CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE articles CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE main CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE types CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE tools_usage CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE phone_verifications CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

COMMIT;

-- ============================================================================
-- GROUP C: Missing FKs + New Columns
-- ============================================================================

START TRANSACTION;

-- Add FK on cycle_inventory.cycle_id -> cycles(id) ON DELETE CASCADE
ALTER TABLE cycle_inventory
  ADD CONSTRAINT fk_inventory_cycle
  FOREIGN KEY (cycle_id) REFERENCES cycles(id) ON DELETE CASCADE;

-- Add FK on cycle_feedbacks.user_id -> users(id) ON DELETE CASCADE
ALTER TABLE cycle_feedbacks
  ADD CONSTRAINT fk_cf_user
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Add FK on app_reviews.user_id -> users(id) ON DELETE SET NULL
ALTER TABLE app_reviews
  ADD CONSTRAINT fk_ar_user
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

-- Add cycles.owner_user_id column (NOT NULL + FK)
ALTER TABLE cycles
  ADD COLUMN owner_user_id INT NOT NULL DEFAULT 1 AFTER name;

-- Backfill owner_user_id from cycle_users
UPDATE cycles c
JOIN cycle_users cu ON cu.cycle_id = c.id AND cu.role = 'owner' AND cu.status = 'accepted'
SET c.owner_user_id = cu.user_id;

-- Now add the FK constraint and remove the default
ALTER TABLE cycles
  ADD CONSTRAINT fk_cycles_owner
  FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE RESTRICT;

ALTER TABLE cycles
  MODIFY COLUMN owner_user_id INT NOT NULL;

-- Add UNIQUE composite on cycle_users(user_id, cycle_id)
ALTER TABLE cycle_users
  ADD CONSTRAINT uk_cycle_users_user_cycle UNIQUE (user_id, cycle_id);

COMMIT;

-- ============================================================================
-- GROUP D: Audit Columns
-- ============================================================================

START TRANSACTION;

-- cycles: updated_at, deleted_at
ALTER TABLE cycles
  ADD COLUMN updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at,
  ADD COLUMN deleted_at DATETIME DEFAULT NULL AFTER updated_at,
  ADD KEY idx_cycles_deleted_at (deleted_at);

-- articles: created_at, updated_at, deleted_at + widen title
ALTER TABLE articles
  MODIFY COLUMN title VARCHAR(150) NOT NULL,
  ADD COLUMN created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER content,
  ADD COLUMN updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at,
  ADD COLUMN deleted_at DATETIME DEFAULT NULL AFTER updated_at,
  ADD KEY idx_articles_deleted_at (deleted_at);

-- cycle_inventory: created_at, updated_at
ALTER TABLE cycle_inventory
  ADD COLUMN created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER entry_date,
  ADD COLUMN updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at;

-- cycle_notes: updated_at
ALTER TABLE cycle_notes
  ADD COLUMN updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER entry_date;

COMMIT;

-- ============================================================================
-- GROUP E: Invitation Tracking
-- ============================================================================

START TRANSACTION;

-- Drop existing FK on created_by before rename
ALTER TABLE cycle_invitations
  DROP FOREIGN KEY cycle_invitations_ibfk_2;

-- Rename created_by -> created_by_user_id
ALTER TABLE cycle_invitations
  CHANGE COLUMN created_by created_by_user_id INT NOT NULL;

-- Re-add FK with new column name
ALTER TABLE cycle_invitations
  ADD CONSTRAINT fk_ci_created_by
  FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Add new tracking columns
ALTER TABLE cycle_invitations
  ADD COLUMN used_by_user_id INT DEFAULT NULL AFTER created_by_user_id,
  ADD COLUMN used_at DATETIME DEFAULT NULL AFTER used_by_user_id,
  ADD COLUMN status ENUM('active','used','expired','revoked') NOT NULL DEFAULT 'active' AFTER used_at;

-- Add FK on used_by_user_id
ALTER TABLE cycle_invitations
  ADD CONSTRAINT fk_ci_used_by
  FOREIGN KEY (used_by_user_id) REFERENCES users(id) ON DELETE SET NULL;

-- Add indexes
ALTER TABLE cycle_invitations
  ADD KEY idx_ci_status (status),
  ADD KEY idx_ci_expires_at (expires_at);

COMMIT;

-- ============================================================================
-- GROUP F: Performance Indexes
-- ============================================================================

START TRANSACTION;

ALTER TABLE cycle_data
  ADD KEY idx_cd_cycle_date (cycle_id, entry_date);

ALTER TABLE cycle_expenses
  ADD KEY idx_ce_cycle_date (cycle_id, entry_date);

ALTER TABLE cycle_sales
  ADD KEY idx_cs_cycle_date (cycle_id, sale_date);

ALTER TABLE cycle_inventory
  ADD KEY idx_ci_cycle_date (cycle_id, entry_date);

ALTER TABLE app_reviews
  ADD KEY idx_ar_created_at (created_at);

ALTER TABLE cycle_feedbacks
  ADD KEY idx_cf_created_at (created_at);

ALTER TABLE phone_verifications
  ADD KEY idx_pv_phone_status (phone, status),
  ADD KEY idx_pv_expires_at (expires_at);

ALTER TABLE tools_usage
  ADD KEY idx_tu_tool_id (tool_id);

COMMIT;

-- ============================================================================
-- GROUP G: cycle_data EAV Refactor
-- ============================================================================

START TRANSACTION;

-- Add new columns
ALTER TABLE cycle_data
  ADD COLUMN metric_type ENUM('weight','mortality','feed','vaccination','water','temperature','humidity','medicine','other') NOT NULL DEFAULT 'other' AFTER cycle_id,
  ADD COLUMN numeric_value DECIMAL(10,2) DEFAULT NULL AFTER metric_type,
  ADD COLUMN text_value VARCHAR(255) DEFAULT NULL AFTER numeric_value;

-- Backfill from 4 known labels
UPDATE cycle_data SET metric_type = 'weight', numeric_value = CAST(value AS DECIMAL(10,2)) WHERE label = 'متوسط وزن القطيع';
UPDATE cycle_data SET metric_type = 'mortality', numeric_value = CAST(value AS DECIMAL(10,2)) WHERE label = 'عدد النافق';
UPDATE cycle_data SET metric_type = 'feed', numeric_value = CAST(value AS DECIMAL(10,2)) WHERE label = 'استهلاك العلف';
UPDATE cycle_data SET metric_type = 'vaccination', text_value = value WHERE label = 'التحصينات';

-- Verify no 'other' with null values (should be 0)
SELECT 'EAV backfill check (expected: 0)' AS chk, COUNT(*) AS got
FROM cycle_data WHERE metric_type = 'other' AND numeric_value IS NULL AND text_value IS NULL;

-- Add composite index
ALTER TABLE cycle_data
  ADD KEY idx_cd_cycle_metric_date (cycle_id, metric_type, entry_date);

-- Drop old columns
ALTER TABLE cycle_data
  DROP COLUMN label,
  DROP COLUMN value;

COMMIT;

-- ============================================================================
-- GROUP H: fcm_token cleanup + main -> product_categories rename
-- ============================================================================

START TRANSACTION;

-- Backfill: migrate any users.fcm_token values not already in user_devices
INSERT IGNORE INTO user_devices (user_id, fcm_token, platform)
SELECT id, fcm_token, 'android'
FROM users
WHERE fcm_token IS NOT NULL AND fcm_token != '' AND fcm_token NOT REGEXP '^[[:space:]]*$';

-- Drop fcm_token from users
ALTER TABLE users
  DROP COLUMN fcm_token;

-- Rename main -> product_categories
-- First drop the FK from types that references main
ALTER TABLE types
  DROP FOREIGN KEY types_ibfk_1;

RENAME TABLE main TO product_categories;

-- Re-add FK on types with new table name, renaming column main -> category_id
ALTER TABLE types
  CHANGE COLUMN main category_id TINYINT NOT NULL;

ALTER TABLE types
  ADD CONSTRAINT fk_types_category
  FOREIGN KEY (category_id) REFERENCES product_categories(id);

COMMIT;

-- ============================================================================
-- GROUP I: tools_usage_events table (new)
-- ============================================================================

START TRANSACTION;

CREATE TABLE tools_usage_events (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  tool_id INT NOT NULL,
  used_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_tue_user (user_id),
  KEY idx_tue_tool (tool_id),
  KEY idx_tue_used_at (used_at),
  CONSTRAINT fk_tue_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

COMMIT;

-- ============================================================================
-- POST-CHECKS: Verify migration success
-- ============================================================================

SELECT 'POST-CHECK: cycle_inventory orphans (expected: 0)' AS chk, COUNT(*) AS got
FROM cycle_inventory ci LEFT JOIN cycles c ON c.id=ci.cycle_id WHERE c.id IS NULL;

SELECT 'POST-CHECK: cycles without owner (expected: 0)' AS chk, COUNT(*) AS got
FROM cycles WHERE owner_user_id IS NULL;

SELECT 'POST-CHECK: tables not unicode_ci (expected: 0)' AS chk, COUNT(*) AS got
FROM information_schema.TABLES
WHERE TABLE_SCHEMA='farkha' AND TABLE_COLLATION != 'utf8mb4_unicode_ci';

SELECT IF(COUNT(*) = 0, 'PASS: fcm_token dropped', 'FAIL: fcm_token still exists') AS chk
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA='farkha' AND TABLE_NAME='users' AND COLUMN_NAME='fcm_token';

SELECT IF(COUNT(*) = 0, 'PASS: label dropped', 'FAIL: label still exists') AS chk
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA='farkha' AND TABLE_NAME='cycle_data' AND COLUMN_NAME='label';

SELECT metric_type, COUNT(*) AS cnt FROM cycle_data GROUP BY metric_type;

SELECT COUNT(*) AS table_count FROM information_schema.TABLES WHERE TABLE_SCHEMA='farkha';
