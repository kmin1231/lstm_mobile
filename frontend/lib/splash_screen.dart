import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final String title;

  const SplashScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });

    return Scaffold(
      backgroundColor: Color(0xFF181A1F),
      body: SafeArea(
        minimum: EdgeInsets.only(top: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'lib/assets/images/stock_chart.png',
              height: 280,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'PrediTock!',
                    style: TextStyle(
                      color: Color(0xFF9bc9e9),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: Text(
                'Check out the stock price predictions\n'
                    'made by the LSTM model in this app',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
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