// db.js

const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const port = 3200;
const router = express.Router();


// Database Connection
const dbPath = path.join(__dirname, '../algorithm/lstm_predictions.sqlite3');

const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error('Database Connection Failure:', err.message);
    } else {
        console.log('Connected to the SQLite database!');
    }
});

// Database Query
router.get('/data/:date', (req, res) => {
    const query = `SELECT actual, prediction, difference, date FROM predictions WHERE date = ?`;

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


module.exports = { router, db, getAllData };