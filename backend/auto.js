// auto.js

const { exec } = require('child_process');
const cron = require('node-cron');
const axios = require('axios');


const startNodeServer = () => {
    return new Promise((resolve, reject) => {
        console.log("Starting Node server...");
        exec('node backend/app.js', { cwd: 'D:/dev/lstm_mobile' }, (err, stdout, stderr) => {
            if (err) {
                console.error(`Error starting server: ${err.message}`);
                return reject(err);
            }
            if (stderr) {
                console.error(`stderr: ${stderr}`);
                return reject(stderr);
            }

            console.log(`Server started successfully: ${stdout}`);
            resolve(stdout);
        });
    });
};


const gitPull = () => {
    return new Promise((resolve, reject) => {
        console.log("Running git pull...");
        exec('git pull origin main', { cwd: 'D:/dev/lstm_mobile' }, (err, stdout, stderr) => {
            if (err) {
                console.error(`Error pulling from git: ${err.message}`);
                return reject(err);
            }

            console.log(`Git pull completed: ${stdout}`);
            resolve(stdout);
        });
    });
};


const sendCurlRequest = async () => {
    try {
        const response = await axios.post('http://localhost:3200/sync-all-tickers');
        console.log('DB sync request sent successfully!', response.data);
    } catch (error) {
        console.error('Error sending request:', error.message);
        console.error('Error stack:', error.stack);
    }
};


const startSendingSyncRequest = async () => {
    try {
        // await startNodeServer();


        // schedule: * * * * * (minute - hour - date - month - weekday)
        // cron test: * * * * * => every minute

        cron.schedule('* * * * *', async () => {
            const timestamp = new Date().toLocaleString('en-US', { timeZone: 'Asia/Seoul' });
            console.log(`Sync request sent at: ${timestamp}`);

            await gitPull();            
            await sendCurlRequest();
        });
    } catch (error) {
        console.error('Error starting server or sending sync request:', error);
    }
};

startSendingSyncRequest();