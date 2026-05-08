-- ============================================
-- Migration: Database Improvements (Phase 1 - Safe)
-- Date: 2026-05-06
-- ============================================
-- هذه الهجرة آمنة 100% — لا تتطلب تعديل على الـ Backend.
-- كل التغييرات شفّافة: قيود سلامة + فهارس + أعمدة افتراضية تلقائية.
--
-- قبل التشغيل:
--   1. خذ نسخة احتياطية كاملة:
--      mysqldump -u root -p farkha_db > backup_2026_05_06.sql
--   2. تأكد عدم وجود قيم يتيمة في types.main و prices.type:
--      SELECT * FROM types WHERE main NOT IN (SELECT id FROM main);
--      SELECT * FROM prices WHERE type NOT IN (SELECT id FROM types);
--   3. شغّل الملف داخل transaction:
--      mysql -u root -p farkha_db < 2026_05_06_database_improvements.sql
-- ============================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 1;

START TRANSACTION;

-- --------------------------------------------------------
-- 1. cycle_feedbacks: ربط بالمستخدم والدورة
-- --------------------------------------------------------
-- يسمح بمعرفة من أرسل التقييم وأي دورة، مع SET NULL عند حذف المستخدم.

ALTER TABLE `cycle_feedbacks`
    ADD COLUMN `user_id` INT DEFAULT NULL FIRST,
    ADD COLUMN `cycle_id` INT DEFAULT NULL AFTER `user_id`,
    ADD INDEX `idx_cf_user_id` (`user_id`),
    ADD INDEX `idx_cf_cycle_id` (`cycle_id`),
    ADD CONSTRAINT `fk_cf_user`
        FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    ADD CONSTRAINT `fk_cf_cycle`
        FOREIGN KEY (`cycle_id`) REFERENCES `cycles`(`id`) ON DELETE SET NULL;

-- --------------------------------------------------------
-- 2. cycles: عمود updated_at للتتبّع التلقائي
-- --------------------------------------------------------

ALTER TABLE `cycles`
    ADD COLUMN `updated_at` DATETIME NOT NULL
        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        AFTER `created_at`;

-- --------------------------------------------------------
-- 3. app_reviews: ربط بالمستخدم + قيد التقييم
-- --------------------------------------------------------

ALTER TABLE `app_reviews`
    ADD CONSTRAINT `fk_ar_user`
        FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    ADD CONSTRAINT `chk_app_reviews_rating`
        CHECK (`rating` BETWEEN 1 AND 5 OR `rating` IS NULL);

-- --------------------------------------------------------
-- 4. types و prices: مفاتيح أجنبية ناقصة
-- --------------------------------------------------------
-- ⚠️ سيفشل لو في قيم يتيمة. شغّل استعلامات الفحص في الأعلى أولاً.

ALTER TABLE `types`
    ADD CONSTRAINT `fk_types_main`
        FOREIGN KEY (`main`) REFERENCES `main`(`id`) ON DELETE RESTRICT;

ALTER TABLE `prices`
    ADD CONSTRAINT `fk_prices_type`
        FOREIGN KEY (`type`) REFERENCES `types`(`id`) ON DELETE RESTRICT;

-- --------------------------------------------------------
-- 5. فهارس لتسريع الاستعلامات الشائعة
-- --------------------------------------------------------

-- prices: تصفية حسب التاريخ مباشرة (لوحة التحكم)
ALTER TABLE `prices`
    ADD INDEX `idx_prices_date` (`date`);

-- cycle_data: استعلامات الجدول الزمني للوزن/النفوق
ALTER TABLE `cycle_data`
    ADD INDEX `idx_cd_entry_date` (`entry_date`),
    ADD INDEX `idx_cd_cycle_date` (`cycle_id`, `entry_date`);

-- cycle_expenses: ملخصات شهرية حسب الدورة
ALTER TABLE `cycle_expenses`
    ADD INDEX `idx_ce_cycle_date` (`cycle_id`, `entry_date`);

-- cycle_sales: تقارير المبيعات
ALTER TABLE `cycle_sales`
    ADD INDEX `idx_cs_cycle_date` (`cycle_id`, `sale_date`);

-- app_reviews: تقارير زمنية
ALTER TABLE `app_reviews`
    ADD INDEX `idx_ar_created_at` (`created_at`);

-- tools_usage: تحليلات الأدوات الأكثر استخداماً
ALTER TABLE `tools_usage`
    ADD INDEX `idx_tu_tool_name` (`tool_name`);

-- phone_verifications: تسريع البحث أثناء OTP
ALTER TABLE `phone_verifications`
    ADD INDEX `idx_pv_phone_status` (`phone`, `status`),
    ADD INDEX `idx_pv_expires_at` (`expires_at`);

-- cycle_invitations: تنظيف الدعوات المنتهية
ALTER TABLE `cycle_invitations`
    ADD INDEX `idx_ci_expires_at` (`expires_at`);

COMMIT;

-- ============================================
-- التحقّق بعد التطبيق
-- ============================================
-- شغّل هذه للتأكد من نجاح كل التغييرات:
--
-- SHOW CREATE TABLE cycle_feedbacks\G
-- SHOW CREATE TABLE cycles\G
-- SHOW CREATE TABLE app_reviews\G
-- SHOW INDEX FROM cycle_data;
-- SHOW INDEX FROM prices;
-- ============================================

-- ============================================
-- في حالة الحاجة للتراجع (Rollback)
-- ============================================
-- START TRANSACTION;
-- ALTER TABLE cycle_invitations DROP INDEX idx_ci_expires_at;
-- ALTER TABLE phone_verifications DROP INDEX idx_pv_phone_status, DROP INDEX idx_pv_expires_at;
-- ALTER TABLE tools_usage DROP INDEX idx_tu_tool_name;
-- ALTER TABLE app_reviews DROP INDEX idx_ar_created_at;
-- ALTER TABLE cycle_sales DROP INDEX idx_cs_cycle_date;
-- ALTER TABLE cycle_expenses DROP INDEX idx_ce_cycle_date;
-- ALTER TABLE cycle_data DROP INDEX idx_cd_entry_date, DROP INDEX idx_cd_cycle_date;
-- ALTER TABLE prices DROP INDEX idx_prices_date;
-- ALTER TABLE prices DROP FOREIGN KEY fk_prices_type;
-- ALTER TABLE types DROP FOREIGN KEY fk_types_main;
-- ALTER TABLE app_reviews DROP CONSTRAINT chk_app_reviews_rating, DROP FOREIGN KEY fk_ar_user;
-- ALTER TABLE cycles DROP COLUMN updated_at;
-- ALTER TABLE cycle_feedbacks
--     DROP FOREIGN KEY fk_cf_cycle,
--     DROP FOREIGN KEY fk_cf_user,
--     DROP INDEX idx_cf_cycle_id,
--     DROP INDEX idx_cf_user_id,
--     DROP COLUMN cycle_id,
--     DROP COLUMN user_id;
-- COMMIT;
-- ============================================
