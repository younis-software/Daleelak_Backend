'''
يقترح اماكن مشابهه لمكان محدد ال -
( /recommend ) الخاصه فيه هي (Endpoint)

البحث عن اماكن ب استخدام نص حر ال -
( /search ) الخاصه فيه هي (Endpoint)

يعرض الاماكن حسب التصنيف ال -
( /filter ) الخاصه فيه هي (Endpoint)
'''

from flask import Flask, request, jsonify
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

app = Flask(__name__)
app.config['JSON_AS_ASCII'] = False


CSV_PATH = "amman_places_final_v2.csv"
REQUIRED_COLUMNS = ["الاسم بالعربي", "التصنيف", "Tags", "Description"]

try:
    df = pd.read_csv(CSV_PATH)
except FileNotFoundError:
    raise SystemExit(
        f"❌ ما لقيت ملف البيانات \"{CSV_PATH}\". تأكدي إنه بنفس مجلد المشروع "
        f"وإنه الاسم مطابق بالضبط (بما فيها حالة الأحرف)."
    )
except pd.errors.EmptyDataError:
    raise SystemExit(f"❌ ملف \"{CSV_PATH}\" فاضي أو تالف — افتحيه وتأكدي إنه فيه بيانات.")
except Exception as e:
    raise SystemExit(f"❌ صار خطأ غير متوقع وإحنا عم نحمّل \"{CSV_PATH}\": {e!r}")

missing_cols = [c for c in REQUIRED_COLUMNS if c not in df.columns]
if missing_cols:
    raise SystemExit(
        f"❌ ملف البيانات ناقصه هالأعمدة: {missing_cols}. "
        f"تأكدي إنه نفس ملف amman_places_final_v2.csv الأصلي ومو نسخة معدّلة بالغلط."
    )

df['Tags'] = df['Tags'].fillna('')
df['Description'] = df['Description'].fillna('')
df['التصنيف'] = df['التصنيف'].fillna('')

df['التصنيف_قائمة'] = df['التصنيف'].apply(lambda x: [cat.strip() for cat in x.split(',')])

df['combined_features'] = df['التصنيف'] + ' ' + df['Tags'] + ' ' + df['Description']

try:
    tfidf = TfidfVectorizer()
    tfidf_matrix = tfidf.fit_transform(df['combined_features'])
    similarity_matrix = cosine_similarity(tfidf_matrix)
except Exception as e:
    raise SystemExit(f"❌ صار خطأ وإحنا عم نجهّز محرك البحث (TF-IDF): {e!r}")


def get_recommendations(place_name, place_id=None, top_n=10):
    if not place_name or not isinstance(place_name, str):
        return None

    matches = df[df['الاسم بالعربي'] == place_name]

    if place_id:
        matches = matches[matches['Place ID'] == place_id]

    if matches.empty:
        return None  

    idx = matches.index[0]
    similarity_scores = list(enumerate(similarity_matrix[idx]))
    similarity_scores = sorted(similarity_scores, key=lambda x: x[1], reverse=True)
    similarity_scores = similarity_scores[1:top_n + 1]
    recommended_indices = [i[0] for i in similarity_scores]
    return df['الاسم بالعربي'].iloc[recommended_indices].tolist()


def filter_by_category(category):
    filtered = df[df['التصنيف_قائمة'].apply(lambda cats: category in cats)]
    return filtered['الاسم بالعربي'].tolist()


def search_by_text(user_query, top_n=5):
    user_vector = tfidf.transform([user_query])
    similarity_scores = cosine_similarity(user_vector, tfidf_matrix)
    similarity_scores = list(enumerate(similarity_scores[0]))
    similarity_scores = sorted(similarity_scores, key=lambda x: x[1], reverse=True)
    similarity_scores = similarity_scores[:top_n]
    recommended_indices = [i[0] for i in similarity_scores]
    return df['الاسم بالعربي'].iloc[recommended_indices].tolist()


@app.route('/recommend', methods=['GET'])
def recommend():
    place_name = request.args.get('place')
    place_id = request.args.get('place_id') 

    if not place_name:
        return jsonify({'error': 'يجب إرسال معامل place'}), 400

    result = get_recommendations(place_name, place_id=place_id)

    if result is None:
        return jsonify({'error': f'لم يتم العثور على مكان باسم: {place_name}'}), 404

    return jsonify({'recommendations': result})


@app.route('/filter', methods=['GET'])
def filter_category():
    category = request.args.get('category')

    if not category:
        return jsonify({'error': 'يجب إرسال معامل category'}), 400

    return jsonify({'places': filter_by_category(category)})


@app.route('/search', methods=['GET'])
def search():
    query = request.args.get('query')

    if not query:
        return jsonify({'error': 'يجب إرسال معامل query'}), 400

    return jsonify({'results': search_by_text(query)})


if __name__ == '__main__':
    app.run(debug=True)