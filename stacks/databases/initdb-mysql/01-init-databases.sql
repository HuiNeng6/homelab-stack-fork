-- =============================================================================
-- HomeLab MariaDB Init Script
-- Issue: #11
-- Creates databases for services that prefer MySQL/MariaDB.
-- IDEMPOTENT: Uses IF NOT EXISTS for all operations.
-- =============================================================================

-- Set proper character set
SET NAMES utf8mb4;

-- BookStack
CREATE DATABASE IF NOT EXISTS `bookstack`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'bookstack'@'%' IDENTIFIED BY '${BOOKSTACK_DB_PASSWORD:-changeme}';
GRANT ALL PRIVILEGES ON `bookstack`.* TO 'bookstack'@'%';

-- Nextcloud (MySQL alternative - optional)
CREATE DATABASE IF NOT EXISTS `nextcloud`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_bin;

CREATE USER IF NOT EXISTS 'nextcloud_mysql'@'%' IDENTIFIED BY '${NEXTCLOUD_DB_PASSWORD:-changeme}';
GRANT ALL PRIVILEGES ON `nextcloud`.* TO 'nextcloud_mysql'@'%';

-- Apply changes
FLUSH PRIVILEGES;

-- Log completion
SELECT 'MariaDB initialization complete. Databases created: bookstack, nextcloud' AS status;