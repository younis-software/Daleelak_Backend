import os
import re
import json
import time
import csv
import logging
from datetime import datetime
from dotenv import load_dotenv
from groq import Groq
from flask import Flask, request, jsonify

from recommendations import df, get_recommendations, filter_by_category, search_by_text
from smart_features import (
    find_neighborhood, find_nearby_places, find_nearby_places_by_coords,
    find_day, get_hours,
    find_price_level, filter_by_price, combined_search,
    get_place_card, get_rating_summary, get_place_coords, get_place_summary,
    core_text, strip_prefixes,
)

load_dotenv()
client = Groq(api_key=os.environ.get("GROQ_API_KEY"))
logging.basicConfig(
    filename="chatbot_errors.log",
    level=logging.WARNING,
    format="%(asctime)s [%(levelname)s] %(message)s",
    encoding="utf-8",
)
logger = logging.getLogger("chatbot")
ANALYTICS_LOG_PATH = "chatbot_analytics.csv"
_ANALYTICS_HEADER = ["timestamp", "session_id", "user_message", "tool_used", "response_time_s", "had_error"]


def _log_interaction(session_id, user_message, tool_used, response_time, had_error=False):
    try:
        file_exists = os.path.isfile(ANALYTICS_LOG_PATH)
        with open(ANALYTICS_LOG_PATH, "a", newline="", encoding="utf-8-sig") as f:
            writer = csv.writer(f)
            if not file_exists:
                writer.writerow(_ANALYTICS_HEADER)
            writer.writerow([
                datetime.now().isoformat(timespec="seconds"),
                session_id, user_message, tool_used or "", round(response_time, 3), had_error,
            ])
    except Exception as e:
        logger.warning(f"فشل تسجيل سطر بملف chatbot_analytics.csv: {e}")

app = Flask(__name__)
app.config['JSON_AS_ASCII'] = False

MODEL_NAME = "openai/gpt-oss-120b"

CATEGORY_SYNONYMS = {
    "مطاعم": ["مطعم", "مطاعم", "أكل", "اكل", "مطعمين", "restaurant", "restaurants", "food"],
    "كافيهات": ["كافيه", "كوفي", "كافيهات", "قهوة", "مقهى", "مقاهي", "cafe", "cafes", "coffee", "coffee shop"],
    "حدائق": ["حديقة", "حدائق", "متنزه", "متنزهات", "منتزه", "park", "parks", "garden", "gardens"],
    "مولات": ["مول", "مولات", "مركز تسوق", "مراكز تسوق", "مجمع تجاري", "mall", "malls", "shopping center", "shopping centre"],
    "متاحف": ["متحف", "متاحف", "museum", "museums"],
    "مساجد و اماكن دينية": ["مسجد", "جامع", "مساجد", "جوامع", "كنيسة", "كنائس", "ديني", "دينية", "mosque", "mosques", "church", "churches", "religious"],
    "اماكن أثرية": ["أثري", "اثري", "آثار", "اثار", "أثرية", "اثرية", "تاريخي", "تاريخية", "archaeological", "archeological", "ruins", "historical site", "historical"],
    "شوارع ومناطق سياحية": ["شارع", "شوارع", "منطقة سياحية", "مناطق سياحية", "سياحي", "سياحية", "street", "streets", "tourist area", "touristic"],
    "اسواق شعبية": ["سوق", "أسواق", "اسواق", "سوق شعبي", "بازار", "market", "markets", "souk", "souq"],
    "مسابح": ["مسبح", "مسابح", "حمام سباحة", "swimming pool", "pool", "pools"],
    "مزارع": ["مزرعة", "مزارع", "farm", "farms"],
    "ملاهي": ["ملاهي", "ملهى", "أراجيح", "اراجيح", "amusement park", "fun city", "amusement"],
    # ملاحظة: شلنا "لعب" من هون — كانت بتتطابق غلط مع أي فعل عادي فيه
    # هالجذر (زي "يلعبوا"، "نلعب") بدون أي علاقة فعلية بتصنيف الملاهي.
    "الأماكن المائية": ["أماكن مائية", "اماكن مائية", "ألعاب مائية", "العاب مائية", "water park", "water games"],
    "اماكن كرة قدم (رياضة)": ["ملعب", "ملاعب", "كرة قدم", "كوره", "كورة", "رياضة", "رياضية", "football", "soccer", "sports field"],
}

NEARBY_TRIGGERS = [
    "قريب", "قريبة", "قريبه", "أقرب", "اقرب", "حوالين", "جنب", "بالقرب من",
    "نزلة عند", "مشوار قريب", "near", "nearest", "close to", "nearby",
]

RATING_TRIGGERS = [
    "رأيك", "رايك", "تقييم", "تقييمه", "كم نجمة", "كم نجمه", "منيح هالمكان",
    "كويس هالمكان", "rating", "review", "stars",
]
INFO_TRIGGERS = [
    "احكيلي عن", "معلومات عن", "تفاصيل", "عنوان", "عنوانه", "رقمه",
    "رقم هاتف", "رقم هاتفه", "وين هو", "فين هو", "address of",
    "details about", "phone number",
]

LIST_TRIGGERS = [
    "كل ال", "جميع", "شو عندكم", "شو عندكن", "وش عندكم", "ايش عندكم",
    "عندكم", "عندكن", "وريني", "ورجيني", "ورينا", "ابغى اشوف", "بغيت اشوف",
    "بدي اشوف", "بدي اعرف كل", "الموجودة", "الموجودين", "list all",
    "show me all", "what do you have", "what places do you have",
]

SIMILARITY_TRIGGERS = [
    "شبيه", "شبيهة", "بتشبه", "يشبه", "متل", "متل ما", "زي", "عجبني",
    "عجبتني", "لو حبيت", "شو تقترح", "اقترح", "قترح", "رشحلي", "رشحيلي",
    "similar to", "recommend", "suggest",
]

GENERIC_NAME_WORDS = {
    "حديقة", "حدائق", "متنزه", "منتزه", "مطعم", "مطاعم", "كافيه", "كافيهات",
    "مقهى", "سوق", "أسواق", "اسواق", "مسجد", "جامع", "متحف", "متاحف",
    "مسبح", "مسابح", "مزرعة", "مول", "مولات", "ملعب", "ملاعب", "مدينة",
    "park", "garden", "restaurant", "cafe", "mosque", "museum", "mall",
    "market", "farm", "pool", "club",

    "الاحد", "الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الاربعاء",
    "الخميس", "الجمعة", "الجمعه", "السبت", "يوم",
    
    "اردني", "اردنية", "اردنيه", "الاردني", "الاردنية", "الاردنيه",
    "jordanian",
    
    "كره", "قدم", "الكره", "القدم", "رياضه", "الرياضه",
    
    "عمان", "amman", "جبل",
    
    "first", "best", "top", "new", "good", "great", "one", "spot",
    "place", "get", "near", "nice", "cool", "the", "and", "for", "with",
   
    "of", "is", "are", "in", "on", "at", "to", "a", "an",
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

_GENERIC_NAME_WORDS_NORM = {normalize_ar(w) for w in GENERIC_NAME_WORDS}


def tokens_of(text):
    return set(re.findall(r"[\w']+", normalize_ar(text)))

_PLACE_INDEX = []
for _, _row in df.iterrows():
    _names = []
    if isinstance(_row.get("الاسم بالعربي"), str):
        _names.append(_row["الاسم بالعربي"])
    if isinstance(_row.get("الاسم بالإنجليزي"), str):
        _names.append(_row["الاسم بالإنجليزي"])
    _PLACE_INDEX.append({
        "official_name": _row["الاسم بالعربي"],
        "token_sets": [tokens_of(n) for n in _names],
    })


def find_category_match(norm_query):
    norm_query_core = core_text(norm_query)
    for official_category, synonyms in CATEGORY_SYNONYMS.items():
        for syn in synonyms:
            syn_core = core_text(normalize_ar(syn))
            pattern = re.escape(syn_core) + r"(?!ه)"
            if re.search(pattern, norm_query_core):
                return official_category
    return None


def find_place_match(query_tokens):

    scores_by_name = {}  # name -> (best_score, best_coverage)
    for entry in _PLACE_INDEX:
        name = entry["official_name"]
        for name_tokens in entry["token_sets"]:
            meaningful_name_tokens = name_tokens - _GENERIC_NAME_WORDS_NORM
            if not meaningful_name_tokens:
                continue
            overlap = meaningful_name_tokens & query_tokens
            if not overlap:
                continue
            score = sum(len(t) for t in overlap)
            coverage = len(overlap) / len(meaningful_name_tokens)
            prev = scores_by_name.get(name)
            if prev is None or (score, coverage) > prev:
                scores_by_name[name] = (score, coverage)

    if not scores_by_name:
        return None
    best_score = max(s for s, c in scores_by_name.values())
    if best_score < 3: 
        return None

    candidates = [(name, c) for name, (s, c) in scores_by_name.items() if s == best_score]
    top_coverage = max(c for _, c in candidates)
    winners = [name for name, c in candidates if c == top_coverage]
    if len(winners) > 1:  
        return None
    return winners[0]


def rule_based_classify(user_message, last_place=None):
    norm_query = normalize_ar(user_message)
    query_tokens = tokens_of(user_message)

    has_list_trigger = any(normalize_ar(t) in norm_query for t in LIST_TRIGGERS)
    has_similarity_trigger = any(normalize_ar(t) in norm_query for t in SIMILARITY_TRIGGERS)
    has_nearby_trigger = any(normalize_ar(t) in norm_query for t in NEARBY_TRIGGERS)
    has_rating_trigger = any(normalize_ar(t) in norm_query for t in RATING_TRIGGERS)
    has_info_trigger = any(normalize_ar(t) in norm_query for t in INFO_TRIGGERS)

    place = find_place_match(query_tokens)
    category = find_category_match(norm_query)
    neighborhood_name, neighborhood_coords = find_neighborhood(user_message)
    day = find_day(user_message)
    price_level = find_price_level(user_message)

    place_meaningful = tokens_of(place or "") - _GENERIC_NAME_WORDS_NORM
    neighborhood_meaningful = tokens_of(neighborhood_name or "") - _GENERIC_NAME_WORDS_NORM
    place_is_just_the_neighborhood = bool(place) and bool(neighborhood_coords) and (
        normalize_ar(neighborhood_name or "") in normalize_ar(place or "")
        or (bool(place_meaningful) and place_meaningful <= neighborhood_meaningful)
    )
    combined_blocked_by_place = place and not place_is_just_the_neighborhood

    day_combo = bool(day) and (bool(category) or bool(price_level) or bool(neighborhood_coords))
    price_geo_combo = bool(price_level) and bool(neighborhood_coords)
    if (day_combo or price_geo_combo) and not (place and has_similarity_trigger) and not combined_blocked_by_place:
        return "combined_search", {
            "category": category, "price_level": price_level,
            "neighborhood": neighborhood_name, "day": day,
        }

    if neighborhood_coords and has_nearby_trigger and (not place or place_is_just_the_neighborhood):
        return "nearby_search", {"neighborhood": neighborhood_name, "category": category}

    resolved_place = place or last_place
    if resolved_place and (has_rating_trigger or has_info_trigger or day):
        return "place_info", {"place_name": resolved_place, "day": day}

    if place and has_similarity_trigger:
        return "get_recommendations", {"place_name": place}

    if category and has_list_trigger:
        if price_level:
            return "filter_by_price", {"price_level": price_level, "category": category}
        return "filter_by_category", {"category": category}

    if category and len(query_tokens - _GENERIC_NAME_WORDS_NORM) == 0:
        return "search_by_text", {"user_query": user_message}

    return None, None



FALLBACK_PROMPT_TEMPLATE = """أنت مصنّف نيّة لمساعد يساعد الناس يلاقوا أماكن بعمان (مطاعم/كافيهات/حدائق/متاحف...الخ).
رجّع JSON فقط بدون أي كلام إضافي أو Markdown، بالشكل التالي بالضبط:

{{"action": "search", "answer": null}}
أو
{{"action": "answer", "answer": "نص الرد هون"}}

استخدم "search" فقط إذا كان المستخدم بدو يلاقي/يبحث عن مكان بعمان (حتى لو ما ذكر كلمة صريحة
زي "مطعم" أو "حديقة"، المهم يكون قصده يدور على مكان يروحله).

استخدم "action": "answer" واملأ "answer" بالرد المناسب مباشرة، بنفس لغة سؤال المستخدم بالضبط، بهاي الحالات:
- سؤال عام مالوش علاقة بأماكن بعمان (طقس، نكتة، رياضيات، برمجة، معلومة عامة) -> جاوب عادي وبإيجاز.
- طلب رأي/تقييم شخصي عن مكان معين ("شو رأيك...؟", "هل هو منيح؟") -> اعتذر بلطف وقول إنك ما بتقيّم الأماكن، بس تقدر تساعده يلاقي أماكن مشابهة إذا حب.
- كلام غير مفهوم / عشوائي / فاضي -> اطلب منه بلطف يوضح قصده.

أمثلة:
السؤال: "بدي مطعم رخيص بالشميساني" -> {{"action": "search", "answer": null}}
السؤال: "كيف الطقس اليوم؟" -> {{"action": "answer", "answer": "ما بقدر أتابع الطقس، بس أقدر أساعدك تلاقي مكان حلو بعمان لو حبيت 🙂"}}
السؤال: "شو رأيك بمطعم ليفانت هل هو منيح؟" -> {{"action": "answer", "answer": "ما بقدر أقيّم الأماكن شخصياً، بس ممكن أرشحلك أماكن شبيهة فيه إذا حبيت."}}
السؤال: "asdkjaslkdj" -> {{"action": "answer", "answer": "ما فهمت قصدك بالضبط، ممكن توضحلي أكثر؟"}}

السؤال الحالي: "{question}"
"""


def llm_classify_or_answer(user_message):
    try:
        response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=[
                {"role": "user", "content": FALLBACK_PROMPT_TEMPLATE.format(question=user_message)}
            ],
            temperature=0,
            response_format={"type": "json_object"},
        )
        result = json.loads(response.choices[0].message.content)
        action = result.get("action", "search")
        answer = result.get("answer")
        if action == "answer" and answer:
            return "answer", answer
        return "search", None
    except Exception:
        return "search", None


def is_arabic(text):
    return bool(re.search(r"[\u0600-\u06FF]", text))


def format_list_reply(user_message, names, intro_ar, intro_en, empty_ar, empty_en):
    arabic = is_arabic(user_message)
    if not names:
        return empty_ar if arabic else empty_en
    bullet_list = "\n".join(f"• {n}" for n in names[:10])
    intro = intro_ar if arabic else intro_en
    return f"{intro}\n{bullet_list}"

def _places_payload(items):
    payload = []
    for item in items or []:
        name = item.get("name") if isinstance(item, dict) else item
        summary = get_place_summary(name)
        if summary is None:
            continue  
        if isinstance(item, dict) and item.get("distance_km") is not None:
            summary = {**summary, "distance_km": item["distance_km"]}
        payload.append(summary)
    return payload


available_functions = {
    "search_by_text": search_by_text,
    "filter_by_category": filter_by_category,
    "get_recommendations": get_recommendations,
}

SESSION_STATE = {}


def _get_last_place(session_id):
    return SESSION_STATE.get(session_id, {}).get("last_place")


def _remember_place(session_id, place_name):
    if place_name:
        SESSION_STATE.setdefault(session_id, {})["last_place"] = place_name


def format_place_card(card, day=None, day_hours=None, arabic=True):
    lines = []
    if arabic:
        lines.append(f"📍 {card['name_ar']}")
        if card.get("rating") is not None:
            lines.append(f"⭐ التقييم: {card['rating']} من 5 ({card.get('rating_count')} تقييم)")
        if card.get("address"):
            lines.append(f"🏠 العنوان: {card['address']}")
        if card.get("phone"):
            lines.append(f"📞 الهاتف: {card['phone']}")
        if card.get("website"):
            lines.append(f"🌐 الموقع: {card['website']}")
        if card.get("maps_link"):
            lines.append(f"🗺️ خرائط جوجل: {card['maps_link']}")
        if day:
            if day_hours is not None:
                lines.append(f"🕒 الدوام يوم {day}: {day_hours}")
            else:
                lines.append(f"🕒 ما عنا معلومة عن أوقات الدوام يوم {day} لهاد المكان.")
    else:
        name = card.get("name_en") or card["name_ar"]
        lines.append(f"📍 {name}")
        if card.get("rating") is not None:
            lines.append(f"⭐ Rating: {card['rating']}/5 ({card.get('rating_count')} reviews)")
        if card.get("address"):
            lines.append(f"🏠 Address: {card['address']}")
        if card.get("phone"):
            lines.append(f"📞 Phone: {card['phone']}")
        if card.get("website"):
            lines.append(f"🌐 Website: {card['website']}")
        if card.get("maps_link"):
            lines.append(f"🗺️ Google Maps: {card['maps_link']}")
        if day:
            if day_hours is not None:
                lines.append(f"🕒 Hours on {day}: {day_hours}")
            else:
                lines.append(f"🕒 No hours info available for {day} for this place.")
    return "\n".join(lines)


def _ask_chatbot_impl(user_message, session_id="default"):
    debug_info = {"tool_used": None, "tool_args": None, "tool_result": None, "places": []}
    arabic = is_arabic(user_message)
    last_place = _get_last_place(session_id)

    tool_name, tool_args = rule_based_classify(user_message, last_place=last_place)

    if tool_name is None:
        action, payload = llm_classify_or_answer(user_message)
        if action == "answer":
            return payload, debug_info
        tool_name, tool_args = "search_by_text", {"user_query": user_message}

    debug_info["tool_used"] = tool_name
    debug_info["tool_args"] = tool_args

    if tool_name == "nearby_search":
        result = find_nearby_places(tool_args["neighborhood"], category=tool_args.get("category"), top_n=5)
        debug_info["tool_result"] = result
        if not result or not result["results"]:
            return (
                f"ما لقيت أماكن قريبة من {tool_args['neighborhood']} بهاد التصنيف."
                if arabic else f"Couldn't find nearby places for {tool_args['neighborhood']}."
            ), debug_info
        if result["results"]:
            _remember_place(session_id, result["results"][0]["name"])
        debug_info["places"] = _places_payload(result["results"])
        lines = [f"أقرب أماكن لـ{result['neighborhood']}:" if arabic else f"Nearest places to {result['neighborhood']}:"]
        for r in result["results"]:
            lines.append(f"• {r['name']} — {r['distance_km']} كم" if arabic else f"• {r['name']} — {r['distance_km']} km")
        return "\n".join(lines), debug_info

    if tool_name == "place_info":
        card = get_place_card(tool_args["place_name"])
        debug_info["tool_result"] = card
        if card is None:
            return (
                f"ما لقيت مكان اسمه \"{tool_args['place_name']}\" بالقائمة."
                if arabic else f"Couldn't find \"{tool_args['place_name']}\" in the list."
            ), debug_info
        _remember_place(session_id, card["name_ar"])
        debug_info["places"] = _places_payload([card["name_ar"]])
        day_hours = get_hours(tool_args["place_name"], tool_args["day"]) if tool_args.get("day") else None
        return format_place_card(card, day=tool_args.get("day"), day_hours=day_hours, arabic=arabic), debug_info

    if tool_name == "filter_by_price":
        result = filter_by_price(tool_args["price_level"], category=tool_args.get("category"))
        debug_info["tool_result"] = result
        if result:
            _remember_place(session_id, result[0])
        debug_info["places"] = _places_payload(result)
        price_label = {1: "رخيص", 2: "متوسط السعر", 3: "غالي"}.get(tool_args["price_level"], "")
        return format_list_reply(
            user_message, result,
            f"هاي الأماكن ({tool_args.get('category', '')}) بمستوى سعر {price_label}:",
            f"Places in this price range:",
            "ما لقيت أماكن بهاد النطاق السعري بهاد التصنيف.", "Couldn't find places in that price range.",
        ), debug_info

    if tool_name == "combined_search":
        result = combined_search(
            category=tool_args.get("category"), price_level=tool_args.get("price_level"),
            neighborhood=tool_args.get("neighborhood"), day=tool_args.get("day"),
        )
        debug_info["tool_result"] = result
        names = result["names"]
        if names:
            _remember_place(session_id, names[0])
        debug_info["places"] = _places_payload(names)
        if not names:
            return (
                "ما لقيت أماكن مطابقة لكل الشروط يلي طلبتيها." if arabic
                else "Couldn't find places matching all the filters."
            ), debug_info

        parts_ar, parts_en = [], []
        if tool_args.get("category"):
            parts_ar.append(f"تصنيف {tool_args['category']}")
            parts_en.append(f"category {tool_args['category']}")
        if tool_args.get("price_level"):
            label = {1: "رخيص", 2: "متوسط", 3: "غالي"}.get(tool_args["price_level"], "")
            parts_ar.append(f"سعر {label}")
            parts_en.append("that price range")
        if tool_args.get("neighborhood"):
            parts_ar.append(f"قريب من {tool_args['neighborhood']}")
            parts_en.append(f"near {tool_args['neighborhood']}")
        if tool_args.get("day"):
            parts_ar.append(f"مفتوح يوم {tool_args['day']}")
            parts_en.append(f"open on {tool_args['day']}")

        intro_ar = "هاي الأماكن (" + "، ".join(parts_ar) + "):"
        intro_en = "Here are places (" + ", ".join(parts_en) + "):"
        note = ""
        if result.get("relaxed_price"):
            note = (
                "\n(ملاحظة: ما لقيت نتائج بالسعر المطلوب بالضبط، هاي أقرب أماكن متوفرة بنفس الشروط التانية)"
                if arabic else
                "\n(Note: no exact price match found, showing places matching the other filters instead)"
            )
        lines = [intro_ar if arabic else intro_en] + [f"• {n}" for n in names] 
        return "\n".join(lines) + note, debug_info

    function_result = available_functions[tool_name](**tool_args)
    debug_info["tool_result"] = function_result

    if tool_name == "get_recommendations":
        if function_result is None:
            reply = (
                f"ما لقيت مكان اسمه \"{tool_args['place_name']}\" بالقائمة."
                if arabic
                else f"Couldn't find a place called \"{tool_args['place_name']}\" in the list."
            )
        else:
            _remember_place(session_id, tool_args["place_name"])
            debug_info["places"] = _places_payload(function_result)
            reply = format_list_reply(
                user_message, function_result,
                f"أماكن شبيهة بـ {tool_args['place_name']}:",
                f"Places similar to {tool_args['place_name']}:",
                "ما لقيت أماكن شبيهة كفاية.", "Couldn't find similar places.",
            )
    elif tool_name == "filter_by_category":
        if function_result:
            _remember_place(session_id, function_result[0])
        debug_info["places"] = _places_payload(function_result)
        reply = format_list_reply(
            user_message, function_result,
            f"هاي الأماكن ضمن تصنيف {tool_args['category']}:",
            f"Here are the places under {tool_args['category']}:",
            "ما لقيت أماكن بهاد التصنيف.", "Couldn't find places in that category.",
        )
    else:  # search_by_text
        if function_result:
            _remember_place(session_id, function_result[0])
        debug_info["places"] = _places_payload(function_result)
        reply = format_list_reply(
            user_message, function_result,
            "لقيتلك هالأماكن اللي ممكن تعجبك:",
            "Here are some places you might like:",
            "ما لقيت نتائج مطابقة لطلبك.", "Couldn't find matching results.",
        )

    return reply, debug_info


COMPOUND_CONNECTORS = [
    "وبعدين قول", "وبعدين احكي", "وبعدين", "بعدين قول", "بعدين احكي",
    "وكمان قول", "وكمان احكي", "وكمان", "و كمان",
    "and then", "also tell me", "as well as",
]


def split_compound_query(user_message):

    for conn in COMPOUND_CONNECTORS:
        idx = user_message.find(conn)
        if idx > 3:
            part1 = user_message[:idx].strip(" ،,.؟?")
            part2 = user_message[idx + len(conn):].strip(" ،,.؟?")
            if len(part1) > 2 and len(part2) > 2:
                return part1, part2
    return None, None


def _extract_anchor_place(debug_info):

    tool_used = debug_info.get("tool_used")
    tool_args = debug_info.get("tool_args") or {}
    if tool_used in ("get_recommendations", "place_info") and tool_args.get("place_name"):
        return tool_args["place_name"]

    tr = debug_info.get("tool_result")
    if isinstance(tr, list) and tr:
        return tr[0]
    if isinstance(tr, dict):
        if tr.get("names"):
            return tr["names"][0]
        if tr.get("results"):
            return tr["results"][0].get("name")
        if tr.get("name_ar"):
            return tr["name_ar"]
    return None


def _handle_compound_query(part1, part2, session_id):
 
    arabic = is_arabic(part1 + " " + part2)
    reply1, debug1 = _ask_chatbot_impl(part1, session_id=session_id)

    norm2 = normalize_ar(part2)
    category2 = find_category_match(norm2)
    has_nearby2 = any(normalize_ar(t) in norm2 for t in NEARBY_TRIGGERS)
    _, neighborhood2_coords = find_neighborhood(part2)

    anchor_place = _extract_anchor_place(debug1)

    if category2 and has_nearby2 and not neighborhood2_coords and anchor_place:
        anchor_coords = get_place_coords(anchor_place)
        if anchor_coords:
            nearby = find_nearby_places_by_coords(
                anchor_coords[0], anchor_coords[1], category=category2,
                top_n=5, exclude_name=anchor_place,
            )
            if nearby:
                lines = [reply1, ""]
                lines.append(
                    f"وبالنسبة لأقرب أماكن ({category2}) من {anchor_place}:"
                    if arabic else f"And nearest ({category2}) to {anchor_place}:"
                )
                for r in nearby:
                    lines.append(f"• {r['name']} — {r['distance_km']} كم" if arabic else f"• {r['name']} — {r['distance_km']} km")
                debug = {
                    "tool_used": "compound_query",
                    "tool_args": {"part1": part1, "part2": part2, "relation": "nearby_to_anchor", "anchor": anchor_place},
                    "tool_result": nearby,
                    # البند 3: places للجزء الأول (لو في) + places للأماكن
                    # القريبة من المرساة (anchor) اللي حسبناها هون
                    "places": (debug1.get("places") or []) + _places_payload(nearby),
                }
                return "\n".join(lines), debug

    reply2, debug2 = _ask_chatbot_impl(part2, session_id=session_id)
    separator = "\n\nبالنسبة للجزء التاني من سؤالك:\n" if arabic else "\n\nAs for the second part of your question:\n"
    debug = {
        "tool_used": "compound_query",
        "tool_args": {"part1_tool": debug1.get("tool_used"), "part2_tool": debug2.get("tool_used")},
        "tool_result": None,
        "places": (debug1.get("places") or []) + (debug2.get("places") or []),
    }
    return reply1 + separator + reply2, debug


def ask_chatbot(user_message, session_id="default"):

    start_time = time.time()
    tool_used_for_log = None
    had_error = False
    try:
        if not user_message or not isinstance(user_message, str) or not user_message.strip():
            arabic_default = True  
            return ("ما وصلني سؤال، ممكن تكتبي شي؟" if arabic_default else "I didn't receive a question — could you type something?"), {
                "tool_used": None, "tool_args": None, "tool_result": None, "places": [],
            }

        reply, debug_info = None, None
        part1, part2 = split_compound_query(user_message)
        if part1 and part2:
            reply, debug_info = _handle_compound_query(part1, part2, session_id)
        else:
            reply, debug_info = _ask_chatbot_impl(user_message, session_id=session_id)
        tool_used_for_log = debug_info.get("tool_used")
        return reply, debug_info

    except Exception as e:
        had_error = True
        logger.error(f"خطأ غير متوقع أثناء معالجة السؤال \"{user_message}\": {e!r}", exc_info=True)
        arabic = is_arabic(user_message) if isinstance(user_message, str) else True
        fallback_reply = (
            "صار في مشكلة تقنية من عندي، ممكن تجربي تسألي بصيغة تانية أو بعد شوي؟"
            if arabic else
            "Something went wrong on my end — please try rephrasing your question or try again shortly."
        )
        return fallback_reply, {"tool_used": None, "tool_args": None, "tool_result": None, "places": [], "error": str(e)}

    finally:
        elapsed = time.time() - start_time
        _log_interaction(session_id, user_message, tool_used_for_log, elapsed, had_error)


@app.route("/chat", methods=["POST"])
def chat():
    try:
        data = request.get_json(silent=True) or {}
    except Exception as e:
        logger.error(f"فشل قراءة JSON من الطلب: {e!r}", exc_info=True)
        return jsonify({"error": "الطلب مش بصيغة JSON صحيحة"}), 400

    user_message = data.get("message")
    session_id = data.get("session_id", "default")

    if not user_message or not isinstance(user_message, str) or not user_message.strip():
        return jsonify({"error": "يجب إرسال معامل message كنص غير فاضي"}), 400

    try:
        reply, debug_info = ask_chatbot(user_message, session_id=session_id)

        return jsonify({
            "reply": reply,
            "places": debug_info.get("places", []),
            "debug": debug_info,
        })
    except Exception as e:

        logger.critical(f"خطأ غير متوقع بالكامل بالـ /chat endpoint: {e!r}", exc_info=True)
        return jsonify({"error": "صار في مشكلة تقنية، جربي بعد شوي", "reply": None}), 500


if __name__ == "__main__":
    app.run(debug=True, port=5001)