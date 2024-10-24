// app.js
const express = require('express');
const path = require('path');
const admin = require('firebase-admin');
const { router: dbRouter, getAllData } = require('./db');
const cron = require('node-cron');
// const dbRouter = require('./db');
// const sqlitte3 = require('sqlite3').verbose();
const app = express();
const port = 3000;

// Firebase Admin SDK
require('dotenv').config();

const serviceAccount = require('./lstm-f254d.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const firestoreDb = admin.firestore();

// SQLite Database Connection
// const sqliteDb = new sqlite3.Database('./db_240924.sqlite3', (err) => {
//     if (err) {
//         console.error('Database Connection Failure:', err.message);
//     } else {
//         console.log('Connected to the database successfully!');
//     }
// });

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
        const snapshot = await firestoreDb.collection('005930_prediction')
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

// API EndPoint
// Data Save from SQLite DB to Firestore
// const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms)); // 'sleep' for retry

const saveWithCheck = async (row, retries = 3) => {
    try {
        const docId = row.date; // identifier field: 'date'
        const docRef = firestoreDb.collection('005930_prediction').doc(docId);

        const docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
            console.log(`Document for ${docId} already exists.`);
            return;
        }

        const { id, ...dataWithoutId } = row;
        await docRef.set(dataWithoutId);
        console.log(`Data saved for date: ${row.date}`);

    } catch (error) {
        console.error(`Error saving row with date ${row.date}:`, error);
        console.error('Row data:', row);
        if (retries > 0) {
            console.log(`Retrying to save data for date ${row.date}. Retries left: ${retries}`);
            await sleep(2000);
            return saveWithCheck(row, retries - 1);
        } else {
            console.error(`Failed to save data for date ${row.date} after retries.`);
        }
    }
};

app.post('/save-to-firestore', async (req, res) => {
    try {
        const rows = await new Promise((resolve, reject) => {
            getAllData((err, rows) => {
                if (err) {
                    return reject(err);
                }
                resolve(rows);
            });
        });

        const promises = rows.map(async (row) => {
            await saveWithCheck(row);
        });

        await Promise.all(promises);
        console.log('Data saved successfully to Firestore!');

        // await integerValues();

        res.status(200).send('Data saved to Firestore successfully!'); // HTTP200: OK
    } catch (error) {
        console.error('Error saving to Firestore:', error);
        res.status(500).send('Error saving to Firestore: ' + error.message); // HTTP500: Internal Server Error
    }
});

app.post('/save-specific/:date', async (req, res) => {
    const { date } = req.params;
    console.log('Received date from URL:', date);

    try {
        const rows = await new Promise((resolve, reject) => {
            getAllData((err, rows) => {
                if (err) {
                    return reject(err);
                }
                resolve(rows);
            });
        });

        const filteredRows = rows.filter(row => row.date === date);

        const promises = filteredRows.map(async (row) => {
            // await saveWithCheck(row);
            const docId = row.date;
            const docRef = firestoreDb.collection('005930_prediction').doc(docId);

            await docRef.set(row);
        });

        await Promise.all(promises);
        console.log(`Data for date ${date} saved successfully to Firestore!`);
        await integerValues(date);

        res.status(200).send(`Data for date ${date} saved to Firestore successfully!`);
    } catch (error) {
        console.error('Error saving to Firestore:', error);
        res.status(500).send('Error saving to Firestore: ' + error.message);
    }
});

async function integerValues() {
    console.log('integerValues function called');

    const collectionRef = firestoreDb.collection('005930_prediction'); // collection name
    // let query = collectionRef;
    const snapshot = await collectionRef.get();

    // if (date) {
    //     query = collectionRef.where('date', '>=', date);
    // }

    // const snapshot = await query.get();
    //  collectionRef.get(); // object 'snapshot'

    if (snapshot.empty) {
        console.log('No documents found in the collection.');
        return;
    }

    console.log(`Found ${snapshot.size} documents to process.`);

    for (const doc of snapshot.docs) {
        const data = doc.data();

        const differenceValue = data.difference;
        const predictionValue = data.prediction;

        let newDifferenceValue;
        let newPredictionValue;

        if (typeof differenceValue === 'number') {
            newDifferenceValue = Math.round(differenceValue);
        } else {
            console.log(`Document ${doc.id} has an invalid value for 'difference': ${differenceValue}`);
            continue; // skip
        }

        if (typeof predictionValue === 'number') {
            newPredictionValue = Math.round(predictionValue);
        } else {
            console.log(`Document ${doc.id} has an invalid value for 'prediction': ${predictionValue}`);
            continue; // skip
        }

        // converts field values to 'integer'
        await collectionRef.doc(doc.id).update({
            difference: newDifferenceValue,
            prediction: newPredictionValue
        });

        console.log(`Updated document ${doc.id}: difference = ${newDifferenceValue}, prediction = ${newPredictionValue}`);
        
//         try {
//             await collectionRef.doc(doc.id).update({
//                 difference: newDifferenceValue,
//                 prediction: newPredictionValue
//             });
//             console.log(`Updated document ${doc.id}: difference = ${newDifferenceValue}, prediction = ${newPredictionValue}`);
//         } catch (error) {
//             console.error(`Failed to update document ${doc.id}:`, error);
        }
    }

async function integerSpecific(date) {
    console.log('integerSpecific function called for date:', date);

    const collectionRef = firestoreDb.collection('005930_prediction');
    const snapshot = await collectionRef.get();

    if (snapshot.empty) {
        console.log('No documents found in the collection.');
        return;
    }

    console.log(`Found ${snapshot.size} documents in the collection.`);

    const docRef = collectionRef.doc(date);
    const docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
        console.log(`No document found for date: ${date}`);
        return;
    }

    const data = docSnapshot.data();
    const differenceValue = data.difference;
    const predictionValue = data.prediction;

    let newDifferenceValue;
    let newPredictionValue;

    if (typeof differenceValue === 'number') {
        newDifferenceValue = Math.round(differenceValue);
    } else {
        console.log(`Document ${date} has an invalid value for 'difference': ${differenceValue}`);
        return; // skip
    }

    if (typeof predictionValue === 'number') {
        newPredictionValue = Math.round(predictionValue);
    } else {
        console.log(`Document ${date} has an invalid value for 'prediction': ${predictionValue}`);
        return; // skip
    }

    await docRef.update({
        difference: newDifferenceValue,
        prediction: newPredictionValue
    });

    console.log(`Updated document ${date}: difference = ${newDifferenceValue}, prediction = ${newPredictionValue}`);
}

app.post('/update-integer-values/:date', async (req, res) => {
    const { date } = req.params;

    if (!date) {
        return res.status(400).send('Date parameter is required.');
    }

    try {
        await integerSpecific(date);
        res.status(200).send(`Integer values updated successfully for data after ${date}`);
    } catch (error) {
        console.error('Error updating integer values:', error);
        res.status(500).send('Error updating integer values: ' + error.message);
    }
});

const saveRecentFirestore = async () => {
    const today = new Date();
    const aheadDate = new Date(today);
    aheadDate.setDate(today.getDate() - 30);

    try {
        const rows = await new Promise((resolve, reject) => {
            const query = `SELECT * FROM predictions WHERE date BETWEEN ? AND ? ORDER BY date DESC LIMIT 30`;
            db.all(query, [aheadDate.toISOString().split('T')[0], today.toISOString().split('T')[0]], (err, rows) => {
                if (err) {
                    return reject(err);
                }
                resolve(rows);
            });
        });

        const promises = rows.map(async (row) => {
            await saveWithCheck(row);
        });

        await Promise.all(promises);
        console.log('Recent 30 days data saved successfully to Firestore!');
    } catch (error) {
        console.error('Error saving recent data to Firestore:', error);
        throw new Error('Error saving recent data to Firestore: ' + error.message);
    }
};

app.post('/save-recent-firestore', async (req, res) => {
    try {
        await saveRecentFirestore();
        res.status(200).send('Recent 30 days data saved to Firestore successfully!');
    } catch (error) {
        res.status(500).send('Error saving recent 30 days data to Firestore: ' + error.message);
    }
});

const startServer = () => {
    app.listen(port, () => {
        console.log(`Server running at http://localhost:${port}`);
        // integerValues().catch(console.error);
    });
};

// integerValues().catch(console.error);
// module.exports = startServer;
startServer();