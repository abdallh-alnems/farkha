CREATE TABLE IF NOT EXISTS cycle_feedbacks (
    id           INT NOT NULL AUTO_INCREMENT,
    rating       TINYINT NOT NULL,
    issue        VARCHAR(500) NULL DEFAULT NULL,
    suggestion   VARCHAR(500) NULL DEFAULT NULL,
    app_version  VARCHAR(20)  NULL DEFAULT NULL,
    platform     ENUM('android','ios') NULL DEFAULT NULL,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT chk_cycle_feedbacks_rating
        CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
