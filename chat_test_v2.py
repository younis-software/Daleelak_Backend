# -*- coding: utf-8 -*-
import csv
import time
from collections import defaultdict

from chatbot import ask_chatbot 
from test_bank_v3 import TEST_BANK_V3

ALL_INTENTS = [
    "search_by_text", "filter_by_category", "get_recommendations",
    "nearby_search", "place_info", "filter_by_price", "combined_search",
    "compound_query", None,
]

def run_tests():
    results = []
    print("=" * 70)
    print(f"بدء الاختبار: {len(TEST_BANK_V3)} سؤال ")
    print("=" * 70)

    total_start = time.time()

    for i, case in enumerate(TEST_BANK_V3, start=1):
        question = case["question"]
        expected = case["intent"]

        session_id = f"test-v3-{i}"

        start = time.time()
        try:
            reply, debug_info = ask_chatbot(question, session_id=session_id)
            elapsed = round(time.time() - start, 3)
            actual = debug_info.get("tool_used")
            error = ""
        except Exception as e:
            elapsed = round(time.time() - start, 3)
            actual = "ERROR"
            reply = ""
            error = f"{type(e).__name__}: {e}"

        is_correct = (actual == expected)
        status = "✅" if is_correct else "❌"
        print(f"[{i:3d}/{len(TEST_BANK_V3)}] {status} متوقع={str(expected):20s} فعلي={str(actual):20s} ({elapsed}s)")
        if error:
            print(f"      ⚠️ {error}")

        results.append({
            "رقم": i, "السؤال": question,
            "متوقع": expected, "فعلي": actual,
            "صحيح": is_correct, "الوقت": elapsed,
            "الرد": reply[:200] if reply else "", "خطأ": error,
        })
        time.sleep(0.3)

    total_elapsed = round(time.time() - total_start, 2)
    print_summary(results, total_elapsed)
    save_csv(results)
    return results


def compute_prf(results):
    tp = defaultdict(int) 
    fp = defaultdict(int) 
    fn = defaultdict(int) 

    for r in results:
        exp, act = r["متوقع"], r["فعلي"]
        if exp == act:
            tp[exp] += 1
        else:
            fp[act] += 1
            fn[exp] += 1

    rows = []
    for intent in ALL_INTENTS:
        support = sum(1 for r in results if r["متوقع"] == intent)
        if support == 0:
            continue
        precision = tp[intent] / (tp[intent] + fp[intent]) if (tp[intent] + fp[intent]) > 0 else 0.0
        recall = tp[intent] / (tp[intent] + fn[intent]) if (tp[intent] + fn[intent]) > 0 else 0.0
        f1 = (2 * precision * recall / (precision + recall)) if (precision + recall) > 0 else 0.0
        rows.append({
            "النوع": intent or "خارج النطاق",
            "العدد": support,
            "Precision": round(precision, 3),
            "Recall": round(recall, 3),
            "F1": round(f1, 3),
        })
    return rows


def print_summary(results, total_elapsed):
    n = len(results)
    correct = sum(1 for r in results if r["صحيح"])

    print("\n" + "=" * 70)
    print("التقرير النهائي")
    print("=" * 70)
    print(f"عدد الأسئلة: {n} | صحيح: {correct} | الدقة الإجمالية (Accuracy): {round(correct/n*100, 1)}%")
    print(f"الوقت الكلي: {total_elapsed}s | متوسط لكل سؤال: {round(total_elapsed/n, 2)}s")

    print("\n--- Precision / Recall / F1 لكل نوع أداة ---")
    prf_rows = compute_prf(results)
    print(f"{'النوع':25s}{'العدد':>8s}{'Precision':>12s}{'Recall':>10s}{'F1':>8s}")
    for row in prf_rows:
        print(f"{row['النوع']:25s}{row['العدد']:>8d}{row['Precision']:>12.3f}{row['Recall']:>10.3f}{row['F1']:>8.3f}")

    macro_f1 = round(sum(r["F1"] for r in prf_rows) / len(prf_rows), 3) if prf_rows else 0
    print(f"\nMacro-F1 (متوسط F1 لكل الأنواع بوزن متساوٍ): {macro_f1}")

    wrong = [r for r in results if not r["صحيح"]]
    if wrong:
        print(f"\n--- الأسئلة الغلط ({len(wrong)}) ---")
        for r in wrong:
            print(f"  #{r['رقم']} \"{r['السؤال']}\" -> متوقع: {r['متوقع']} | فعلي: {r['فعلي']}")


def save_csv(results):
    prf_rows = compute_prf(results)
    with open("test_results_v3.csv", "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=list(results[0].keys()))
        writer.writeheader()
        writer.writerows(results)
    with open("prf_metrics_v3.csv", "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=list(prf_rows[0].keys()))
        writer.writeheader()
        writer.writerows(prf_rows)
    print("\n📄 تم حفظ: test_results_v3.csv (تفاصيل كل سؤال)")
    print("📄 تم حفظ: prf_metrics_v3.csv (Precision/Recall/F1 لكل نوع — هاد لملحق التقرير)")


if __name__ == "__main__":
    run_tests()