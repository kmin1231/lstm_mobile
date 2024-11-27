import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'splash_screen.dart';
import 'home_screen.dart';
import 'constants.dart';

void main() async {
  // checks whether Flutter app is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // initializes Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  // loads fonts
  await FontLoader.loadFonts();
  
  // runs flutter application!
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the 'root' of the application!
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'PrediTock',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(title: 'PrediTock'),
        '/home': (context) => HomeScreen(stockTicker: ''),
        '/detail': (context) => DetailScreen(stockName: '', stockTicker: ''),
      },

      theme: ThemeData(
        primaryColor: mainColor,
        scaffoldBackgroundColor: backgroundColor,
      ),
    );
  }
}