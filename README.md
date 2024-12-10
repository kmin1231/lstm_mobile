# Stock Price Prediction with LSTM on Mobile

### '`PrediTock`' Overview

<img src="https://drive.google.com/uc?id=1IVpuFYLAcDl7j2M-eHcf6O1nVhfdSKTR" alt="splash" width=30%>

<b>`"PrediTock"` = `'PREDIction'` + `'sTOCK'`;</b>
- KOSPI 상위 10개 종목에 대해 LSTM 알고리즘에 의한 예측 결과를 제공하는 모바일 애플리케이션입니다.
- 최근 60일 간의 데이터를 바탕으로 예측 결과를 다양한 형태로 표시합니다.
- 종목별 최신 뉴스도 함께 확인할 수 있습니다.

<br>

## Project Architecture

<img src="https://drive.google.com/uc?id=1G5BloW7Rg83ZQPR8GLNRjrkROpvMBufu" alt="architecture" width=65%>

## Project Structure
```
lstm_mobile
.
├── alfred
│   ├── analysis_options.yaml
│   ├── bin
│   ├── CHANGELOG.md
│   ├── doc
│   │   └── api
│   ├── lib
│   │   ├── alfred.dart             # Alfred server main file
│   │   ├── kis.key
│   │   ├── news_service.dart
│   │   └── stock_info.dart
│   ├── pubspec.lock
│   ├── pubspec.yaml
│   ├── README.md
│   └── test
│       └── alfred_test.dart
├── algorithm
│   ├── Dockerfile
│   ├── Dockerfile.jenkins
│   ├── Jenkinsfile
│   ├── lstm_predictions.sqlite3    # local database file
│   ├── lstm.py                     # Python script
│   ├── requirements.txt            # runtime environment
│   └── stats.py                    # statistical analysis
├── backend
│   ├── app.js                      # Node.js server main file
│   ├── auto.js                     # automation script
│   ├── config.js
│   ├── db.js                       # database connection
│   ├── index.js
│   ├── lstm-f254d.json             # connection to Firestore DB
│   ├── node_modules/
│   ├── package.json
│   ├── package-lock.json
│   ├── token.dat
│   └── views
│       └── data.ejs                # template for database query result
├── frontend                        # Dart/Flutter
│   ├── analysis_options.yaml
│   ├── android/
│   ├── firebase.json               # connection to Firestore DB
│   ├── frontend.iml
│   ├── ios/
│   ├── lib
│   │   ├── assets
│   │   │   ├── fonts/
│   │   │   ├── images/
│   │   │   └── kis.key
│   │   ├── constants.dart
│   │   ├── firebase_options.dart
│   │   ├── home_screen.dart
│   │   ├── info_screen.dart
│   │   ├── main.dart               # Flutter app entry point
│   │   ├── news_crawler.dart
│   │   ├── overview_screen.dart
│   │   └── splash_screen.dart
│   ├── linux/
│   ├── macos/
│   ├── pubspec.lock
│   ├── pubspec.yaml
│   ├── README.md
│   ├── test
│   │   └── widget_test.dart
│   ├── web
│   │   ├── favicon.png
│   │   ├── icons
│   │   ├── index.html
│   │   └── manifest.json
│   └── windows/
├── kubernetes
│   ├── cronjob.yaml
│   ├── deployment.yaml
│   ├── docker-compose.yml
│   ├── Dockerfile.alfred
│   ├── Dockerfile.cron
│   ├── Dockerfile.flutter
│   ├── Dockerfile.flutterWeb
│   └── service.yaml
├── .gitattributes
├── .gitignore
├── LICENSE
├── lstm_django/
└── README.md
```