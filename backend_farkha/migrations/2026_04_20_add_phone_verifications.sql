ALTER TABLE users
  ADD COLUMN phone_verified_at DATETIME DEFAULT NULL AFTER phone;

CREATE TABLE phone_verifications (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  phone VARCHAR(20) NOT NULL,
  otp_hash VARCHAR(64) NOT NULL,
  session_token CHAR(36) NOT NULL UNIQUE,
  verified_token CHAR(36) DEFAULT NULL UNIQUE,
  verified_token_expires_at DATETIME DEFAULT NULL,
  attempts_remaining TINYINT UNSIGNED NOT NULL DEFAULT 5,
  resend_count TINYINT UNSIGNED NOT NULL DEFAULT 0,
  status ENUM('pending','verified','expired','locked') NOT NULL DEFAULT 'pending',
  locked_until DATETIME DEFAULT NULL,
  expires_at DATETIME NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_pv_user_id (user_id),
  INDEX idx_pv_phone (phone),
  CONSTRAINT fk_phone_verifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
