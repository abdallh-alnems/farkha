-- ============================================
-- Migration: Recommended schema improvements
-- Date: 2026-05-02
-- ============================================

-- 1. Add user_id and cycle_id to cycle_feedbacks for proper tracking
ALTER TABLE cycle_feedbacks
    ADD COLUMN user_id INT DEFAULT NULL FIRST,
    ADD COLUMN cycle_id INT DEFAULT NULL AFTER user_id,
    ADD CONSTRAINT fk_cf_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_cf_cycle FOREIGN KEY (cycle_id) REFERENCES cycles(id) ON DELETE SET NULL;

-- 2. Add updated_at to cycles
ALTER TABLE cycles
    ADD COLUMN updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at;

-- 3. Add user_id FK to app_reviews
ALTER TABLE app_reviews
    ADD CONSTRAINT fk_ar_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

-- 4. Add CHECK constraint for rating in app_reviews
ALTER TABLE app_reviews
    ADD CONSTRAINT chk_app_reviews_rating CHECK (rating BETWEEN 1 AND 5 OR rating IS NULL);

-- 5. Add index on prices.date for faster history queries
ALTER TABLE prices
    ADD INDEX idx_date (date);

-- 6. Add index on cycle_data.entry_date for chronological queries
ALTER TABLE cycle_data
    ADD INDEX idx_entry_date (entry_date);
