import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

class SplashScreen extends StatelessWidget {
  final String title;
  const SplashScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });

    const double imageHeight = 280;
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
              height: imageHeight,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: sizedBoxH1),
            Text(
              welcomeText,
              style: GoogleFonts.getFont(
                fontSplash,
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
                fontSplash,
                color: mainColor,
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
                  fontSplash,
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