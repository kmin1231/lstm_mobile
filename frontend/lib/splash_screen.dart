import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  final String title;
  const SplashScreen({Key? key, required this.title}) : super(key: key);
  static const String fontFamily = 'Signika Negative';
  // static const String fontFamily = 'Baloo Paaji 2';

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });

    const Color backgroundColor = Color(0xFF181A1F);
    const double ImageHeight = 280;
    const double sizedBoxH1 = 55;
    const double sizedBoxH2 = 15;
    const double sizedBoxH3 = 40;
    const double fontDefault = 40;
    const double fontSmall = 20;

    const String welcomeText = 'Welcome to';
    const String appNameText = 'PrediTock!';
    const String descriptionText
                  = 'Check out the stock price predictions\n'
                    'made by the LSTM model in this app';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        minimum: EdgeInsets.only(top: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'lib/assets/images/stock_chart.png',
              height: ImageHeight,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: sizedBoxH1),
            Text(
              welcomeText,
              style: GoogleFonts.getFont(
                fontFamily,
                color: Colors.white,
                fontSize: fontDefault,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: sizedBoxH2),
            Text(
              appNameText,
              style: GoogleFonts.getFont(
                fontFamily,
                color: Color(0xFF9bc9e9),
                fontSize: fontDefault,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: sizedBoxH3),
            Center(
              child: Text(
                descriptionText,
                style: GoogleFonts.getFont(
                  fontFamily,
                  color: Colors.white,
                  fontSize: fontSmall,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}