// app.js
const express = require('express');
const path = require('path');
const admin = require('firebase-admin');
const { router: dbRouter, getAllData } = require('./db');
// const dbRouter = require('./db');
// const sqlitte3 = require('sqlite3').verbose();
const app = express();
const port = 3000;

// Firebase Admin SDK
require('dotenv').config();

const serviceAccount = require('./lstm-f254d.json');
// const serviceAccount = {
//     type: process.env.FIREBASE_TYPE,
//     project_id: process.env.FIREBASE_PROJECT_ID,
//     private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
//     private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
//     client_email: process.env.FIREBASE_CLIENT_EMAIL,
//     client_id: process.env.FIREBASE_CLIENT_ID,
//     auth_uri: process.env.FIREBASE_AUTH_URI,
//     token_uri: process.env.FIREBASE_TOKEN_URI,
//     auth_provider_x509_cert_url: process.env.FIREBASE_AUTH_PROVIDER_X509_CERT_URL,
//     client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL,
//   };

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
            const docId = row.date; // identifier field: 'date'

            const { id, ...dataWithoutId } = row; // excludes 'id'
            
            await firestoreDb.collection('lstm_prediction').doc(docId).set(dataWithoutId);
        });

        await Promise.all(promises);
        res.status(200).send('Data saved to Firestore successfully!'); // HTTP200: OK
    } catch (error) {
        console.error('Error saving to Firestore:', error);
        res.status(500).send('Error saving to Firestore: ' + error.message); // HTTP500: Internal Server Error
    }
});

async function integerValues() {
    const collectionRef = firestoreDb.collection('lstm_prediction'); // collection name
    const snapshot = await collectionRef.get(); // object 'snapshot'

    snapshot.forEach(async (doc) => {
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
    });
}

integerValues().catch(console.error);

  app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
  });