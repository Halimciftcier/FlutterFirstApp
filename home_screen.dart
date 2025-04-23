import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

// Ana ekran widget'ımız
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Kullanıcının girdiği metni almak için bir kontrolcü
  final TextEditingController _textController = TextEditingController();

  // Çevrilmiş metni tutan değişken
  String _translatedText = '';

  // Çeviri işlemini yapan çevirici nesnesi
  final translator = GoogleTranslator();

  // Başlangıçta varsayılan olarak seçili kaynak ve hedef diller
  String _sourceLang = 'en'; // İngilizce
  String _targetLang = 'tr'; // Türkçe

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Uygulama üst kısmı (başlık çubuğu)
      appBar: AppBar(
        title: const Text('Translator App'), // Başlık yazısı
      ),
      // Sayfanın ana içeriği
      body: Padding(
        padding: const EdgeInsets.all(14.0), // Sayfa kenar boşlukları
        child: Column(
          children: [
            // Metin giriş alanı
            TextField(
              controller: _textController, // Kullanıcının girdiği metni alacak
              decoration: const InputDecoration(
                labelText: 'Çevrilecek metni girin', // Etiket yazısı
                border: OutlineInputBorder(), // Kenarlıklı görünüm
              ),
              maxLines: 4, // 4 satırlık giriş alanı
            ),
            const SizedBox(height: 20), // Araya boşluk koyduk
            // Dil seçimi için satır (kaynak ve hedef diller)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Kaynak dili seçmek için dropdown menü
                DropdownButton<String>(
                  value: _sourceLang, // Seçili olan dil
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('İngilizce')),
                    DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                    DropdownMenuItem(value: 'fr', child: Text('Fransızca')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sourceLang = value!; // Seçilen dili güncelleme
                    });
                  },
                ),
                const Text("→"),
                // Hedef dili seçmek için dropdown menü
                DropdownButton<String>(
                  value: _targetLang, // Seçili hedef dil
                  items: const [
                    DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                    DropdownMenuItem(value: 'en', child: Text('İngilizce')),
                    DropdownMenuItem(value: 'fr', child: Text('Fransızca')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _targetLang = value!; // Seçilen hedef dili güncelle
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12), // Yine biraz boşluk
            // "Çevir" butonu
            ElevatedButton(
              onPressed: () async {
                if (_textController.text.trim().isEmpty) {
                  // Eğer metin boşsa uyarı ver
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Lütfen çevirmek için bir metin girin."),
                    ),
                  );
                  return;
                }

                var translation = await translator.translate(
                  _textController.text,
                  from: _sourceLang,
                  to: _targetLang,
                );
                setState(() {
                  _translatedText = translation.text;
                });
              },
              child: const Text('Çevir'),
            ),

            const SizedBox(height: 16), // Sonuç kısmı ile araya boşluk
            // Çevrilen metni göster
            Text(
              _translatedText, // Güncellenen metin burada gösterilir
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
