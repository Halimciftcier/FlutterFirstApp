import 'package:flutter/material.dart';
import 'package:translator_clean/screens/welcome_screen.dart';

// Uygulamanın başlangıç noktası
void main() {
  runApp(const TranslatorApp()); // TranslatorApp widget'ını çalıştır
}

// Ana uygulama widget'ı
class TranslatorApp extends StatelessWidget {
  const TranslatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Çeviri Uygulaması', // Uygulama başlığı
      debugShowCheckedModeBanner: false, // Sağ üstteki debug bandını gizle
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema rengi
      ),
      home: const WelcomeScreen(), // Ana ekran olarak HomeScreen kullan
    );
  }
}
