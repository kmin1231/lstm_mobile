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
        const snapshot = await firestoreDb.collection('lstm_prediction')
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
        const docRef = firestoreDb.collection('lstm_prediction').doc(docId);

        const docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
            console.log(`Document for ${docId} already exists. Skipping save.`);
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
        res.status(200).send('Data saved to Firestore successfully!'); // HTTP200: OK
    } catch (error) {
        console.error('Error saving to Firestore:', error);
        res.status(500).send('Error saving to Firestore: ' + error.message); // HTTP500: Internal Server Error
    }
});

app.post('/save-specific', async (req, res) => {
    console.log('Received request body:', req.body);
    const { date } = req.body;

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
            await saveWithCheck(row);
        });

        await Promise.all(promises);
        console.log(`Data for date ${date} saved successfully to Firestore!`);
        res.status(200).send(`Data for date ${date} saved to Firestore successfully!`);
    } catch (error) {
        console.error('Error saving to Firestore:', error);
        res.status(500).send('Error saving to Firestore: ' + error.message);
    }
});


// app.post('/save-to-firestore', async (req, res) => {
//     try {
//         const rows = await new Promise((resolve, reject) => {
//             getAllData((err, rows) => {
//                 if (err) {
//                     return reject(err);
//                 }
//                 resolve(rows);
//             });
//         });

//         // console.log('SQLite Data:', rows);
//         // const recentRows = rows.slice(-5);
//         // console.log('Recent Data:', recentRows);

//         const promises = rows.map(async (row) => {
//             try {
//                 const docId = row.date; // identifier field: 'date'

//                 const { id, ...dataWithoutId } = row; // excludes 'id'
            
//                 await firestoreDb.collection('lstm_prediction').doc(docId).set(dataWithoutId);
//                 console.log(`Data synchronized for date: ${row.date}`);
//             } catch (error) {
//                 console.error(`Error saving row with date ${row.date}:`, error);
//             }
//     });

//         await Promise.all(promises);
//         console.log('Data saved successfully to Firestore!');
//         res.status(200).send('Data saved to Firestore successfully!'); // HTTP200: OK
//     } catch (error) {
//         console.error('Error saving to Firestore:', error);
//         res.status(500).send('Error saving to Firestore: ' + error.message); // HTTP500: Internal Server Error
//     }
// });


async function integerValues() {
    console.log('integerValues function called');
    const collectionRef = firestoreDb.collection('lstm_prediction'); // collection name
    const snapshot = await collectionRef.get(); // object 'snapshot'

    if (snapshot.empty) {
        console.log('No documents found in the collection.');
        return;
    }

    console.log(`Found ${snapshot.size} documents in the collection.`);


    // snapshot.forEach(async (doc) => {
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
            return; // skip
        }

        if (typeof predictionValue === 'number') {
            newPredictionValue = Math.round(predictionValue);
        } else {
            console.log(`Document ${doc.id} has an invalid value for 'prediction': ${predictionValue}`);
            return; // skip
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

app.post('/update-integer-values', async (req, res) => {
    try {
        await integerValues(); // integerValues 함수 호출
        res.status(200).send('Integer values updated successfully!'); // 성공 응답
    } catch (error) {
        console.error('Error updating integer values:', error);
        res.status(500).send('Error updating integer values: ' + error.message); // 오류 응답
    }
});

//   app.listen(port, () => {
//     console.log(`Server running at http://localhost:${port}`);
//   });

const startServer = () => {
    app.listen(port, () => {
        console.log(`Server running at http://localhost:${port}`);

        integerValues().catch(console.error);
    });
};

// integerValues().catch(console.error);
// module.exports = startServer;
startServer();