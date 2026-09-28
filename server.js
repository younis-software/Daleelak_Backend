import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import db from './src/config/db.js'; // استدعاء جسر قاعدة البيانات بالدوكر
import placesRoutes from './src/routes/places.js'; // استدعاء روابط الأماكن الحقيقية

// تفعيل قراءة ملف الـ .env
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5020;

// الإعدادات البرمجية الأساسية
app.use(cors());
app.use(express.json());

// المسار الرئيسي لفحص عمل الخادم
app.get('/', (req, res) => {
    res.send('مرحباً بك في خادم منصة دليلك الحقيقي والمليء ببيانات الأردن!');
});

// 🚀 ربط مسارات الأماكن الحقيقية بالداتا بيس (بدل الكود الوهمي القديم)
app.use('/api/places', placesRoutes);

// تشغيل السيرفر
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
