# -*- coding: utf-8 -*-
import chatbot as chatbot

cat_cases = [
    ("عندي فضول، عرضيلي كل المطعمين المسجلين عندكم", "مطاعم"),
    ("بدي قائمة بكل أماكن الأكل الموجودة", "مطاعم"),
    ("Show me all the restaurants you have", "مطاعم"),
    ("وريني جميع الكوفيات يلي عندكم", "كافيهات"),
    ("Show me all the coffee shops you have", "كافيهات"),
    ("بدي أشوف كل المتنزهات الموجودة بالنظام", "حدائق"),
    ("عندكم كل المتنزهات؟ وريني ياها", "حدائق"),
    ("عندكم كل مراكز التسوق؟ وريني ياها الموجودة", "مولات"),
    ("List all the shopping centers you have", "مولات"),
    ("شو كل المتاحف يلي مسجلة بالنظام؟", "متاحف"),
    ("Show me all the museums you have registered", "متاحف"),
    ("عندكم كل الجوامع؟ وريني ياها", "مساجد و اماكن دينية"),
    ("بدي أشوف كل الكنائس الموجودة عندكم", "مساجد و اماكن دينية"),
    ("وريني جميع الأماكن الدينية المتوفرة", "مساجد و اماكن دينية"),
    ("شو عندكم بازارات؟ ابغى اشوفها كلها", "اسواق شعبية"),
    ("Show me all the souqs you have", "اسواق شعبية"),
    ("بدي كل الألعاب المائية الموجودة عندكم", "الأماكن المائية"),
    ("عندكم كل الأماكن التاريخية؟ وريني ياها", "اماكن أثرية"),
    ("Show me all the archaeological sites you have", "اماكن أثرية"),
    ("وريني جميع ملاعب الكورة المسجلة", "اماكن كرة قدم (رياضة)"),
    ("عندكم كل الأماكن الرياضية؟ وريني ياها", "اماكن كرة قدم (رياضة)"),
    ("شو كل المزارع الموجودة بالقائمة عندكم بالضبط؟", "مزارع"),
    ("List all the farms you have", "مزارع"),
    ("Show me all the pools you have", "مسابح"),
    ("عندكم كل الملاهي؟ وريني ياها بالكامل", "ملاهي"),
    ("وريني جميع أماكن الأراجيح الموجودة", "ملاهي"),
    ("بدي قائمة بكل الشوارع السياحية المسجلة", "شوارع ومناطق سياحية"),
    ("عندكم كل المناطق السياحية؟ وريني ياها", "شوارع ومناطق سياحية"),
]

price_cases = [
    ("وريني كل الكافيهات الرخيصة عندكم", "مطاعم" if False else "كافيهات", 1),
    ("بدي أماكن أكل اقتصادية، شو عندكم؟", "مطاعم", 1),
    ("عندكم كل المساجد الرخيصة؟", "مساجد و اماكن دينية", 1),  # سعر 1 غالباً بمعظم المساجد
    ("بدي مطاعم بسعر معقول، وريني ياها", "مطاعم", 2),
    ("عندكم مولات بسعر متوسط؟ وريني ياها", "مولات", 2),
    ("شو كل الملاعب متوسطة السعر؟", "اماكن كرة قدم (رياضة)", 2),
    ("بدي مسابح فخمة، شو عندكم؟", "مسابح", 3),
    ("عندكم كل المزارع الغالية؟ وريني ياها", "مزارع", 3),
    ("وريني كل الملاهي الراقية عندكم", "ملاهي", 3),
]

nearby_cases = [
    ("وين أقرب مول للشميساني؟", "الشميساني", "مولات"),
    ("بدي كافيه قريب من عبدون", "عبدون", "كافيهات"),
    ("أقرب حديقة للدوار الأول", "الدوار الاول", "حدائق"),
    ("في مطعم قريب من الدوار السابع؟", "الدوار السابع", "مطاعم"),
    ("وين أقرب مسجد لجبل الحسين؟", "جبل الحسين", "مساجد و اماكن دينية"),
    ("بدي سوق شعبي قريب من الرابية", "الرابية", "اسواق شعبية"),
    ("أقرب متحف لتلاع العلي", "تلاع العلي", "متاحف"),
    ("في ملعب كرة قدم قريب من صويلح؟", "صويلح", "اماكن كرة قدم (رياضة)"),
    ("وين أقرب حديقة لوسط البلد؟", "وسط البلد", "حدائق"),
    ("بدي كافيه قريب من الصويفية", "الصويفية", "كافيهات"),
    ("أقرب سوق شعبي لماركا", "ماركا", "اسواق شعبية"),
    ("في مول قريب من طبربور؟", "طبربور", "مولات"),
    ("وين أقرب مطعم لأبو نصير؟", "أبو نصير", "مطاعم"),
    ("أقرب مزرعة لدابوق", "دابوق", "مزارع"),
    ("بدي مسبح قريب من ناعور", "ناعور", "مسابح"),
    ("أقرب حديقة لمرج الحمام", "مرج الحمام", "حدائق"),
    ("Nearest mall to Khalda", "خلدا", "مولات"),
    ("Nearest museum to Downtown", "وسط البلد", "متاحف"),
    ("Cafe near Sweifieh please", "الصويفية", "كافيهات"),
]

info_cases = [
    ("كم تقييم متحف السيارات الملكي؟", "متحف السيارات الملكي"),
    ("رقم هاتف مطعم ليفانت شو؟", "مطعم ليفانت"),
    ("عنوان سيتي مول وين بالضبط؟", "سيتي مول"),
    ("احكيلي عن مسجد الملك عبد الله", "مسجد الملك عبد الله"),
    ("هل سوق جارا مفتوح يوم السبت؟", "سوق جارا"),
    ("تفاصيل تاج مول شو ممكن تعرفيني عليها؟", "تاج مول"),
    ("Jordan Museum rating please?", "متحف الأردن"),
    ("مزرعة سكاي فارم مفتوحة يوم الجمعة؟", "مزرعة سكاي فارم"),
    ("تفاصيل عن رومي كافيه لو سمحتِ", "رومي كافيه"),
    ("كم تقييم العبدلي مول؟", "العبدلي مول"),
    ("Address of Royal Automobile Museum please", "متحف السيارات الملكي"),
    ("مسبح المدينة المغطى مفتوح يوم الاثنين؟", "مسبح المدينة المغطى"),
]

rec_cases = [
    ("رشحلي أماكن متل متحف السيارات الملكي", "متحف السيارات الملكي"),
    ("جربت مطعم ليفانت وعجبني كتير، في متله؟", "مطعم ليفانت"),
    ("لو حبيت تاج مول وين بعد ممكن أروح؟", "تاج مول"),
    ("عجبتني حدائق الحسين، شو تقترح كمان؟", "حدائق الحسين"),
    ("أماكن بتشبه سوق الوحدات الشعبي", "سوق الوحدات الشعبي"),
    ("Any places similar to Luna park?", "لونا بارك"),
    ("قترحلي كافيهات متل ذا أوك كافيه", "ذا أوك كافيه"),
    ("عجبني نادي عمان لكرة القدم، في متله؟", "نادي عمان لكرة القدم"),
]

combined_cases = [
    ("بدي مطعم مفتوح يوم الجمعة", None),  # day + category
    ("كافيه رخيص مفتوح يوم السبت", None),  # day + price
    ("بدي مكان قريب من الشميساني مفتوح يوم الاحد", None),  # day + neighborhood
    ("بدي مول فخم قريب من خلدا", None),  # price + neighborhood
    ("مطعم رخيص قريب من عبدون", None),  # price + neighborhood
    ("كافيه متوسط السعر قريب من تلاع العلي", None),
    ("مسجد مفتوح يوم الجمعة قريب من الرابية", None),
    ("مسبح غالي قريب من الجبيهة مفتوح يوم السبت", None),
    ("مطعم متوسط السعر مفتوح يوم الخميس", None),
    ("بدي حديقة مفتوحة يوم الاثنين قريبة من وسط البلد", None),
]

compound_cases = [
    "احكيلي عن متحف السيارات الملكي وبعدين احكيلي عن كافيهات قريبة منه",
    "شو رأيك بسوق جارا وبعدين قول لي مطاعم قريبة منه",
    "عجبني رومي كافيه وبعدين قول لي حدائق قريبة منه",
    "بدي أشوف كل المتاحف وكمان قول لي تقييم متحف الأردن",
    "أقرب مطعم لعبدون وبعدين احكيلي عن كافيهات قريبة منه",
    "عجبتني حدائق الملك عبدالله الثاني وكمان احكيلي عن مطاعم قريبة منها",
    "تاج مول تقييمه كم and then tell me about cafes near it",
    "عجبني سيتي مول وبعدين قول لي مطاعم قريبة منه",
]

tricky_cases = [
    ("عندكم    كل    المتاحف   ", "filter_by_category", "متاحف"), 
    ("عَنْدَكُمْ كُلّ الْمَطَاعِمِ", "filter_by_category", "مطاعم"),  
    ("مطعمممممم", None, None), 
]

known_bug_cases = [
    ("في ملعب كرة قدم قريب من الجامعة الأردنية؟", "nearby_search", {"neighborhood": "الجامعة الاردنية", "category": "مساجد و اماكن دينية"}),
    ("What's the rating of Jordan Museum?", "place_info", {"place_name": "مسجد الجامعة الأردنية"}),
]

print("=" * 70)
print("FILTER_BY_CATEGORY")
fails = 0
for q, exp_cat in cat_cases:
    tool, args = chatbot.rule_based_classify(q)
    ok = (tool == "filter_by_category" and args and args.get("category") == exp_cat)
    if not ok:
        fails += 1
        print(f"  ❌ {q!r} -> got {tool}, {args} (expected category={exp_cat})")
print(f"  {len(cat_cases)-fails}/{len(cat_cases)} passed")

print("\nFILTER_BY_PRICE")
fails = 0
for q, exp_cat, exp_price in price_cases:
    tool, args = chatbot.rule_based_classify(q)
    ok = (tool == "filter_by_price" and args.get("category") == exp_cat and args.get("price_level") == exp_price)
    if not ok:
        fails += 1
        print(f"  ❌ {q!r} -> got {tool}, {args} (expected cat={exp_cat}, price={exp_price})")
print(f"  {len(price_cases)-fails}/{len(price_cases)} passed")

print("\nNEARBY_SEARCH")
fails = 0
for q, exp_hood, exp_cat in nearby_cases:
    tool, args = chatbot.rule_based_classify(q)
    ok = (tool == "nearby_search" and args.get("neighborhood") == exp_hood and args.get("category") == exp_cat)
    if not ok:
        fails += 1
        print(f"  ❌ {q!r} -> got {tool}, {args} (expected hood={exp_hood}, cat={exp_cat})")
print(f"  {len(nearby_cases)-fails}/{len(nearby_cases)} passed")

print("\nPLACE_INFO")
fails = 0
for q, exp_place in info_cases:
    tool, args = chatbot.rule_based_classify(q)
    ok = (tool == "place_info" and args.get("place_name") == exp_place)
    if not ok:
        fails += 1
        print(f"  ❌ {q!r} -> got {tool}, {args} (expected place={exp_place})")
print(f"  {len(info_cases)-fails}/{len(info_cases)} passed")

print("\nGET_RECOMMENDATIONS")
fails = 0
for q, exp_place in rec_cases:
    tool, args = chatbot.rule_based_classify(q)
    ok = (tool == "get_recommendations" and args.get("place_name") == exp_place)
    if not ok:
        fails += 1
        print(f"  ❌ {q!r} -> got {tool}, {args} (expected place={exp_place})")
print(f"  {len(rec_cases)-fails}/{len(rec_cases)} passed")

print("\nCOMBINED_SEARCH")
fails = 0
for q, _ in combined_cases:
    tool, args = chatbot.rule_based_classify(q)
    ok = (tool == "combined_search")
    if not ok:
        fails += 1
        print(f"  ❌ {q!r} -> got {tool}, {args}")
print(f"  {len(combined_cases)-fails}/{len(combined_cases)} passed")

print("\nCOMPOUND_QUERY (via full ask_chatbot, offline)")
fails = 0
for i, q in enumerate(compound_cases):
    reply, dbg = chatbot.ask_chatbot(q, session_id=f"v3-comp-{i}")
    ok = (dbg.get("tool_used") == "compound_query")
    if not ok:
        fails += 1
        print(f"  ❌ {q!r} -> got {dbg.get('tool_used')}")
print(f"  {len(compound_cases)-fails}/{len(compound_cases)} passed")

print("\nTRICKY / ROBUSTNESS")
for q, exp_tool, exp_cat in tricky_cases:
    tool, args = chatbot.rule_based_classify(q)
    print(f"  {q!r} -> tool={tool}, args={args}")

print("\nKNOWN BUGS (confirming they reproduce exactly as documented)")
for q, exp_tool, exp_args in known_bug_cases:
    tool, args = chatbot.rule_based_classify(q)
    match = (tool == exp_tool) and all(args.get(k) == v for k, v in exp_args.items())
    print(f"  {'✅ reproduced' if match else '⚠️ did NOT reproduce as expected'}: {q!r} -> {tool}, {args}")