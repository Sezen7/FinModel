import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/gemini_helper.dart';

abstract class RoboAdvisorDataSource {
  Future<String> askFinancialAdvisor({
    required String userMessage,
    required List<Map<String, String>> chatHistory,
    required double monthlyIncome,
    required double totalExpense,
    required double totalDebt,
    required int activeGoalsCount,
  });
}

class RoboAdvisorDataSourceImpl implements RoboAdvisorDataSource {
  @override
  Future<String> askFinancialAdvisor({
    required String userMessage,
    required List<Map<String, String>> chatHistory,
    required double monthlyIncome,
    required double totalExpense,
    required double totalDebt,
    required int activeGoalsCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? apiKey = prefs.getString('USER_GEMINI_API_KEY');

    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      apiKey = dotenv.env['GEMINI_API_KEY'];
    }

    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      throw Exception('Lütfen Ayarlar menüsünden veya .env dosyasından geçerli bir Gemini API anahtarı tanımlayın.');
    }

    final double netSavings = monthlyIncome - totalExpense;

    final systemInstruction = '''
Sen "FinModel AI" adında, son derece profesyonel, samimi, güvenilir ve bilgili bir Kişisel Finans Danışmanısın (Robo-Advisor).
Kullanıcının mevcut finansal profili şu şekildedir:
- Aylık Net Gelir: ₺${monthlyIncome.toStringAsFixed(2)}
- Bu Ayki Toplam Harcama: ₺${totalExpense.toStringAsFixed(2)}
- Kalan Net Tasarruf / Bakiye: ₺${netSavings.toStringAsFixed(2)}
- Toplam Mevcut Borç: ₺${totalDebt.toStringAsFixed(2)}
- Aktif Tasarruf Kumbarası Sayısı: $activeGoalsCount

GÖREVLERİN VE KURALLARIN:
1. Yanıtlarını verirken kullanıcının bu finansal durumunu göz önünde bulundur. Gerekirse bu rakamlardan bahsederek kişiselleştirilmiş, gerçekçi öneriler sun.
2. 50/30/20 bütçe kuralı, bileşik faiz, borç kartopu/çığ yöntemleri, acil durum fonu ve harcama kısıntısı gibi finansal okuryazarlık ilkelerine hakimsin.
3. Yatırım tavsiyesi verirken yasal gereklilik olarak "Bu bir yatırım tavsiyesi değildir (YTD)" uyarısını koru ve temel finansal prensipleri açıkla.
4. Yanıtlarını çok uzun ve sıkıcı tutma. Maddeler, emojiler ve net başlıklar kullanarak okunması kolay ve dinamik bir Türkçe ile yanıt ver.
5. Kullanıcı soru sorduğunda doğrudan, motive edici ve çözüm odaklı cevap ver.
''';

    final List<Content> contents = [];

    // Add previous history (last 8 messages for context)
    final recentHistory = chatHistory.length > 8
        ? chatHistory.sublist(chatHistory.length - 8)
        : chatHistory;

    for (var msg in recentHistory) {
      if (msg['role'] == 'user') {
        contents.add(Content.text(msg['text'] ?? ''));
      } else {
        contents.add(Content.model([TextPart(msg['text'] ?? '')]));
      }
    }

    // Add current user prompt with system instruction
    contents.add(Content.text('$systemInstruction\n\nKullanıcının Sorusu: $userMessage'));

    try {
      final response = await generateContentWithFallback(
        apiKey: apiKey,
        contents: contents,
      );

      if (response.text == null || response.text!.trim().isEmpty) {
        return "Üzgünüm, şu anda yanıt üretemedim. Lütfen sorunuzu tekrar iletin.";
      }

      return response.text!.trim();
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('ücretsiz kotası') || errStr.contains('geçersiz')) {
        rethrow;
      }
      throw Exception('Robo-Advisor bağlantı hatası: $e');
    }
  }
}
