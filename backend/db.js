// db.js

const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
// const app = express();
const port = 3000;
const router = express.Router();

// app.set('view engine', 'ejs');
// app.set('views', path.join(__dirname, 'views'));

// Database Connection
const dbPath = path.join(__dirname, '../lstm_django/merged.sqlite3');

const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error('Database Connection Failure:', err.message);
    } else {
        console.log('Connected to the database successfully!');
    }
});

// Database Query
router.get('/data/:date', (req, res) => {
    const query = `SELECT id, actual, prediction, difference, date FROM lstm_prediction WHERE date = ?`;

    const date = req.params.date;

    db.get(query, [date], (err, row) => {
        if (err) {
            return res.status(500).send('Database error: ' + err.message);
        }

        console.log(`DB Query Result on: http://localhost:${port}/data/${date}`);

        if (row) {
            res.render('data', { data: row });
        } else {
            res.status(404).send('Data NOT found');
        }
    });
});

const getAllData = (callback) => {
    const query = `SELECT date, actual, prediction, difference, ticker FROM test`;
    db.all(query, [], (err, rows) => {
        if (err) {
            return callback(err);
        }
        callback(null, rows);
    });
};

// app.listen(port, () => {
//     console.log(`Server running at http://localhost:${port}`);
// })

module.exports = { router, db, getAllData };

// db.close((err) => {
//     if (err) {
//         return console.error(err.message);
//     }
//     console.log('Close the database connection!');
// });