import db from '../config/db.js'; // استدعاء الجسر الحقيقي للدوكر

// 1. دالة جلب كل الأماكن السياحية الحقيقية بالأردن
export const getPlaces = async (req, res) => {
  try {
    // سحب البيانات من الجدول الافتراضي المجمع والجاهز بالداتا بيس
    const [rows] = await db.query('SELECT * FROM v_active_places ORDER BY name_en');
    res.json(rows); // إرسال الأماكن الحقيقية للفرونت إيند فوراً
  } catch (error) {
    console.error('Error fetching places:', error);
    res.status(500).json({ message: 'حدث خطأ في الخادم أثناء جلب الأماكن' });
  }
};

// 2. دالة جلب تفاصيل مكان واحد محدد بالـ ID حقيقياً
export const getPlaceById = async (req, res) => {
  try {
    const placeId = parseInt(req.params.id);
    
    // استعلام حقيقي للبحث عن المكان بالـ ID تبعه
    const [rows] = await db.query('SELECT * FROM v_active_places WHERE place_id = ?', [placeId]);
    
    // فحص جملة الـ if الشرطية (إذا المكان مش موجود)
    if (rows.length === 0) {
      return res.status(404).json({ message: 'عذراً، هذا المكان غير موجود في قاعدة البيانات' });
    }
    
    res.json(rows[0]); // إرجاع بيانات هذا المكان المحدد فقط
  } catch (error) {
    console.error('Error fetching place by ID:', error);
    res.status(500).json({ message: 'حدث خطأ في الخادم أثناء جلب تفاصيل المكان' });
  }
};
