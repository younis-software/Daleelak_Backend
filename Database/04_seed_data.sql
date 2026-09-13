-- File: 04_seed_data.sql
-- Demo data, test queries, and validation queries.
USE dalilak_db;

-- Seed/demo data
-- ============================================================

START TRANSACTION;

-- The same bcrypt fixture is used only as a non-production demo hash.
INSERT INTO users
(user_id, first_name, last_name, email, password_hash, role, status, created_at)
VALUES
(1, 'Dalilak', 'Admin One', 'admin.one@demo.dalilak.test', '$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin', 'active', '2026-01-01 09:00:00'),
(2, 'Dalilak', 'Admin Two', 'admin.two@demo.dalilak.test', '$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin', 'active', '2026-01-01 09:05:00'),
(3, 'Ahmad', 'Demo', 'ahmad.user@demo.dalilak.test', '$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'user', 'active', '2026-01-02 10:00:00'),
(4, 'Lina', 'Demo', 'lina.user@demo.dalilak.test', '$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'user', 'active', '2026-01-02 10:05:00'),
(5, 'Omar', 'Demo', 'omar.user@demo.dalilak.test', '$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'user', 'active', '2026-01-02 10:10:00'),
(6, 'Sara', 'Demo', 'sara.user@demo.dalilak.test', '$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'user', 'active', '2026-01-02 10:15:00'),
(7, 'Noor', 'Demo', 'noor.user@demo.dalilak.test', '$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'user', 'active', '2026-01-02 10:20:00');

INSERT INTO user_profiles (user_id, display_name, preferred_language)
VALUES
(1, 'Dalilak Admin One', 'en'), (2, 'Dalilak Admin Two', 'ar'),
(3, 'Ahmad Demo', 'ar'), (4, 'Lina Demo', 'en'), (5, 'Omar Demo', 'ar'),
(6, 'Sara Demo', 'en'), (7, 'Noor Demo', 'ar');

INSERT INTO countries (country_id, country_code, name_ar, name_en) VALUES
(1, 'JO', 'الأردن', 'Jordan'),
(2, 'SA', 'السعودية', 'Saudi Arabia'),
(3, 'AE', 'الإمارات العربية المتحدة', 'United Arab Emirates'),
(4, 'EG', 'مصر', 'Egypt'),
(5, 'PS', 'فلسطين', 'Palestine');

INSERT INTO cities (city_id, country_id, name_ar, name_en, latitude, longitude) VALUES
(1, 1, 'عمّان', 'Amman', 31.9539, 35.9106),
(2, 1, 'العقبة', 'Aqaba', 29.5321, 35.0063),
(3, 1, 'إربد', 'Irbid', 32.5569, 35.8469),
(4, 1, 'الزرقاء', 'Zarqa', 32.0728, 36.0879),
(5, 1, 'وادي موسى', 'Wadi Musa', 30.3285, 35.4444),
(6, 2, 'الرياض', 'Riyadh', 24.7136, 46.6753),
(7, 3, 'دبي', 'Dubai', 25.2048, 55.2708),
(8, 4, 'القاهرة', 'Cairo', 30.0444, 31.2357);

INSERT INTO areas (area_id, city_id, name_ar, name_en, latitude, longitude) VALUES
(1, 1, 'وسط البلد', 'Downtown Amman', 31.9516, 35.9340),
(2, 1, 'جبل عمّان', 'Jabal Amman', 31.9474, 35.9270),
(3, 1, 'جبل اللويبدة', 'Jabal Al-Weibdeh', 31.9580, 35.9240),
(4, 1, 'العبدلي', 'Abdali', 31.9632, 35.9106),
(5, 1, 'عبدون', 'Abdoun', 31.9500, 35.8830),
(6, 1, 'الصويفية', 'Sweifieh', 31.9540, 35.8660),
(7, 1, 'حدائق الحسين', 'Al Hussein Parks', 31.9880, 35.8350),
(8, 1, 'شارع مكة', 'Mecca Street', 31.9780, 35.8720),
(9, 2, 'واجهة العقبة', 'Aqaba Waterfront', 29.5260, 35.0100),
(10, 5, 'وسط وادي موسى', 'Wadi Musa Center', 30.3285, 35.4444),
(11, 3, 'وسط إربد', 'Irbid Downtown', 32.5560, 35.8470),
(12, 1, 'الشميساني', 'Al Shmeisani', 31.9670, 35.9000),
(13, 1, 'المدينة الرياضية', 'Sports City', 31.9950, 35.8950);

INSERT INTO categories (category_id, parent_category_id, name_ar, name_en, slug) VALUES
(1, NULL, 'معالم سياحية', 'Tourist Attractions', 'tourist-attractions'),
(2, NULL, 'أماكن تاريخية', 'Historical Places', 'historical-places'),
(3, NULL, 'أماكن أثرية', 'Archaeological Places', 'archaeological-places'),
(4, NULL, 'أماكن ثقافية', 'Cultural Places', 'cultural-places'),
(5, NULL, 'متاحف', 'Museums', 'museums'),
(6, NULL, 'حدائق عامة', 'Parks', 'parks'),
(7, 6, 'حدائق', 'Gardens', 'gardens'),
(8, NULL, 'أماكن طبيعية', 'Natural Places', 'natural-places'),
(9, NULL, 'مطاعم', 'Restaurants', 'restaurants'),
(10, NULL, 'مقاهي', 'Cafés', 'cafes'),
(11, NULL, 'فنادق', 'Hotels', 'hotels'),
(12, NULL, 'تسوق', 'Shopping', 'shopping'),
(13, 12, 'أسواق شعبية', 'Traditional Markets', 'traditional-markets'),
(14, NULL, 'ترفيه', 'Entertainment', 'entertainment'),
(15, 14, 'أماكن عائلية', 'Family Places', 'family-places');

INSERT INTO amenities (amenity_id, name_ar, name_en, slug, icon_name) VALUES
(1, 'واي فاي مجاني', 'Free Wi-Fi', 'free-wifi', 'wifi'),
(2, 'مواقف سيارات', 'Parking', 'parking', 'car'),
(3, 'مناسب للعائلات', 'Family Friendly', 'family-friendly', 'users'),
(4, 'مهيأ للكراسي المتحركة', 'Wheelchair Accessible', 'wheelchair-accessible', 'accessibility'),
(5, 'جلسات خارجية', 'Outdoor Seating', 'outdoor-seating', 'sun'),
(6, 'جلسات داخلية', 'Indoor Seating', 'indoor-seating', 'home'),
(7, 'دورات مياه', 'Restrooms', 'restrooms', 'bath'),
(8, 'منطقة أطفال', 'Kids Area', 'kids-area', 'baby'),
(9, 'تكييف', 'Air Conditioning', 'air-conditioning', 'snowflake'),
(10, 'مناسب للحيوانات الأليفة', 'Pet Friendly', 'pet-friendly', 'paw-print'),
(11, 'إفطار', 'Breakfast', 'breakfast', 'coffee'),
(12, 'استقبال فندقي', 'Hotel Reception', 'hotel-reception', 'concierge-bell'),
(13, 'جولات إرشادية', 'Guided Tours', 'guided-tours', 'map'),
(14, 'بطاقات ائتمانية', 'Credit Cards Accepted', 'credit-cards', 'credit-card'),
(15, 'مصلى', 'Prayer Room', 'prayer-room', 'landmark'),
(16, 'إطلالة بانورامية', 'Scenic View', 'scenic-view', 'mountain'),
(17, 'قرب المواصلات', 'Public Transport Nearby', 'public-transport', 'bus'),
(18, 'توصيل', 'Delivery Available', 'delivery', 'truck'),
(19, 'حجز مسبق', 'Reservations Available', 'reservations', 'calendar'),
(20, 'حراسة', 'Security', 'security', 'shield');

INSERT INTO tags (tag_id, name_ar, name_en, slug) VALUES
(1, 'عائلي', 'Family', 'family'),
(2, 'رومانسي', 'Romantic', 'romantic'),
(3, 'اقتصادي', 'Cheap', 'cheap'),
(4, 'فاخر', 'Luxury', 'luxury'),
(5, 'خارجي', 'Outdoor', 'outdoor'),
(6, 'داخلي', 'Indoor', 'indoor'),
(7, 'للأطفال', 'Kids', 'kids'),
(8, 'شائع', 'Popular', 'popular'),
(9, 'هادئ', 'Quiet', 'quiet'),
(10, 'طبيعة', 'Nature', 'nature'),
(11, 'تاريخي', 'Historical', 'historical'),
(12, 'ثقافي', 'Cultural', 'cultural'),
(13, 'حياة ليلية', 'Nightlife', 'nightlife'),
(14, 'منظر خلاب', 'Scenic', 'scenic'),
(15, 'تجربة محلية', 'Local Experience', 'local-experience');

INSERT INTO places
(place_id, area_id, name_ar, name_en, description_ar, description_en, slug, address, place_location, phone, email, website, google_maps_url, price_level, is_featured, is_verified, publication_status, created_by)
VALUES
(1, 1, 'قلعة عمّان - بيانات تجريبية', 'Amman Citadel - Demo', 'موقع تاريخي تجريبي في وسط عمّان.', 'A clearly marked demo record inspired by Amman heritage sites.', 'amman-citadel-demo', 'Demo address, Downtown Amman', ST_SRID(POINT(35.9342,31.9516),4326), '+962790000001', 'citadel@demo.dalilak.test', 'https://example.test/dalilak/amman-citadel', 'https://maps.example.test/amman-citadel', 2, TRUE, TRUE, 'published', 1),
(2, 1, 'المسرح الروماني - بيانات تجريبية', 'Roman Theatre - Demo', 'سجل تجريبي لمعلم أثري.', 'A demo archaeological attraction record.', 'roman-theatre-demo', 'Demo address, Downtown Amman', ST_SRID(POINT(35.9350,31.9510),4326), '+962790000002', 'theatre@demo.dalilak.test', 'https://example.test/dalilak/roman-theatre', 'https://maps.example.test/roman-theatre', 2, TRUE, TRUE, 'published', 1),
(3, 2, 'ممشى شارع الرينبو - تجريبي', 'Rainbow Street Walk - Demo', 'تجربة تجريبية للمشي والمقاهي.', 'A demo walking and café discovery record.', 'rainbow-street-demo', 'Demo address, Jabal Amman', ST_SRID(POINT(35.9272,31.9470),4326), '+962790000003', 'rainbow@demo.dalilak.test', NULL, 'https://maps.example.test/rainbow-street', 2, TRUE, TRUE, 'published', 1),
(4, 7, 'حدائق الملك حسين - تجريبي', 'King Hussein Gardens - Demo', 'مساحات خضراء تجريبية للعائلات.', 'A demo green-space record for family activities.', 'king-hussein-gardens-demo', 'Demo address, Al Hussein Parks', ST_SRID(POINT(35.8352,31.9882),4326), '+962790000004', 'gardens@demo.dalilak.test', NULL, 'https://maps.example.test/king-hussein-gardens', 1, TRUE, TRUE, 'published', 1),
(5, 4, 'بوليفارد العبدلي - تجريبي', 'Abdali Boulevard - Demo', 'سجل تجريبي للتسوق والمطاعم.', 'A demo shopping and dining destination.', 'abdali-boulevard-demo', 'Demo address, Abdali', ST_SRID(POINT(35.9108,31.9634),4326), '+962790000005', 'abdali@demo.dalilak.test', NULL, 'https://maps.example.test/abdali-boulevard', 3, TRUE, TRUE, 'published', 1),
(6, 5, 'تاج مول - تجريبي', 'Taj Mall - Demo', 'مركز تسوق تجريبي للعائلات.', 'A clearly marked demo shopping mall record.', 'taj-mall-demo', 'Demo address, Abdoun', ST_SRID(POINT(35.8832,31.9502),4326), '+962790000006', 'taj@demo.dalilak.test', NULL, 'https://maps.example.test/taj-mall', 3, FALSE, TRUE, 'published', 1),
(7, 8, 'سيتي مول - تجريبي', 'City Mall - Demo', 'مركز ترفيهي وتسوق تجريبي.', 'A demo mall and entertainment record.', 'city-mall-demo', 'Demo address, Mecca Street', ST_SRID(POINT(35.8722,31.9782),4326), '+962790000007', 'citymall@demo.dalilak.test', NULL, 'https://maps.example.test/city-mall', 3, FALSE, TRUE, 'published', 1),
(8, 1, 'سوق البلد الشعبي - تجريبي', 'Al-Balad Traditional Market - Demo', 'سوق تجريبي للتجارب المحلية.', 'A demo traditional market experience.', 'al-balad-market-demo', 'Demo address, Downtown Amman', ST_SRID(POINT(35.9345,31.9522),4326), '+962790000008', 'market@demo.dalilak.test', NULL, 'https://maps.example.test/al-balad-market', 1, TRUE, TRUE, 'published', 1),
(9, 3, 'مقهى اللويبدة الفني - تجريبي', 'Weibdeh Art Café - Demo', 'مقهى تجريبي هادئ بطابع ثقافي.', 'A quiet demo café with a cultural theme.', 'weibdeh-art-cafe-demo', 'Demo address, Jabal Al-Weibdeh', ST_SRID(POINT(35.9242,31.9582),4326), '+962790000009', 'weibdeh@demo.dalilak.test', NULL, 'https://maps.example.test/weibdeh-art-cafe', 2, FALSE, TRUE, 'published', 1),
(10, 1, 'المطبخ الأردني التجريبي', 'Jordanian Kitchen - Demo', 'مطعم تجريبي يقدم أطباقاً محلية.', 'A fictional demo restaurant serving local-style dishes.', 'jordanian-kitchen-demo', 'Demo address, Downtown Amman', ST_SRID(POINT(35.9335,31.9518),4326), '+962790000010', 'kitchen@demo.dalilak.test', NULL, 'https://maps.example.test/jordanian-kitchen', 2, FALSE, TRUE, 'published', 1),
(11, 2, 'مقهى التلال السبعة - تجريبي', 'Seven Hills Café - Demo', 'مقهى تجريبي بإطلالة.', 'A fictional demo café with a scenic view.', 'seven-hills-cafe-demo', 'Demo address, Jabal Amman', ST_SRID(POINT(35.9278,31.9468),4326), '+962790000011', 'sevenhills@demo.dalilak.test', NULL, 'https://maps.example.test/seven-hills-cafe', 2, TRUE, TRUE, 'published', 1),
(12, 4, 'فندق إطلالة عمّان - تجريبي', 'Amman View Hotel - Demo', 'فندق تجريبي بخدمات إقامة.', 'A fictional demo hotel record.', 'amman-view-hotel-demo', 'Demo address, Abdali', ST_SRID(POINT(35.9098,31.9638),4326), '+962790000012', 'hotel@demo.dalilak.test', NULL, 'https://maps.example.test/amman-view-hotel', 4, FALSE, TRUE, 'published', 1),
(13, 2, 'بيت الزيتون للضيافة - تجريبي', 'Olive Tree Guesthouse - Demo', 'بيت ضيافة تجريبي مناسب للعائلات.', 'A fictional family-friendly demo guesthouse.', 'olive-tree-guesthouse-demo', 'Demo address, Jabal Amman', ST_SRID(POINT(35.9265,31.9462),4326), '+962790000013', 'olive@demo.dalilak.test', NULL, 'https://maps.example.test/olive-tree-guesthouse', 3, FALSE, FALSE, 'published', 1),
(14, 10, 'وادي الموجب الطبيعي - تجريبي', 'Wadi Mujib Nature - Demo', 'سجل تجريبي لموقع طبيعي.', 'A fictional demo natural attraction record.', 'wadi-mujib-nature-demo', 'Demo address, Wadi Musa area', ST_SRID(POINT(35.6950,31.4650),4326), '+962790000014', 'wadi@demo.dalilak.test', NULL, 'https://maps.example.test/wadi-mujib-nature', 2, TRUE, TRUE, 'published', 1),
(15, 9, 'واجهة العقبة البحرية - تجريبي', 'Aqaba Waterfront - Demo', 'واجهة بحرية تجريبية للترفيه.', 'A fictional demo waterfront attraction.', 'aqaba-waterfront-demo', 'Demo address, Aqaba Waterfront', ST_SRID(POINT(35.0102,29.5262),4326), '+962790000015', 'aqaba@demo.dalilak.test', NULL, 'https://maps.example.test/aqaba-waterfront', 2, TRUE, TRUE, 'published', 1),
(16, 7, 'متحف السيارات الملكي - تجريبي', 'Royal Automobile Museum - Demo', 'سجل تجريبي لمتحف ثقافي.', 'A fictional demo museum record.', 'automobile-museum-demo', 'Demo address, Al Hussein Parks', ST_SRID(POINT(35.8358,31.9885),4326), '+962790000016', 'museum@demo.dalilak.test', NULL, 'https://maps.example.test/automobile-museum', 2, FALSE, TRUE, 'published', 1),
(17, 7, 'حديقة اكتشاف الأطفال - تجريبية', 'Children Discovery Garden - Demo', 'حديقة تجريبية للأطفال.', 'A fictional demo garden for children.', 'children-discovery-garden-demo', 'Demo address, Al Hussein Parks', ST_SRID(POINT(35.8348,31.9876),4326), '+962790000017', 'kids@demo.dalilak.test', NULL, 'https://maps.example.test/children-discovery-garden', 1, FALSE, TRUE, 'published', 1),
(18, 6, 'ألعاب الهروب عمّان - تجريبي', 'Amman Escape Games - Demo', 'تجربة ترفيهية داخلية تجريبية.', 'A fictional indoor entertainment record.', 'amman-escape-games-demo', 'Demo address, Sweifieh', ST_SRID(POINT(35.8662,31.9542),4326), '+962790000018', 'escape@demo.dalilak.test', NULL, 'https://maps.example.test/amman-escape-games', 2, FALSE, FALSE, 'published', 1),
(19, 1, 'سوق الشعب - تجريبي', 'Souq Al-Shaab - Demo', 'سوق تقليدي تجريبي.', 'A fictional traditional market record.', 'souq-al-shaab-demo', 'Demo address, Downtown Amman', ST_SRID(POINT(35.9338,31.9525),4326), '+962790000019', 'souq@demo.dalilak.test', NULL, 'https://maps.example.test/souq-al-shaab', 1, FALSE, FALSE, 'published', 1),
(20, 3, 'بيت التراث الأردني - تجريبي', 'Jordan Heritage House - Demo', 'مركز تراثي وثقافي تجريبي.', 'A fictional demo cultural heritage venue.', 'jordan-heritage-house-demo', 'Demo address, Jabal Al-Weibdeh', ST_SRID(POINT(35.9238,31.9576),4326), '+962790000020', 'heritage@demo.dalilak.test', NULL, 'https://maps.example.test/jordan-heritage-house', 2, FALSE, FALSE, 'pending', 1);

INSERT INTO place_categories (place_id, category_id, is_primary) VALUES
(1,1,TRUE),(1,2,FALSE),(1,3,FALSE),(2,2,TRUE),(2,3,FALSE),(2,4,FALSE),
(3,1,TRUE),(3,12,FALSE),(4,6,TRUE),(4,7,FALSE),(4,15,FALSE),(5,12,TRUE),(5,14,FALSE),(5,15,FALSE),
(6,12,TRUE),(6,15,FALSE),(7,12,TRUE),(7,14,FALSE),(8,13,TRUE),(8,12,FALSE),(8,4,FALSE),
(9,10,TRUE),(9,4,FALSE),(9,15,FALSE),(10,9,TRUE),(10,15,FALSE),(11,10,TRUE),(11,1,FALSE),
(12,11,TRUE),(13,11,TRUE),(13,15,FALSE),(14,8,TRUE),(14,1,FALSE),(15,8,TRUE),(15,14,FALSE),
(16,5,TRUE),(16,4,FALSE),(17,7,TRUE),(17,15,FALSE),(18,14,TRUE),(18,15,FALSE),
(19,13,TRUE),(19,12,FALSE),(20,4,TRUE),(20,2,FALSE);

INSERT INTO place_amenities (place_id, amenity_id) VALUES
(1,2),(1,7),(1,13),(1,16),(2,2),(2,7),(2,13),(3,5),(3,6),(3,7),
(4,2),(4,3),(4,4),(4,7),(4,8),(5,1),(5,2),(5,4),(5,7),(5,14),
(6,2),(6,3),(6,4),(6,7),(6,9),(7,2),(7,3),(7,7),(7,9),(8,2),
(8,7),(8,15),(9,1),(9,5),(9,6),(9,7),(9,9),(10,1),(10,2),(10,6),
(10,7),(10,9),(10,14),(11,1),(11,5),(11,6),(11,16),(12,1),(12,2),(12,4),
(12,7),(12,9),(12,11),(12,12),(13,1),(13,2),(13,3),(13,7),(14,2),(14,13),
(14,16),(15,2),(15,3),(15,7),(15,16),(16,2),(16,4),(16,7),(16,13),(17,2),
(17,3),(17,4),(17,7),(17,8),(18,2),(18,3),(18,6),(18,7),(19,2),(19,7),
(20,1),(20,4),(20,7),(20,13);

INSERT INTO place_tags (place_id, tag_id) VALUES
(1,8),(1,11),(1,12),(2,8),(2,11),(2,12),(3,8),(3,5),(3,15),(4,1),(4,5),(4,7),
(5,8),(5,6),(6,1),(6,7),(7,1),(7,6),(8,15),(8,12),(9,9),(9,6),(9,12),
(10,1),(10,15),(11,2),(11,14),(12,4),(12,8),(13,1),(13,9),(14,10),(14,5),
(15,10),(15,14),(16,12),(16,11),(17,1),(17,7),(18,6),(18,7),(19,15),(20,12),(20,11);

INSERT INTO place_images (place_id, image_url, storage_key, title, alt_text, display_order, is_primary) VALUES
(1,'https://images.example.test/dalilak/places/1-1.jpg','demo/places/1-1.jpg','Citadel demo image','Demo image of Amman Citadel',1,TRUE),
(1,'https://images.example.test/dalilak/places/1-2.jpg','demo/places/1-2.jpg','Citadel detail','Demo detail image',2,FALSE),
(2,'https://images.example.test/dalilak/places/2-1.jpg','demo/places/2-1.jpg','Theatre demo image','Demo image of Roman Theatre',1,TRUE),
(2,'https://images.example.test/dalilak/places/2-2.jpg','demo/places/2-2.jpg','Theatre seating','Demo theatre detail',2,FALSE),
(3,'https://images.example.test/dalilak/places/3-1.jpg','demo/places/3-1.jpg','Street demo image','Demo Rainbow Street image',1,TRUE),
(4,'https://images.example.test/dalilak/places/4-1.jpg','demo/places/4-1.jpg','Garden demo image','Demo family garden image',1,TRUE),
(5,'https://images.example.test/dalilak/places/5-1.jpg','demo/places/5-1.jpg','Boulevard demo image','Demo Abdali Boulevard image',1,TRUE),
(6,'https://images.example.test/dalilak/places/6-1.jpg','demo/places/6-1.jpg','Mall demo image','Demo Taj Mall image',1,TRUE),
(7,'https://images.example.test/dalilak/places/7-1.jpg','demo/places/7-1.jpg','City Mall demo image','Demo City Mall image',1,TRUE),
(8,'https://images.example.test/dalilak/places/8-1.jpg','demo/places/8-1.jpg','Market demo image','Demo traditional market image',1,TRUE),
(9,'https://images.example.test/dalilak/places/9-1.jpg','demo/places/9-1.jpg','Cafe demo image','Demo art cafe image',1,TRUE),
(10,'https://images.example.test/dalilak/places/10-1.jpg','demo/places/10-1.jpg','Restaurant demo image','Demo restaurant image',1,TRUE),
(11,'https://images.example.test/dalilak/places/11-1.jpg','demo/places/11-1.jpg','Cafe view','Demo scenic cafe image',1,TRUE),
(12,'https://images.example.test/dalilak/places/12-1.jpg','demo/places/12-1.jpg','Hotel demo image','Demo hotel image',1,TRUE),
(13,'https://images.example.test/dalilak/places/13-1.jpg','demo/places/13-1.jpg','Guesthouse demo image','Demo guesthouse image',1,TRUE),
(14,'https://images.example.test/dalilak/places/14-1.jpg','demo/places/14-1.jpg','Nature demo image','Demo nature attraction image',1,TRUE),
(15,'https://images.example.test/dalilak/places/15-1.jpg','demo/places/15-1.jpg','Waterfront demo image','Demo waterfront image',1,TRUE),
(16,'https://images.example.test/dalilak/places/16-1.jpg','demo/places/16-1.jpg','Museum demo image','Demo museum image',1,TRUE),
(17,'https://images.example.test/dalilak/places/17-1.jpg','demo/places/17-1.jpg','Garden demo image','Demo children garden image',1,TRUE),
(18,'https://images.example.test/dalilak/places/18-1.jpg','demo/places/18-1.jpg','Games demo image','Demo escape games image',1,TRUE),
(19,'https://images.example.test/dalilak/places/19-1.jpg','demo/places/19-1.jpg','Souq demo image','Demo souq image',1,TRUE),
(20,'https://images.example.test/dalilak/places/20-1.jpg','demo/places/20-1.jpg','Heritage demo image','Demo heritage house image',1,TRUE);

-- Weekly recurring schedules. Several places use split periods and one uses an overnight period.
INSERT INTO opening_hours (place_id, day_of_week, period_number, opens_at, closes_at, closes_next_day, is_closed, is_24_hours) VALUES
(1,1,1,'09:00','17:00',FALSE,FALSE,FALSE),(1,2,1,'09:00','17:00',FALSE,FALSE,FALSE),(1,3,1,'09:00','17:00',FALSE,FALSE,FALSE),(1,4,1,'09:00','17:00',FALSE,FALSE,FALSE),(1,5,1,'09:00','17:00',FALSE,FALSE,FALSE),(1,6,1,'09:00','17:00',FALSE,FALSE,FALSE),(1,7,1,'09:00','17:00',FALSE,FALSE,FALSE),
(2,1,1,'08:00','16:00',FALSE,FALSE,FALSE),(2,2,1,'08:00','16:00',FALSE,FALSE,FALSE),(2,3,1,'08:00','16:00',FALSE,FALSE,FALSE),(2,4,1,'08:00','16:00',FALSE,FALSE,FALSE),(2,5,1,'08:00','16:00',FALSE,FALSE,FALSE),(2,6,1,'08:00','16:00',FALSE,FALSE,FALSE),(2,7,1,'08:00','16:00',FALSE,FALSE,FALSE),
(3,1,1,'09:00','13:00',FALSE,FALSE,FALSE),(3,1,2,'16:00','22:00',FALSE,FALSE,FALSE),(3,2,1,'09:00','13:00',FALSE,FALSE,FALSE),(3,2,2,'16:00','22:00',FALSE,FALSE,FALSE),(3,3,1,'09:00','13:00',FALSE,FALSE,FALSE),(3,3,2,'16:00','22:00',FALSE,FALSE,FALSE),(3,4,1,'09:00','13:00',FALSE,FALSE,FALSE),(3,4,2,'16:00','22:00',FALSE,FALSE,FALSE),(3,5,1,'09:00','13:00',FALSE,FALSE,FALSE),(3,5,2,'16:00','23:00',FALSE,FALSE,FALSE),(3,6,1,'09:00','23:00',FALSE,FALSE,FALSE),(3,7,1,'09:00','22:00',FALSE,FALSE,FALSE),
(4,1,1,NULL,NULL,FALSE,TRUE,FALSE),(4,2,1,'08:00','21:00',FALSE,FALSE,FALSE),(4,3,1,'08:00','21:00',FALSE,FALSE,FALSE),(4,4,1,'08:00','21:00',FALSE,FALSE,FALSE),(4,5,1,'08:00','21:00',FALSE,FALSE,FALSE),(4,6,1,'08:00','21:00',FALSE,FALSE,FALSE),(4,7,1,'08:00','21:00',FALSE,FALSE,FALSE),
(5,1,1,'10:00','23:00',FALSE,FALSE,FALSE),(5,2,1,'10:00','23:00',FALSE,FALSE,FALSE),(5,3,1,'10:00','23:00',FALSE,FALSE,FALSE),(5,4,1,'10:00','23:00',FALSE,FALSE,FALSE),(5,5,1,'10:00','00:00',TRUE,FALSE,FALSE),(5,6,1,'10:00','00:00',TRUE,FALSE,FALSE),(5,7,1,'10:00','23:00',FALSE,FALSE,FALSE),
(9,1,1,'08:00','22:00',FALSE,FALSE,FALSE),(9,2,1,'08:00','22:00',FALSE,FALSE,FALSE),(9,3,1,'08:00','22:00',FALSE,FALSE,FALSE),(9,4,1,'08:00','22:00',FALSE,FALSE,FALSE),(9,5,1,'08:00','23:00',FALSE,FALSE,FALSE),(9,6,1,'09:00','23:00',FALSE,FALSE,FALSE),(9,7,1,'09:00','22:00',FALSE,FALSE,FALSE),
(18,1,1,'16:00','02:00',TRUE,FALSE,FALSE),(18,2,1,'16:00','02:00',TRUE,FALSE,FALSE),(18,3,1,'16:00','02:00',TRUE,FALSE,FALSE),(18,4,1,'16:00','02:00',TRUE,FALSE,FALSE),(18,5,1,'16:00','03:00',TRUE,FALSE,FALSE),(18,6,1,'12:00','03:00',TRUE,FALSE,FALSE),(18,7,1,'12:00','23:00',FALSE,FALSE,FALSE);

INSERT INTO place_contacts (place_id, contact_type, contact_value, label, is_primary) VALUES
(1,'phone','+962790000001','Demo phone',TRUE),(1,'website','https://example.test/dalilak/amman-citadel','Demo website',TRUE),
(5,'phone','+962790000005','Demo phone',TRUE),(5,'instagram','https://social.example.test/dalilak/abdali','Demo Instagram',TRUE),
(9,'phone','+962790000009','Demo phone',TRUE),(9,'whatsapp','+962790000009','Demo WhatsApp',FALSE),
(10,'email','kitchen@demo.dalilak.test','Demo email',TRUE),(12,'phone','+962790000012','Demo phone',TRUE),
(15,'phone','+962790000015','Demo phone',TRUE),(18,'tiktok','https://social.example.test/dalilak/escape','Demo TikTok',TRUE);

INSERT INTO reviews (review_id, place_id, user_id, rating, review_text, status, moderated_by, moderated_at) VALUES
(1,1,3,5,'تجربة تجريبية ممتازة ومفيدة.','approved',1,'2026-02-01 10:00:00'),
(2,1,4,4,'Demo review for the historical location.','approved',1,'2026-02-01 10:05:00'),
(3,2,5,5,'سجل مراجعة تجريبي للمسرح.','approved',2,'2026-02-02 10:00:00'),
(4,3,6,4,'Nice demo walking area.','approved',1,'2026-02-02 10:05:00'),
(5,4,7,5,'مكان عائلي تجريبي جميل.','approved',2,'2026-02-03 10:00:00'),
(6,5,3,4,'Useful demo shopping entry.','approved',1,'2026-02-03 10:05:00'),
(7,9,4,5,'مقهى تجريبي هادئ.','approved',2,'2026-02-04 10:00:00'),
(8,10,5,3,'Demo review awaiting moderation.','pending',NULL,NULL),
(9,11,6,5,'A scenic demo café.','approved',1,'2026-02-05 10:00:00'),
(10,12,7,4,'Demo hotel review.','approved',2,'2026-02-05 10:05:00'),
(11,18,3,2,'Demo review rejected for testing.','rejected',1,'2026-02-06 10:00:00'),
(12,20,4,5,'Pending review for the pending place.','pending',NULL,NULL);

INSERT INTO favorites (user_id, place_id) VALUES
(3,1),(3,4),(3,5),(3,11),(4,1),(4,3),(4,9),(4,12),(5,2),(5,5),(5,10),(6,4),(6,11),(6,15),(7,1),(7,16),(7,17),(7,19);

INSERT INTO place_views (place_id, user_id, session_id, ip_hash, viewed_at) VALUES
(1,3,'demo-session-001',NULL,'2026-02-01 10:00:00'),(1,4,'demo-session-002',NULL,'2026-02-02 10:00:00'),(1,NULL,'demo-session-003','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa','2026-02-03 10:00:00'),
(2,5,'demo-session-004',NULL,'2026-02-03 11:00:00'),(2,6,'demo-session-005',NULL,'2026-02-04 11:00:00'),(3,4,'demo-session-006',NULL,'2026-02-04 12:00:00'),
(4,7,'demo-session-007',NULL,'2026-02-05 12:00:00'),(4,NULL,'demo-session-008','bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb','2026-02-05 13:00:00'),
(5,3,'demo-session-009',NULL,'2026-02-06 14:00:00'),(5,4,'demo-session-010',NULL,'2026-02-06 15:00:00'),(5,5,'demo-session-011',NULL,'2026-02-07 15:00:00'),
(9,6,'demo-session-012',NULL,'2026-02-07 16:00:00'),(10,3,'demo-session-013',NULL,'2026-02-08 17:00:00'),(11,6,'demo-session-014',NULL,'2026-02-08 18:00:00'),
(12,7,'demo-session-015',NULL,'2026-02-09 19:00:00'),(15,NULL,'demo-session-016','cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc','2026-02-10 20:00:00'),
(16,7,'demo-session-017',NULL,'2026-02-10 20:00:00'),(17,7,'demo-session-018',NULL,'2026-02-11 20:00:00'),(18,3,'demo-session-019',NULL,'2026-02-11 21:00:00'),(19,5,'demo-session-020',NULL,'2026-02-12 21:00:00');

INSERT INTO user_interactions (user_id, place_id, interaction_type, metadata_json) VALUES
(3,1,'view',JSON_OBJECT('source','home')),(3,1,'share',JSON_OBJECT('channel','demo')),(4,9,'map_open',JSON_OBJECT('source','search')),
(5,5,'favorite',JSON_OBJECT('source','place_detail')),(6,11,'view',JSON_OBJECT('source','nearby')),(7,17,'map_open',JSON_OBJECT('source','category')),
(3,NULL,'search',JSON_OBJECT('query','historical places')),(4,3,'view',JSON_OBJECT('source','category')),(5,10,'review',JSON_OBJECT('rating',3)),(6,15,'favorite',JSON_OBJECT('source','place_detail'));

INSERT INTO place_reports (place_id, reported_by, reason, description, status) VALUES
(6,3,'incorrect_information','Demo report: address needs review.','pending'),
(13,4,'duplicate_place','Demo report for moderation testing.','resolved'),
(20,5,'missing_details','Pending demo place needs more information.','pending');

INSERT INTO review_reports (review_id, reported_by, reason, description, status) VALUES
(11,6,'inappropriate_content','Demo report against a rejected review.','resolved'),
(8,7,'needs_review','Demo pending review report.','pending');

INSERT INTO notifications (user_id, notification_type, title, message, entity_type, entity_id) VALUES
(3,'review_approved','Review approved','Your demo review was approved.','review',1),
(4,'place_verified','Place verified','A demo place was verified by an administrator.','place',3),
(5,'report_received','Report received','Your demo report is waiting for review.','place_report',1),
(6,'featured_place','Featured place','A new demo featured place is available.','place',11),
(7,'review_pending','Review pending','Your demo review is awaiting moderation.','review',12);

INSERT INTO admin_activity_logs (admin_user_id, action_type, entity_type, entity_id, description, ip_address) VALUES
(1,'create','place',1,'Created demo historical place','192.0.2.10'),
(1,'verify','place',1,'Verified demo place','192.0.2.10'),
(2,'approve','review',1,'Approved demo review','192.0.2.11'),
(2,'resolve','place_report',2,'Resolved demo place report','192.0.2.11'),
(1,'update','category',14,'Updated entertainment category','192.0.2.10');

COMMIT;

-- ============================================================
-- Test queries
-- Uncomment or run individually in MySQL Workbench/mysql2.
-- ============================================================

-- 1. Active places
SELECT * FROM v_active_places ORDER BY name_en;

-- 2. Places by category
SELECT DISTINCT p.place_id, p.name_en
FROM places p JOIN place_categories pc ON pc.place_id = p.place_id
JOIN categories c ON c.category_id = pc.category_id
WHERE c.slug = 'historical-places' AND p.deleted_at IS NULL AND p.publication_status = 'published';

-- 3. Places in Amman
SELECT p.place_id, p.name_en, a.name_en AS area_name
FROM places p JOIN areas a ON a.area_id = p.area_id JOIN cities c ON c.city_id = a.city_id
WHERE c.name_en = 'Amman' AND p.deleted_at IS NULL AND p.publication_status = 'published';

-- 4. Places in an area
SELECT p.* FROM places p JOIN areas a ON a.area_id = p.area_id
WHERE a.name_en = 'Downtown Amman' AND p.deleted_at IS NULL;

-- 5. Highest-rated places
SELECT * FROM places WHERE publication_status = 'published' AND deleted_at IS NULL
ORDER BY average_rating DESC, review_count DESC LIMIT 20;

-- 6. Featured places
SELECT * FROM places WHERE is_featured = TRUE AND publication_status = 'published' AND deleted_at IS NULL;

-- 7. Verified places
SELECT * FROM places WHERE is_verified = TRUE AND publication_status = 'published' AND deleted_at IS NULL;

-- 8. Nearby places within 5 km of central Amman
SET @user_longitude = 35.9106;
SET @user_latitude = 31.9539;
SET @radius_meters = 5000;
SELECT p.place_id, p.name_en,
       ST_Distance_Sphere(p.place_location, ST_SRID(POINT(@user_longitude,@user_latitude),4326)) AS distance_meters
FROM places p
WHERE p.publication_status = 'published' AND p.deleted_at IS NULL
  AND ST_Distance_Sphere(p.place_location, ST_SRID(POINT(@user_longitude,@user_latitude),4326)) <= @radius_meters
ORDER BY distance_meters, p.place_id;

-- 9. Places with parking
SELECT DISTINCT p.place_id, p.name_en
FROM places p JOIN place_amenities pa ON pa.place_id = p.place_id
JOIN amenities a ON a.amenity_id = pa.amenity_id
WHERE a.slug = 'parking' AND p.publication_status = 'published' AND p.deleted_at IS NULL;

-- 10. Family-friendly places
SELECT DISTINCT p.place_id, p.name_en
FROM places p JOIN place_tags pt ON pt.place_id = p.place_id JOIN tags t ON t.tag_id = pt.tag_id
WHERE t.slug = 'family' AND p.publication_status = 'published' AND p.deleted_at IS NULL;

-- 11. Places in multiple categories
SELECT p.place_id, p.name_en
FROM places p JOIN place_categories pc ON pc.place_id = p.place_id JOIN categories c ON c.category_id = pc.category_id
WHERE c.slug IN ('restaurants','family-places') AND p.deleted_at IS NULL
GROUP BY p.place_id, p.name_en HAVING COUNT(DISTINCT c.slug) = 2;

-- 12. Name search
SELECT place_id, name_ar, name_en FROM places
WHERE deleted_at IS NULL AND publication_status = 'published'
  AND (name_ar LIKE '%تجريبي%' OR name_en LIKE '%Demo%');

-- 13. FULLTEXT search
SELECT place_id, name_en,
       MATCH(name_ar,name_en,description_ar,description_en) AGAINST ('historical' IN NATURAL LANGUAGE MODE) AS relevance
FROM places
WHERE deleted_at IS NULL AND publication_status = 'published'
  AND MATCH(name_ar,name_en,description_ar,description_en) AGAINST ('historical' IN NATURAL LANGUAGE MODE)
ORDER BY relevance DESC;

-- 14. User favorites
SELECT p.* FROM favorites f JOIN places p ON p.place_id = f.place_id
WHERE f.user_id = 3 AND p.deleted_at IS NULL ORDER BY f.created_at DESC;

-- 15. User reviews
SELECT r.*, p.name_en FROM reviews r JOIN places p ON p.place_id = r.place_id
WHERE r.user_id = 3 ORDER BY r.created_at DESC;

-- 16. Most viewed places
SELECT p.place_id, p.name_en, COUNT(v.view_id) AS total_views
FROM places p JOIN place_views v ON v.place_id = p.place_id
WHERE p.deleted_at IS NULL AND p.publication_status = 'published'
GROUP BY p.place_id, p.name_en ORDER BY total_views DESC LIMIT 20;

-- 17. Most favorited places
SELECT p.place_id, p.name_en, COUNT(*) AS favorite_count
FROM favorites f JOIN places p ON p.place_id = f.place_id
WHERE p.deleted_at IS NULL AND p.publication_status = 'published'
GROUP BY p.place_id, p.name_en ORDER BY favorite_count DESC LIMIT 20;

-- 18. Top 10 places
SELECT * FROM places WHERE deleted_at IS NULL AND publication_status = 'published'
ORDER BY average_rating DESC, review_count DESC LIMIT 10;

-- 19. Places with no approved reviews
SELECT p.place_id, p.name_en FROM places p LEFT JOIN reviews r
ON r.place_id = p.place_id AND r.status = 'approved' AND r.deleted_at IS NULL
WHERE p.deleted_at IS NULL AND p.publication_status = 'published'
GROUP BY p.place_id, p.name_en HAVING COUNT(r.review_id) = 0;

-- 20. Pending reports
SELECT 'place' AS report_type, place_report_id AS report_id, reason, created_at
FROM place_reports WHERE status = 'pending'
UNION ALL
SELECT 'review', review_report_id, reason, created_at
FROM review_reports WHERE status = 'pending' ORDER BY created_at;

-- 21. Pending reviews
SELECT r.review_id, p.name_en, r.rating, r.review_text, r.created_at
FROM reviews r JOIN places p ON p.place_id = r.place_id WHERE r.status = 'pending';

-- 22. Admin activity
SELECT l.*, u.email AS admin_email FROM admin_activity_logs l JOIN users u ON u.user_id = l.admin_user_id
ORDER BY l.created_at DESC;

-- 23. Category statistics
SELECT c.category_id, c.name_en, COUNT(DISTINCT pc.place_id) AS place_count
FROM categories c LEFT JOIN place_categories pc ON pc.category_id = c.category_id
LEFT JOIN places p ON p.place_id = pc.place_id AND p.deleted_at IS NULL AND p.publication_status = 'published'
GROUP BY c.category_id, c.name_en ORDER BY place_count DESC;

-- 24. Number of users
SELECT COUNT(*) AS total_users FROM users WHERE deleted_at IS NULL;

-- 25. Number of published places
SELECT COUNT(*) AS total_places FROM places WHERE deleted_at IS NULL AND publication_status = 'published';

-- 26. Average rating
SELECT AVG(average_rating) AS average_rating FROM places
WHERE deleted_at IS NULL AND publication_status = 'published' AND review_count > 0;

-- 27. Places sorted by distance
SELECT p.place_id, p.name_en,
       ST_Distance_Sphere(p.place_location, ST_SRID(POINT(@user_longitude,@user_latitude),4326)) AS distance_meters
FROM places p WHERE p.deleted_at IS NULL AND p.publication_status = 'published'
ORDER BY distance_meters LIMIT 50;

-- 28. Offset pagination
SELECT place_id, name_en, average_rating FROM places
WHERE deleted_at IS NULL AND publication_status = 'published'
ORDER BY place_id DESC LIMIT 10 OFFSET 0;

-- 29. Combined filters: Amman, category, rating, price, verified
SELECT DISTINCT p.place_id, p.name_en, p.average_rating
FROM places p JOIN areas a ON a.area_id = p.area_id JOIN cities c ON c.city_id = a.city_id
JOIN place_categories pc ON pc.place_id = p.place_id JOIN categories cat ON cat.category_id = pc.category_id
JOIN place_amenities pa ON pa.place_id = p.place_id JOIN amenities am ON am.amenity_id = pa.amenity_id
WHERE c.name_en = 'Amman' AND cat.slug = 'family-places' AND am.slug = 'parking'
  AND p.average_rating >= 4 AND p.price_level <= 3 AND p.is_verified = TRUE
  AND p.publication_status = 'published' AND p.deleted_at IS NULL;

-- 30. Open now for a supplied weekday/time. Parameters: 1=Monday, 17:30 current time.
SET @current_day = 1;
SET @current_time = '17:30:00';
SELECT DISTINCT p.place_id, p.name_en
FROM places p JOIN opening_hours oh ON oh.place_id = p.place_id
WHERE p.deleted_at IS NULL AND p.publication_status = 'published'
  AND oh.day_of_week = @current_day AND oh.is_closed = FALSE
  AND (oh.is_24_hours = TRUE OR
       (oh.closes_next_day = FALSE AND @current_time BETWEEN oh.opens_at AND oh.closes_at) OR
       (oh.closes_next_day = TRUE AND @current_time >= oh.opens_at));

-- ============================================================
-- Validation queries
-- ============================================================

-- Expected: 7 users, 5 countries, 8 cities, 13 areas, 15 categories,
-- 20 amenities, 15 tags, 20 places, 12 reviews, 18 favorites.
SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
UNION ALL SELECT 'countries', COUNT(*) FROM countries
UNION ALL SELECT 'cities', COUNT(*) FROM cities
UNION ALL SELECT 'areas', COUNT(*) FROM areas
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'amenities', COUNT(*) FROM amenities
UNION ALL SELECT 'tags', COUNT(*) FROM tags
UNION ALL SELECT 'places', COUNT(*) FROM places
UNION ALL SELECT 'place_images', COUNT(*) FROM place_images
UNION ALL SELECT 'opening_hours', COUNT(*) FROM opening_hours
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL SELECT 'favorites', COUNT(*) FROM favorites
UNION ALL SELECT 'place_views', COUNT(*) FROM place_views
UNION ALL SELECT 'user_interactions', COUNT(*) FROM user_interactions
UNION ALL SELECT 'place_reports', COUNT(*) FROM place_reports
UNION ALL SELECT 'review_reports', COUNT(*) FROM review_reports
UNION ALL SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL SELECT 'admin_activity_logs', COUNT(*) FROM admin_activity_logs;

-- Cached review aggregates must match approved, non-deleted reviews.
SELECT p.place_id, p.average_rating, ROUND(COALESCE(AVG(r.rating),0),2) AS calculated_rating,
       p.review_count, COUNT(r.review_id) AS calculated_count
FROM places p LEFT JOIN reviews r ON r.place_id = p.place_id
 AND r.status = 'approved' AND r.deleted_at IS NULL
GROUP BY p.place_id, p.average_rating, p.review_count
HAVING ROUND(p.average_rating,2) <> ROUND(COALESCE(AVG(r.rating),0),2)
    OR p.review_count <> COUNT(r.review_id);

-- Places without a primary image.
SELECT p.place_id, p.name_en FROM places p
LEFT JOIN place_images i ON i.place_id = p.place_id AND i.is_primary = TRUE AND i.deleted_at IS NULL
WHERE p.deleted_at IS NULL GROUP BY p.place_id, p.name_en HAVING COUNT(i.image_id) = 0;

-- Orphan checks should return zero rows.
SELECT p.place_id FROM places p LEFT JOIN areas a ON a.area_id = p.area_id WHERE a.area_id IS NULL;
SELECT pc.place_id FROM place_categories pc LEFT JOIN places p ON p.place_id = pc.place_id WHERE p.place_id IS NULL;
SELECT pc.category_id FROM place_categories pc LEFT JOIN categories c ON c.category_id = pc.category_id WHERE c.category_id IS NULL;

-- Useful optimizer checks.
EXPLAIN SELECT p.place_id, p.name_en FROM places p
JOIN areas a ON a.area_id = p.area_id JOIN cities c ON c.city_id = a.city_id
WHERE c.city_id = 1 AND p.publication_status = 'published' AND p.deleted_at IS NULL;

EXPLAIN SELECT p.place_id, p.name_en FROM places p
JOIN place_categories pc ON pc.place_id = p.place_id
WHERE pc.category_id = 2 AND p.publication_status = 'published' AND p.deleted_at IS NULL;
