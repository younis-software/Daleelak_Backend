-- File: 03_views_procedures.sql
-- Views and triggers. No stored procedures are required by the current architecture.
USE dalilak_db;

-- Review aggregate triggers
-- Reviews are authoritative; these cached values improve listing performance.
-- The backend must still perform review moderation and writes in transactions.
-- ============================================================

DELIMITER $$

CREATE TRIGGER trg_reviews_after_insert
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    UPDATE places AS p
    LEFT JOIN (
        SELECT place_id, AVG(rating) AS rating_average, COUNT(*) AS rating_count
        FROM reviews
        WHERE status = 'approved' AND deleted_at IS NULL
        GROUP BY place_id
    ) AS s ON s.place_id = p.place_id
    SET p.average_rating = COALESCE(s.rating_average, 0.00),
        p.review_count = COALESCE(s.rating_count, 0)
    WHERE p.place_id = NEW.place_id;
END$$

CREATE TRIGGER trg_reviews_after_update
AFTER UPDATE ON reviews
FOR EACH ROW
BEGIN
    UPDATE places AS p
    LEFT JOIN (
        SELECT place_id, AVG(rating) AS rating_average, COUNT(*) AS rating_count
        FROM reviews
        WHERE status = 'approved' AND deleted_at IS NULL
        GROUP BY place_id
    ) AS s ON s.place_id = p.place_id
    SET p.average_rating = COALESCE(s.rating_average, 0.00),
        p.review_count = COALESCE(s.rating_count, 0)
    WHERE p.place_id IN (OLD.place_id, NEW.place_id);
END$$

CREATE TRIGGER trg_reviews_after_delete
AFTER DELETE ON reviews
FOR EACH ROW
BEGIN
    UPDATE places AS p
    LEFT JOIN (
        SELECT place_id, AVG(rating) AS rating_average, COUNT(*) AS rating_count
        FROM reviews
        WHERE status = 'approved' AND deleted_at IS NULL
        GROUP BY place_id
    ) AS s ON s.place_id = p.place_id
    SET p.average_rating = COALESCE(s.rating_average, 0.00),
        p.review_count = COALESCE(s.rating_count, 0)
    WHERE p.place_id = OLD.place_id;
END$$

DELIMITER ;

-- ============================================================
-- Useful views
-- ============================================================

CREATE OR REPLACE VIEW v_active_places AS
SELECT
    p.place_id,
    p.slug,
    p.name_ar,
    p.name_en,
    p.description_ar,
    p.description_en,
    p.address,
    ST_Y(p.place_location) AS latitude,
    ST_X(p.place_location) AS longitude,
    p.price_level,
    p.average_rating,
    p.review_count,
    p.view_count,
    p.is_featured,
    p.is_verified,
    p.area_id,
    a.name_ar AS area_name_ar,
    a.name_en AS area_name_en,
    c.city_id,
    c.name_ar AS city_name_ar,
    c.name_en AS city_name_en,
    co.country_id,
    co.name_ar AS country_name_ar,
    co.name_en AS country_name_en
FROM places AS p
JOIN areas AS a ON a.area_id = p.area_id
JOIN cities AS c ON c.city_id = a.city_id
JOIN countries AS co ON co.country_id = c.country_id
WHERE p.deleted_at IS NULL
  AND p.publication_status = 'published';

CREATE OR REPLACE VIEW v_place_rating_summary AS
SELECT
    p.place_id,
    p.name_en,
    p.average_rating,
    p.review_count,
    COUNT(r.review_id) AS verified_review_rows,
    COALESCE(AVG(r.rating), 0.00) AS calculated_average_rating
FROM places AS p
LEFT JOIN reviews AS r
    ON r.place_id = p.place_id
   AND r.status = 'approved'
   AND r.deleted_at IS NULL
GROUP BY p.place_id, p.name_en, p.average_rating, p.review_count;

CREATE OR REPLACE VIEW v_popular_places AS
SELECT
    p.place_id,
    p.name_ar,
    p.name_en,
    p.average_rating,
    p.review_count,
    p.view_count,
    COUNT(DISTINCT f.user_id) AS favorite_count
FROM places AS p
LEFT JOIN favorites AS f ON f.place_id = p.place_id
WHERE p.deleted_at IS NULL
  AND p.publication_status = 'published'
GROUP BY p.place_id, p.name_ar, p.name_en, p.average_rating, p.review_count, p.view_count;

-- ============================================================
