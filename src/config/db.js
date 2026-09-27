import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const db = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

db.getConnection()
    .then(connection => {
        console.log('🚀 تم الاتصال بنجاح بقاعدة بيانات دليلك عبر Docker!');
        connection.release();
    })
    .catch(error => {
        console.error('❌ خطأ في الاتصال بقاعدة البيانات:', error.message);
    });

export default db;
