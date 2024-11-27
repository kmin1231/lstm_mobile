import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // print(Directory.current.path);
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the 'root' of the application!
  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF181A1F);

    return MaterialApp(
      title: 'PrediTock',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(title: 'PrediTock'),
        '/home': (context) => HomeScreen(stockTicker: '005930'),
        '/detail': (context) => DetailScreen(stockName: '', stockTicker: ''),
      },
      theme: ThemeData(
        primaryColor: Color(0xFF9BC9E9),
        scaffoldBackgroundColor: backgroundColor,
      ),
    );
  }
}