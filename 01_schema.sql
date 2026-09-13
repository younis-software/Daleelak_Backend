-- File: 01_schema.sql
-- Dalilak schema: tables, primary keys, foreign keys, unique constraints, and checks.

-- Dalilak - MySQL 8 database implementation
-- Demo data only. Generate production password hashes in the backend with bcrypt or Argon2.

CREATE DATABASE IF NOT EXISTS dalilak_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE dalilak_db;

SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- ============================================================
-- Core identity and geographic hierarchy
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
    user_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(30) NULL,
    profile_image VARCHAR(500) NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    latitude DECIMAL(10,8) NULL,
    longitude DECIMAL(11,8) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP NULL DEFAULT NULL,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (user_id),
    UNIQUE KEY uq_users_email (email),
    CONSTRAINT chk_users_role CHECK (role IN ('user', 'admin')),
    CONSTRAINT chk_users_status CHECK (status IN ('active', 'pending', 'suspended')),
    CONSTRAINT chk_users_latitude CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_users_longitude CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),
    CONSTRAINT chk_users_coordinate_pair CHECK (
        (latitude IS NULL AND longitude IS NULL) OR
        (latitude IS NOT NULL AND longitude IS NOT NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS user_profiles (
    user_id BIGINT UNSIGNED NOT NULL,
    display_name VARCHAR(150) NULL,
    bio TEXT NULL,
    preferred_language CHAR(2) NOT NULL DEFAULT 'en',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    CONSTRAINT fk_user_profiles_user FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_user_profiles_language CHECK (preferred_language IN ('ar', 'en'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS countries (
    country_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    country_code CHAR(2) NOT NULL,
    name_ar VARCHAR(150) NOT NULL,
    name_en VARCHAR(150) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (country_id),
    UNIQUE KEY uq_countries_code (country_code),
    UNIQUE KEY uq_countries_name_ar (name_ar),
    UNIQUE KEY uq_countries_name_en (name_en),
    CONSTRAINT chk_countries_code CHECK (country_code = UPPER(country_code))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS cities (
    city_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    country_id BIGINT UNSIGNED NOT NULL,
    name_ar VARCHAR(150) NOT NULL,
    name_en VARCHAR(150) NOT NULL,
    latitude DECIMAL(10,8) NULL,
    longitude DECIMAL(11,8) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (city_id),
    UNIQUE KEY uq_cities_country_name_ar (country_id, name_ar),
    UNIQUE KEY uq_cities_country_name_en (country_id, name_en),
    CONSTRAINT fk_cities_country FOREIGN KEY (country_id) REFERENCES countries (country_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_cities_latitude CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_cities_longitude CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),
    CONSTRAINT chk_cities_coordinate_pair CHECK (
        (latitude IS NULL AND longitude IS NULL) OR
        (latitude IS NOT NULL AND longitude IS NOT NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS areas (
    area_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    city_id BIGINT UNSIGNED NOT NULL,
    parent_area_id BIGINT UNSIGNED NULL,
    name_ar VARCHAR(150) NOT NULL,
    name_en VARCHAR(150) NOT NULL,
    latitude DECIMAL(10,8) NULL,
    longitude DECIMAL(11,8) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (area_id),
    UNIQUE KEY uq_areas_city_name_ar (city_id, name_ar),
    UNIQUE KEY uq_areas_city_name_en (city_id, name_en),
    CONSTRAINT fk_areas_city FOREIGN KEY (city_id) REFERENCES cities (city_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_areas_parent FOREIGN KEY (parent_area_id) REFERENCES areas (area_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_areas_latitude CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_areas_longitude CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),
    CONSTRAINT chk_areas_coordinate_pair CHECK (
        (latitude IS NULL AND longitude IS NULL) OR
        (latitude IS NOT NULL AND longitude IS NOT NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS categories (
    category_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    parent_category_id BIGINT UNSIGNED NULL,
    name_ar VARCHAR(150) NOT NULL,
    name_en VARCHAR(150) NOT NULL,
    slug VARCHAR(180) NOT NULL,
    description_ar TEXT NULL,
    description_en TEXT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (category_id),
    UNIQUE KEY uq_categories_slug (slug),
    UNIQUE KEY uq_categories_parent_name_ar (parent_category_id, name_ar),
    UNIQUE KEY uq_categories_parent_name_en (parent_category_id, name_en),
    CONSTRAINT fk_categories_parent FOREIGN KEY (parent_category_id) REFERENCES categories (category_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- POINT uses X=longitude and Y=latitude. SRID 4326 is WGS 84.
CREATE TABLE IF NOT EXISTS places (
    place_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    area_id BIGINT UNSIGNED NOT NULL,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255) NOT NULL,
    description_ar TEXT NULL,
    description_en TEXT NULL,
    slug VARCHAR(255) NOT NULL,
    address VARCHAR(500) NOT NULL,
    place_location POINT SRID 4326 NOT NULL,
    phone VARCHAR(30) NULL,
    email VARCHAR(255) NULL,
    website VARCHAR(500) NULL,
    google_maps_url VARCHAR(1000) NULL,
    price_level TINYINT UNSIGNED NULL,
    average_rating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    review_count INT UNSIGNED NOT NULL DEFAULT 0,
    view_count INT UNSIGNED NOT NULL DEFAULT 0,
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    publication_status VARCHAR(20) NOT NULL DEFAULT 'draft',
    created_by BIGINT UNSIGNED NULL,
    updated_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (place_id),
    UNIQUE KEY uq_places_slug (slug),
    CONSTRAINT fk_places_area FOREIGN KEY (area_id) REFERENCES areas (area_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_places_created_by FOREIGN KEY (created_by) REFERENCES users (user_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_places_updated_by FOREIGN KEY (updated_by) REFERENCES users (user_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_places_price_level CHECK (price_level IS NULL OR price_level BETWEEN 1 AND 4),
    CONSTRAINT chk_places_rating CHECK (average_rating BETWEEN 0.00 AND 5.00),
    CONSTRAINT chk_places_publication_status CHECK (
        publication_status IN ('draft', 'pending', 'published', 'archived')
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- Place detail and classification tables
-- ============================================================

CREATE TABLE IF NOT EXISTS place_categories (
    place_id BIGINT UNSIGNED NOT NULL,
    category_id BIGINT UNSIGNED NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (place_id, category_id),
    CONSTRAINT fk_place_categories_place FOREIGN KEY (place_id) REFERENCES places (place_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_place_categories_category FOREIGN KEY (category_id) REFERENCES categories (category_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS place_images (
    image_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    place_id BIGINT UNSIGNED NOT NULL,
    image_url VARCHAR(1000) NOT NULL,
    storage_key VARCHAR(500) NULL,
    title VARCHAR(255) NULL,
    alt_text VARCHAR(255) NULL,
    display_order INT UNSIGNED NOT NULL DEFAULT 0,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (image_id),
    CONSTRAINT fk_place_images_place FOREIGN KEY (place_id) REFERENCES places (place_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_place_images_url CHECK (CHAR_LENGTH(TRIM(image_url)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS opening_hours (
    opening_hours_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    place_id BIGINT UNSIGNED NOT NULL,
    day_of_week TINYINT UNSIGNED NOT NULL,
    period_number TINYINT UNSIGNED NOT NULL DEFAULT 1,
    opens_at TIME NULL,
    closes_at TIME NULL,
    closes_next_day BOOLEAN NOT NULL DEFAULT FALSE,
    is_closed BOOLEAN NOT NULL DEFAULT FALSE,
    is_24_hours BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (opening_hours_id),
    UNIQUE KEY uq_opening_hours_period (place_id, day_of_week, period_number),
    CONSTRAINT fk_opening_hours_place FOREIGN KEY (place_id) REFERENCES places (place_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_opening_hours_day CHECK (day_of_week BETWEEN 1 AND 7),
    CONSTRAINT chk_opening_hours_period CHECK (period_number >= 1),
    CONSTRAINT chk_opening_hours_flags CHECK (NOT (is_closed AND is_24_hours)),
    CONSTRAINT chk_opening_hours_closed_times CHECK (
        (is_closed = TRUE AND opens_at IS NULL AND closes_at IS NULL) OR is_closed = FALSE
    ),
    CONSTRAINT chk_opening_hours_24h_times CHECK (
        (is_24_hours = TRUE AND opens_at IS NULL AND closes_at IS NULL) OR is_24_hours = FALSE
    ),
    CONSTRAINT chk_opening_hours_regular_times CHECK (
        is_closed = TRUE OR is_24_hours = TRUE OR (opens_at IS NOT NULL AND closes_at IS NOT NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS amenities (
    amenity_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name_ar VARCHAR(150) NOT NULL,
    name_en VARCHAR(150) NOT NULL,
    slug VARCHAR(180) NOT NULL,
    description_ar TEXT NULL,
    description_en TEXT NULL,
    icon_name VARCHAR(100) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (amenity_id),
    UNIQUE KEY uq_amenities_slug (slug),
    KEY idx_amenities_name_en (name_en)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS place_amenities (
    place_id BIGINT UNSIGNED NOT NULL,
    amenity_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (place_id, amenity_id),
    CONSTRAINT fk_place_amenities_place FOREIGN KEY (place_id) REFERENCES places (place_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_place_amenities_amenity FOREIGN KEY (amenity_id) REFERENCES amenities (amenity_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS place_contacts (
    contact_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    place_id BIGINT UNSIGNED NOT NULL,
    contact_type VARCHAR(30) NOT NULL,
    contact_value VARCHAR(1000) NOT NULL,
    label VARCHAR(100) NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    display_order INT UNSIGNED NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (contact_id),
    UNIQUE KEY uq_place_contacts_value (place_id, contact_type, contact_value(255)),
    CONSTRAINT fk_place_contacts_place FOREIGN KEY (place_id) REFERENCES places (place_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_place_contacts_type CHECK (
        contact_type IN ('phone', 'whatsapp', 'email', 'website', 'facebook', 'instagram', 'tiktok', 'youtube', 'x', 'other_social', 'other')
    ),
    CONSTRAINT chk_place_contacts_value CHECK (CHAR_LENGTH(TRIM(contact_value)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS tags (
    tag_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name_ar VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    slug VARCHAR(150) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (tag_id),
    UNIQUE KEY uq_tags_slug (slug),
    KEY idx_tags_name_en (name_en)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS place_tags (
    place_id BIGINT UNSIGNED NOT NULL,
    tag_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (place_id, tag_id),
    CONSTRAINT fk_place_tags_place FOREIGN KEY (place_id) REFERENCES places (place_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_place_tags_tag FOREIGN KEY (tag_id) REFERENCES tags (tag_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- Reviews, user activity, moderation, and notifications
-- ============================================================

CREATE TABLE IF NOT EXISTS reviews (
    review_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    place_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NULL,
    rating TINYINT UNSIGNED NOT NULL,
    review_text TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    moderated_by BIGINT UNSIGNED NULL,
    moderated_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (review_id),
    UNIQUE KEY uq_reviews_user_place (user_id, place_id),
    CONSTRAINT fk_reviews_place FOREIGN KEY (place_id) REFERENCES places (place_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_reviews_moderator FOREIGN KEY (moderated_by) REFERENCES users (user_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT chk_reviews_status CHECK (status IN ('pending', 'approved', 'rejected', 'hidden'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS favorites (
    user_id BIGINT UNSIGNED NOT NULL,
    place_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, place_id),
    CONSTRAINT fk_favorites_user FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_favorites_place FOREIGN KEY (place_id) REFERENCES places (place_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS place_views (
    view_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    place_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NULL,
    session_id VARCHAR(128) NULL,
    ip_hash CHAR(64) NULL,
    viewed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (view_id),
    CONSTRAINT fk_place_views_place FOREIGN KEY (place_id) REFERENCES places (place_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_place_views_user FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS user_interactions (
    interaction_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NULL,
    place_id BIGINT UNSIGNED NULL,
    interaction_type VARCHAR(30) NOT NULL,
    metadata_json JSON NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (interaction_id),
    CONSTRAINT fk_interactions_user FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_interactions_place FOREIGN KEY (place_id) REFERENCES places (place_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_interactions_type CHECK (
        interaction_type IN ('view', 'favorite', 'review', 'search', 'share', 'map_open')
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS place_reports (
    place_report_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    place_id BIGINT UNSIGNED NOT NULL,
    reported_by BIGINT UNSIGNED NULL,
    reason VARCHAR(100) NOT NULL,
    description TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (place_report_id),
    CONSTRAINT fk_place_reports_place FOREIGN KEY (place_id) REFERENCES places (place_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_place_reports_reporter FOREIGN KEY (reported_by) REFERENCES users (user_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_place_reports_reviewer FOREIGN KEY (reviewed_by) REFERENCES users (user_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_place_reports_status CHECK (status IN ('pending', 'resolved', 'rejected'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS review_reports (
    review_report_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    review_id BIGINT UNSIGNED NOT NULL,
    reported_by BIGINT UNSIGNED NULL,
    reason VARCHAR(100) NOT NULL,
    description TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (review_report_id),
    CONSTRAINT fk_review_reports_review FOREIGN KEY (review_id) REFERENCES reviews (review_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_review_reports_reporter FOREIGN KEY (reported_by) REFERENCES users (user_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_review_reports_reviewer FOREIGN KEY (reviewed_by) REFERENCES users (user_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_review_reports_status CHECK (status IN ('pending', 'resolved', 'rejected'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS notifications (
    notification_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    entity_type VARCHAR(30) NULL,
    entity_id BIGINT UNSIGNED NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (notification_id),
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS admin_activity_logs (
    log_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    admin_user_id BIGINT UNSIGNED NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    entity_type VARCHAR(30) NOT NULL,
    entity_id BIGINT UNSIGNED NULL,
    description TEXT NULL,
    ip_address VARCHAR(45) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id),
    CONSTRAINT fk_admin_logs_admin FOREIGN KEY (admin_user_id) REFERENCES users (user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
