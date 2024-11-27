import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const String appName = 'PrediTock';

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

// colors
const Color backgroundColor = Color(0xFF181A1F);
const Color mainColor = Color(0xFF9BC9E9);
const Color elementColor = Color(0xFF32343a);
const Color progressColor = Color(0xFFCFE2F3);
const Color tickerColor = Color(0xFF9bc9e9);

// fonts
final String fontTitle = 'Lexend';
final String fontTicker = 'Lato';
final String fontItem = 'IBM Plex Sans KR';


class FontLoader {
  static late final TextStyle lexendFont;
  static late final TextStyle latoFont;
  static late final TextStyle ibmPlexSansKrFont;

  static Future<void> loadFonts() async {
    lexendFont = GoogleFonts.lexend();
    latoFont = GoogleFonts.lato();
    ibmPlexSansKrFont = GoogleFonts.ibmPlexSansKr();
  }

  static TextStyle getTextFont(String fontName) {
    switch (fontName) {
      case 'Lexend':
        return lexendFont;
      case 'Lato':
        return latoFont;
      case 'IBM Plex Sans KR':
        return ibmPlexSansKrFont;
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