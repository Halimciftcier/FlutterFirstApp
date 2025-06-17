import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

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
  List<Map<String, String>> translationHistory =
      []; // Çeviri Geçmişini Tutan Liste

  final FlutterTts flutterTts = FlutterTts(); // TTS nesnesi
  String pronunciationHint = ''; // Alt yazı gibi görünmesi için değişken

  // Ses tanıma nesnesi
  late stt.SpeechToText speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    loadHistory();
    speech = stt.SpeechToText();
  }

  // Dil Kodunu Platforma uygun locale formatına çevirme

  String getLocaleCode(String langCode) {
    switch (langCode) {
      case 'tr':
        return 'tr-TR';
      case 'en':
        return 'en-US';
      case 'fr':
        return 'fr-FR';
      default:
        return 'en-US';
    }
  }

  void listen() async {
    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (val) => print('Durum: $val'),
        onError: (val) => print('Hata: $val'),
      );

      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (val) {
            setState(() {
              _textController.text = val.recognizedWords;
            });
          },
          localeId: getLocaleCode(_sourceLang), // doğru dil kodu
          listenMode: stt.ListenMode.dictation, // uzun cümle algılama
          partialResults: true,
          listenFor: const Duration(seconds: 30), // Max dinleme süresi
        );
      } else {
        print("Mikrofon erişimi reddedildi");
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }

  // SharedPreferences ile geçmişi yükleme
  void loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList('History') ?? [];
    setState(() {
      translationHistory =
          encoded.map((item) {
            final parts = item.split('|');
            return {'from': parts[0], 'to': parts[1], 'text': parts[2]};
          }).toList();
    });
  }

  // SharedPreferences ile geçmişi kaydetme
  void saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        translationHistory
            .map((item) => '${item['from']}|${item['to']}|${item['text']}')
            .toList();
    prefs.setStringList('History', encoded);
  }

  // Geçmişi Sileme

  void clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('History');

    setState(() {
      translationHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translator App')),

      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            // Metin giriş alanı
            TextField(
              controller:
                  _textController, // Kullanıcının girdiği metni alan kontrolcü
              decoration: const InputDecoration(
                labelText: 'Çevrilecek metni girin',
              ),
              maxLines: 4,
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.center,
              child: IconButton(
                onPressed: listen,
                icon: Icon(isListening ? Icons.mic : Icons.mic_none),
                tooltip: 'Mikrofon İle Ses Girişi',
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Kaynak dili seçmek için dropdown menü
                DropdownButton<String>(
                  value: _sourceLang,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('İngilizce')),
                    DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                    DropdownMenuItem(value: 'fr', child: Text('Fransızca')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sourceLang = value!;
                    });
                  },
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      final temp = _sourceLang;
                      _sourceLang = _targetLang;
                      _targetLang = temp;
                    });
                  },
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Dilleri Değiştir',
                ),

                // Hedef dili seçmek için dropdown menü
                DropdownButton<String>(
                  value: _targetLang,
                  items: const [
                    DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                    DropdownMenuItem(value: 'en', child: Text('İngilizce')),
                    DropdownMenuItem(value: 'fr', child: Text('Fransızca')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _targetLang = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () async {
                if (_textController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Lütfen çevirmek için bir metin girin."),
                    ),
                  );
                  return;
                }
                try {
                  var translation = await translator.translate(
                    _textController.text,
                    from: _sourceLang,
                    to: _targetLang,
                  );
                  setState(() {
                    _translatedText = translation.text;
                    pronunciationHint = translation.text;

                    translationHistory.insert(0, {
                      'original': _textController.text,
                      'from': _sourceLang,
                      'to': _targetLang,
                      'text': translation.text,
                    });
                  });
                  saveHistory();
                } catch (e) {
                  print("Çeviri hatası: $e"); // LOG'a yaz
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Çeviri sırasında hata oluştu: $e")),
                  );
                }
              },
              child: const Text('Çevir'),
            ),

            const SizedBox(height: 16), // Sonuç kısmı ile araya boşluk
            // Çevrilen metni göster
            Text(
              _translatedText, // Güncellenen metin burada gösterilir
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_translatedText.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await flutterTts.setLanguage(_targetLang);
                      await flutterTts.speak(_translatedText);
                    },
                    icon: const Icon(Icons.volume_up),
                    label: const Text("Sesli Oku"),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Çeviri Geçmişi",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: "Geçmişi Temizle",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text("Geçmişi Sil"),
                            content: const Text(
                              "Tüm çeviri geçmişi silinsin mi ? ",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("İptal"),
                              ),
                              TextButton(
                                onPressed: () {
                                  clearHistory();
                                  Navigator.pop(context);
                                },
                                child: const Text("Sil"),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ],
            ),

            // Geçimişi Listeleme
            Expanded(
              child: ListView.builder(
                itemCount: translationHistory.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = translationHistory[index];
                  return ListTile(
                    title: Text(
                      "${item['original'] ?? ''}", // orijinal metin
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Çeviri : ${item['text'] ?? ''}  "),
                        Text("Dil: ${item['from']} → ${item['to']}"),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
