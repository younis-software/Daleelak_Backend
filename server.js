import express from 'express';
import cors from 'cors';

const app = express();
const PORT = 5020;

// السماح للواجهات (React) بالاتصال بالخادم
app.use(cors());
app.use(express.json());

// مسار رئيسي للتأكد من عمل الخادم
app.get('/', (req, res) => {
    res.send('مرحباً بك في خادم منصة دليلك!');
});

// مسار تجريبي (API) لإرسال بيانات وهمية لأماكن ترفيهية
app.get('/api/places', (req, res) => {
    const places = [
        { id: 1, name: 'مدينة الملاهي', description: 'ألعاب ترفيهية ومطاعم متنوعة', rating: 4.5 },
        { id: 2, name: 'السينما الكبرى', description: 'أحدث الأفلام بتقنية 3D', rating: 4.8 },
        { id: 3, name: 'المتحف الوطني', description: 'معرض للآثار والفنون التاريخية', rating: 4.7 }
    ];
    res.json(places);
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});