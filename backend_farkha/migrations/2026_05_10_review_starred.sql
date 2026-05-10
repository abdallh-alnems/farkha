ALTER TABLE `app_reviews` ADD COLUMN `is_starred` tinyint(1) NOT NULL DEFAULT 0 AFTER `platform`;
ALTER TABLE `cycle_feedbacks` ADD COLUMN `is_starred` tinyint(1) NOT NULL DEFAULT 0 AFTER `platform`;
