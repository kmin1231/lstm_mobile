import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const String appName = 'PrediTock';

// colors
const Color basicColor = Color(0xFF181A1F);
const Color mainColor = Color(0xFF9BC9E9);
const Color elementColor = Color(0xFF32343A);
const Color calendarBackgroundColor = Colors.white;
const Color calendarTextColor = Colors.white;
const Color resultTextColor = Colors.white;
const Color progressColor = Color(0xFFCFE2F3);
const Color tickerColor = Color(0xFF9BC9E9);
const Color buttonColor = Color(0xFF9BC9E9);
const Color dialogColor = Color(0xFFf6f8fb);
const Color menuButtonColor = Color(0xFFb7B7BA);
const Color infoTextColor = Color(0xFF203139);
const Color dateColor = Color(0xFF74B2D3);
const Color statInfoColor = Color(0xFF74B2D3);

// fonts
final String fontTitle = 'Lexend';
final String fontTicker = 'Lato';
final String fontItem = 'IBM Plex Sans KR';
final String fontSplash = 'Signika Negative';

class FontLoader {
  static late final TextStyle lexendFont;
  static late final TextStyle latoFont;
  static late final TextStyle ibmPlexSansKrFont;
  static late final TextStyle signikaFont;

  static Future<void> loadFonts() async {
    lexendFont = GoogleFonts.lexend();
    latoFont = GoogleFonts.lato();
    ibmPlexSansKrFont = GoogleFonts.ibmPlexSansKr();
    signikaFont = GoogleFonts.signikaNegative();
  }

  static TextStyle getTextFont(String fontName) {
    switch (fontName) {
      case 'Lexend':
        return lexendFont;
      case 'Lato':
        return latoFont;
      case 'IBM Plex Sans KR':
        return ibmPlexSansKrFont;
      case 'Signika Negative':
        return signikaFont;
      default:
        return lexendFont;
    }
  }

  static TextStyle getTextStyle({
    required String fontName,
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    final baseStyle = getTextFont(fontName);
    return baseStyle.copyWith(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }
}

final TextStyle appNameStyle = FontLoader.getTextStyle(
  fontName: fontTitle,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final TextStyle menuCtrlStyle = FontLoader.getTextStyle(
  fontName: fontItem,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

final TextStyle infoMenuStyle = FontLoader.getTextStyle(
  fontName: fontTicker,
  fontWeight: FontWeight.bold,
  fontSize: 16,
  color: infoTextColor
);

final TextStyle statItemStyle = FontLoader.getTextStyle(
  fontName: fontTicker,
  fontWeight: FontWeight.bold,
  fontSize: 19,
  color: infoTextColor
);

final TextStyle statNumStyle = FontLoader.getTextStyle(
  fontName: fontTicker,
  fontWeight: FontWeight.bold,
  fontSize: 18,
  color: statInfoColor,
);


// StatsWidget
// const String textAccuracy = 'Accuracy';
// const String textMargin= 'Error Margin';
// const String textLastActual= 'Last Actual';
// const String textAvgActual = 'Avg. Actual';
// const String textAvgPred = 'Avg. Prediction';
// const String textAvgDiff = 'Avg. Difference';

const String textAccuracy = '예측 정확도';
const String textMargin= '오차 범위';
const String textLastActual= '전일 실제 주가';
const String textAvgActual = '평균 실제 주가';
const String textAvgPred = '평균 예측 주가';
const String textAvgDiff = '평균 오차';


// stock info
const List<String> stockTickers = [
  '005930', // 삼성전자
  '000660', // SK하이닉스
  '373220', // LG에너지솔루션
  '207940', // 삼성바이오로직스
  '005380', // 현대차
  '005935', // 삼성전자우
  '068270', // 셀트리온
  '000270', // 기아
  '105560', // KB금융
  '005490', // POSCO홀딩스
];

const List<String> stockNames = [
  '삼성전자',
  'SK하이닉스',
  'LG에너지솔루션',
  '삼성바이오로직스',
  '현대차',
  '삼성전자우',
  '셀트리온',
  '기아',
  'KB금융',
  'POSCO홀딩스',
];