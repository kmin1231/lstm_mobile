// app.js

const express = require('express');
const path = require('path');
const admin = require('firebase-admin');
const { router: dbRouter, getAllData, db } = require('./db');
const app = express();
const port = 3200;


// stock ticker to update
const ticker = '373220';

const tickers = ['005930', '000660', '373220', '207940', '005380',
                '005935', '068270', '000270', '105560', '005490'];


// Firebase Admin SDK
require('dotenv').config();

const serviceAccount = require('./lstm-f254d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const firestoreDb = admin.firestore();


// Express setting
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.json());


// SQLite router
app.use('/', dbRouter);

// Firestore Database Query
app.get('/firestore/data/:date', async (req, res) => {
    const date = req.params.date;

    try {
        const snapshot = await firestoreDb.collection('predictions')
            .where('date', '==', date).get();

        if (snapshot.empty) {
            console.log(`No matching documents for date: ${date}`);
            return res.status(404).send('No matching documents.');
        }

        let data = [];
        snapshot.forEach(doc => {
            data.push(doc.data());
        });

        console.log(`Firestore Query Result on: http://localhost:${port}/firestore/data/${date}`);
        res.render('data', { data: data[0] });
    } catch (error) {
        console.error('Error retrieving data from Firestore:', error);
        res.status(500).send('Firestore error: ' + error.message);
    }
});


const saveWithCheck = async (row, retries = 3) => {
    try {
        const docId = `${row.date}_${row.ticker}`;
        const docRef = firestoreDb.collection('predictions').doc(docId);

        const docSnapshot = await docRef.get();
        
        if (docSnapshot.exists) {
            console.log(`Document for date: ${row.date} & ticker: ${row.ticker} already exists.`);
            return;
        }

        await docRef.set(row);
        console.log(`Data saved for date '${row.date}' & ticker '${row.ticker}'`);

    } catch (error) {
        console.error(`Error saving row with date ${row.date} & ticker ${row.ticker}:`, error);
        console.error('Row data:', row);
        if (retries > 0) {
            console.log(`Retrying to save data for date ${row.date} & ticker ${row.ticker} -- retries left: ${retries}`);
            await sleep(2000);
            return saveWithCheck(row, retries - 1);
        } else {
            console.error(`Failed to save data for date ${row.date} & ticker ${row.ticker} after retries.`);
        }
    }
};


const getTickerData = async (ticker) => {
    return new Promise((resolve, reject) => {
        const query = `SELECT * FROM predictions WHERE ticker = ?`;
        db.all(query, [ticker], (err, rows) => {
            if (err) {
                console.error(`Error fetching data for ticker ${ticker}:`, err.message);
                return reject(err);
            }
            resolve(rows);
        });
    });
};


// update recent 90 days only
const getTickerDataRecent = async () => {
    return new Promise((resolve, reject) => {
        const today = new Date();
        const ninetyDaysAgo = new Date(today);
        ninetyDaysAgo.setDate(today.getDate() - 90);

        const query = `
            SELECT * 
            FROM predictions 
            WHERE date BETWEEN ? AND ? 
            ORDER BY date DESC`;
        db.all(
            query,
            [
                ninetyDaysAgo.toISOString().split('T')[0],
                today.toISOString().split('T')[0],
            ],
            (err, rows) => {
                if (err) {
                    console.error('Error fetching recent data:', err.message);
                    return reject(err);
                }
                resolve(rows);
            }
        );
    });
};


app.get('/sync/:ticker', async (req, res) => {
    const ticker = req.params.ticker;
    try {
        await syncDataToFirestore(ticker);
        res.status(200).send(`Data for ticker '${ticker}' synced successfully!`);
    } catch (error) {
        res.status(500).send(`Error syncing data for ticker '${ticker}': ${error.message}`);
    }
});


app.post('/sync-all-tickers', async (req, res) => {
    try {
        await syncAllTickersToFirestore();
        res.status(200).send('All tickers synced to Firestore successfully!');
    } catch (error) {
        console.error('Error syncing tickers:', error);
        res.status(500).send('Failed to sync all tickers: ' + error.message);
    }
});


const syncDataToFirestore = async (ticker) => {
    try {
        const rows = await getTickerData(ticker);

        if (!rows.length) {
            console.log(`No data found for ticker '${ticker}'.`);
            return;
        }

        const promises = rows.map((row) => saveWithCheck(row));
        await Promise.all(promises);

        console.log(`All data for ticker '${ticker}' synced to Firestore successfully!\n`);
    } catch (error) {
        console.error(`Error syncing data for ticker '${ticker}':`, error);
    }
};


const saveRecentFirestore = async () => {
    try {
        const rows = await getTickerDataRecent();

        if (rows.length === 0) {
            console.log('No recent data found.');
            return;
        }

        const promises = rows.map(async (row) => {
            await saveWithCheck(row);
        });

        await Promise.all(promises);
        console.log('Recent 90 days data saved successfully to Firestore!');
    } catch (error) {
        console.error('Error saving recent data to Firestore:', error);
        throw new Error('Error saving recent data to Firestore: ' + error.message);
    }
};


app.post('/save-recent-firestore', async (req, res) => {
    try {
        await saveRecentFirestore();
        res.status(200).send('Recent 90 days data saved to Firestore successfully!');
    } catch (error) {
        console.error('Error in endpoint /save-recent-firestore:', error);
        res
            .status(500)
            .send('Error saving recent 90 days data to Firestore: ' + error.message);
    }
});


const syncAllTickersToFirestore = async () => {
    await Promise.all(tickers.map((ticker) => syncDataToFirestore(ticker)));
};



const startServer = () => {
    app.listen(port, () => {
        console.log(`Server running at http://localhost:${port}`);
    
    // syncAllTickersToFirestore(ticker).catch(console.error);
    });
};

startServer();