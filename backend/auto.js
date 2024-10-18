// auto.js

const axios = require('axios');
const { exec } = require('child_process');

const runPythonScript = () => {
    const commands = [
        'python manage.py runserver',
        'python manage.py run_command'
    ];
    
    const options = {
        cwd: '../lstm_django',
        shell: true
    };

    exec(commands[0], options, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error executing command: ${error.message}`);
            return;
        }
        if (stderr) {
            console.error(`stderr: ${stderr}`);
            return;
        }
        console.log(`stdout: ${stdout}`);

        exec(commands[1], options, (error, stdout, stderr) => {
            if (error) {
                console.error(`Error executing command: ${error.message}`);
                return;
            }
            if (stderr) {
                console.error(`stderr: ${stderr}`);
                return;
            }
            console.log(`stdout: ${stdout}`);
        });
    });
};

const sendCurlRequest = async () => {
    try {
        await axios.post('http://localhost:3000/save-to-firestore');
        console.log('Sync request sent successfully');
    } catch (error) {
        console.error('Error sending request:', error);
    }
};

const startSendingRequests = () => {
    const now = new Date();
    const localTime = now.toLocaleString('sv-SE', { timeZone: 'Asia/Seoul' });
    sendCurlRequest();
    console.log(`requested curl to synchronize database at ${localTime}`);
    setInterval(sendCurlRequest, 60000); // every minute (60,000)
};

const startRunningPythonScript = () => {
    const now = new Date();
    const localTime = now.toLocaleString('sv-SE', { timeZone: 'Asia/Seoul' });
    runPythonScript();
    console.log(`requested to run Python script at ${localTime}`);
    setInterval(runPythonScript, 300000); // every 5 minutes (300,000)

    // setInterval(runPythonScript, 300000);
    // console.log('requested to run Python script');
}

startRunningPythonScript();
startSendingRequests();