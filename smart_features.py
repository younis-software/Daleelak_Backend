# -*- coding: utf-8 -*-
"""
1) find_nearby_places   -> "حديقة قريبة من مكان محدد"
2) get_place_card       -> بطاقة تفاصيل كاملة لمكان (عنوان، هاتف، رابط خرائط...)
3) get_rating_summary   -> "التقييم"
4) is_open_on           -> "متى بكون المكان مفتوح"
5) filter_by_price      -> فلترة حسب مستوى السعر (1/2/3) + تصنيف اختياري
"""

import re
import math
from recommendations import df
NEIGHBORHOODS = {
    "المقابلين":        (31.9250, 35.8820),
    "الشميساني":         (31.9620, 35.9040),
    "عبدون":            (31.9480, 35.8730),
    "الدوار الاول":      (31.9540, 35.9160),
    "الدوار السابع":     (31.9610, 35.8800),
    "جبل عمان":          (31.9510, 35.9220),
    "جبل الحسين":        (31.9560, 35.9110),
    "الرابية":           (31.9650, 35.8650),
    "خلدا":              (31.9670, 35.8480),
    "تلاع العلي":        (31.9800, 35.8650),
    "الجبيهة":           (32.0150, 35.8720),
    "الجامعة الاردنية":  (32.0100, 35.8720),
    "وسط البلد":         (31.9520, 35.9350),
    "البلد":            (31.9520, 35.9350),
    "الصويفية":          (31.9530, 35.8680),
    "ماركا":            (31.9880, 35.9820),
    "طبربور":           (32.0050, 35.9450),
    "أبو نصير":          (32.0350, 35.8880),
    "دابوق":            (31.9950, 35.8150),
    "ناعور":            (31.8830, 35.8280),
    "مرج الحمام":        (31.9020, 35.8300),
    "صويلح":            (32.0200, 35.8580),
}

NEIGHBORHOOD_ALIASES_EN = {
    "abdoun": "عبدون",
    "shmeisani": "الشميساني",
    "shmeisany": "الشميساني",
    "muqabalain": "المقابلين",
    "al-muqabalain": "المقابلين",
    "first circle": "الدوار الاول",
    "seventh circle": "الدوار السابع",
    "jabal amman": "جبل عمان",
    "jabal al-hussein": "جبل الحسين",
    "jabal al hussein": "جبل الحسين",
    "rabieh": "الرابية",
    "khalda": "خلدا",
    "tlaa al-ali": "تلاع العلي",
    "tla al-ali": "تلاع العلي",
    "jubaiha": "الجبيهة",
    "university of jordan": "الجامعة الاردنية",
    "downtown": "وسط البلد",
    "sweifieh": "الصويفية",
    "marka": "ماركا",
    "tabarbour": "طبربور",
    "abu nsair": "أبو نصير",
    "dabouq": "دابوق",
    "naour": "ناعور",
    "marj al hamam": "مرج الحمام",
    "sweileh": "صويلح",
}


def normalize_ar(text):
    text = text.strip().lower()
    text = re.sub(r"[إأآا]", "ا", text)
    text = re.sub(r"ى", "ي", text)
    text = re.sub(r"ؤ", "و", text)
    text = re.sub(r"ئ", "ي", text)
    text = re.sub(r"ة", "ه", text)
    text = re.sub(r"[ًٌٍَُِّْـ]", "", text)
    return text


def strip_prefixes(word):

    for p in ("بال", "كال", "فال", "وال", "لل", "ال", "و", "ف", "ب", "ك", "ل"):
        if word.startswith(p) and len(word) - len(p) >= 3:
            return word[len(p):]
    return word


def core_text(text):

    return " ".join(strip_prefixes(w) for w in text.split())


_NEIGHBORHOOD_NORM = {core_text(normalize_ar(k)): (k, v) for k, v in NEIGHBORHOODS.items()}


def find_neighborhood(text):

    norm = core_text(normalize_ar(text))
    for norm_name, (official_name, coords) in _NEIGHBORHOOD_NORM.items():
        if norm_name in norm:
            return official_name, coords
    lower_text = text.lower()
    for alias, official_name in NEIGHBORHOOD_ALIASES_EN.items():
        if alias in lower_text:
            return official_name, NEIGHBORHOODS[official_name]
    return None, None


def haversine_km(lat1, lon1, lat2, lon2):

    R = 6371.0
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
    return 2 * R * math.asin(math.sqrt(a))


def _valid_coords(row):
    try:
        lat, lon = float(row["Latitude"]), float(row["Longitude"])
        return lat, lon
    except (TypeError, ValueError):
        return None


def find_nearby_places_by_coords(lat0, lon0, category=None, top_n=5, exclude_name=None):

    candidates = df
    if category:
        candidates = candidates[candidates["التصنيف_قائمة"].apply(lambda cats: category in cats)]

    results = []
    for _, row in candidates.iterrows():
        if exclude_name and row["الاسم بالعربي"] == exclude_name:
            continue
        c = _valid_coords(row)
        if c is None:
            continue
        dist = haversine_km(lat0, lon0, c[0], c[1])
        results.append({
            "name": row["الاسم بالعربي"],
            "distance_km": round(dist, 2),
            "rating": row.get("التقييم"),
        })

    results.sort(key=lambda r: r["distance_km"])
    return results[:top_n]


def find_nearby_places(neighborhood_query, category=None, top_n=5):

    official_name, coords = find_neighborhood(neighborhood_query)
    if coords is None:
        return None

    lat0, lon0 = coords
    results = find_nearby_places_by_coords(lat0, lon0, category=category, top_n=top_n)
    return {"neighborhood": official_name, "results": results}

def _row_by_place_name(place_name):
    matches = df[df["الاسم بالعربي"] == place_name]
    if matches.empty:
        return None
    return matches.iloc[0]


def _clean(val):

    if isinstance(val, float) and math.isnan(val):
        return None
    if hasattr(val, "item") and not isinstance(val, str):
        try:
            return val.item()
        except Exception:
            pass
    return val


def get_place_card(place_name):

    row = _row_by_place_name(place_name)
    if row is None:
        return None
    return {
        "name_ar": row["الاسم بالعربي"],
        "name_en": _clean(row.get("الاسم بالإنجليزي")),
        "category": _clean(row.get("التصنيف")),
        "rating": _clean(row.get("التقييم")),
        "rating_count": _clean(row.get("عدد التقييمات")),
        "price_level": _clean(row.get("مستوى السعر")),
        "address": _clean(row.get("العنوان")),
        "phone": _clean(row.get("رقم الهاتف")),
        "website": _clean(row.get("الموقع الإلكتروني")),
        "maps_link": _clean(row.get("رابط خرائط جوجل")),
    }


def get_place_summary(place_name):

    row = _row_by_place_name(place_name)
    if row is None:
        return None
    coords = _valid_coords(row)
    return {
        "place_id": _clean(row.get("Place ID")),
        "name_ar": row["الاسم بالعربي"],
        "name_en": _clean(row.get("الاسم بالإنجليزي")),
        "category": _clean(row.get("التصنيف")),
        "latitude": coords[0] if coords else None,
        "longitude": coords[1] if coords else None,
        "rating": _clean(row.get("التقييم")),
        "rating_count": _clean(row.get("عدد التقييمات")),
        "price_level": _clean(row.get("مستوى السعر")),
        "maps_link": _clean(row.get("رابط خرائط جوجل")),
    }


def get_rating_summary(place_name):

    card = get_place_card(place_name)
    if card is None or card["rating"] is None:
        return None
    rating = card["rating"]
    count = card["rating_count"]
    try:
        count_str = f"{int(count):,}".replace(",", ",")
    except (TypeError, ValueError):
        count_str = str(count)
    return {
        "place_name": card["name_ar"],
        "rating": rating,
        "rating_count": count_str,
    }



DAY_COLUMNS = {
    "الاحد": "الأحد", "الأحد": "الأحد",
    "الاثنين": "الاثنين",
    "الثلاثاء": "الثلاثاء", "الثلاثا": "الثلاثاء",
    "الاربعاء": "الأربعاء", "الأربعاء": "الأربعاء",
    "الخميس": "الخميس",
    "الجمعة": "الجمعة", "الجمعه": "الجمعة",
    "السبت": "السبت",
}

_DAY_NORM = {normalize_ar(k): v for k, v in DAY_COLUMNS.items()}


def find_day(text):
    norm = normalize_ar(text)
    for norm_day, col in _DAY_NORM.items():
        if norm_day in norm:
            return col
    return None


def get_hours(place_name, day_column):
    row = _row_by_place_name(place_name)
    if row is None or day_column not in row:
        return None

    return _clean(row[day_column])

PRICE_WORDS = {
    1: ["رخيص", "رخيصة", "اقتصادي", "بسعر بسيط", "مش غالي", "cheap", "budget", "affordable"],
    2: ["متوسط", "معقول", "moderate", "mid range", "mid-range"],
    3: ["غالي", "فخم", "راقي", "expensive", "luxury", "fancy", "upscale"],
}


def get_place_coords(place_name):
    row = _row_by_place_name(place_name)
    if row is None:
        return None
    return _valid_coords(row)


def find_price_level(text):
    norm = normalize_ar(text)
    for level, words in PRICE_WORDS.items():
        for w in words:
            if normalize_ar(w) in norm:
                return level
    return None


def filter_by_price(price_level, category=None, top_n=10):
    candidates = df[df["مستوى السعر"] == price_level]
    if category:
        candidates = candidates[candidates["التصنيف_قائمة"].apply(lambda cats: category in cats)]
    return candidates["الاسم بالعربي"].head(top_n).tolist()


def _day_is_open(row, day_column):
    val = row.get(day_column)
    return isinstance(val, str) and "مغلق" not in val


def combined_search(category=None, price_level=None, neighborhood=None, day=None, top_n=10):

    def apply_filters(cat, price):
        candidates = df
        if cat:
            candidates = candidates[candidates["التصنيف_قائمة"].apply(lambda cats: cat in cats)]
        if price:
            candidates = candidates[candidates["مستوى السعر"] == price]
        if day:
            candidates = candidates[candidates.apply(lambda r: _day_is_open(r, day), axis=1)]
        return candidates

    relaxed_price = False
    candidates = apply_filters(category, price_level)
    if candidates.empty and price_level:
        candidates = apply_filters(category, None)
        relaxed_price = True

    if neighborhood and not candidates.empty:
        official_name, coords = find_neighborhood(neighborhood)
        if coords:
            lat0, lon0 = coords
            candidates = candidates.copy()

            def _dist(row):
                c = _valid_coords(row)
                return haversine_km(lat0, lon0, c[0], c[1]) if c else float("inf")

            candidates["_dist"] = candidates.apply(_dist, axis=1)
            candidates = candidates.sort_values("_dist")

    return {
        "names": candidates["الاسم بالعربي"].head(top_n).tolist(),
        "relaxed_price": relaxed_price,
    }