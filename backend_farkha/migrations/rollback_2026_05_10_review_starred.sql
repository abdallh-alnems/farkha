CREATE TABLE IF NOT EXISTS `app_reviews_starred_archive` (
    `id` INT NOT NULL,
    `review_text` TEXT,
    `starred_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `cycle_feedbacks_starred_archive` (
    `id` INT NOT NULL,
    `starred_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `app_reviews_starred_archive` (`id`, `review_text`)
    SELECT `id`, `review_text` FROM `app_reviews` WHERE `is_starred` = 1;

INSERT IGNORE INTO `cycle_feedbacks_starred_archive` (`id`)
    SELECT `id` FROM `cycle_feedbacks` WHERE `is_starred` = 1;

ALTER TABLE `app_reviews` DROP COLUMN IF EXISTS `is_starred`;
ALTER TABLE `cycle_feedbacks` DROP COLUMN IF EXISTS `is_starred`;
