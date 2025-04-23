import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TranslatorApp());
}

class TranslatorApp extends StatelessWidget {
  const TranslatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Çeviri Uygulaması',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
