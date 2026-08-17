import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/gemini_helper.dart';

abstract class GoalAiDataSource {
  Future<String> generateProgressReport({
    required String title,
    required double targetAmount,
    required double currentAmount,
    required DateTime deadlineDate,
    required DateTime createdAt,
  });
}

class GoalAiDataSourceImpl implements GoalAiDataSource {
  @override
  Future<String> generateProgressReport({
    required String title,
    required double targetAmount,
    required double currentAmount,
    required DateTime deadlineDate,
    required DateTime createdAt,
  }) async {
    // 1. SharedPreferences'tan kullanıcı API anahtarını kontrol et
    final prefs = await SharedPreferences.getInstance();
    String? apiKey = prefs.getString('USER_GEMINI_API_KEY');

    // 2. Yoksa .env dosyasından oku
    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      apiKey = dotenv.env['GEMINI_API_KEY'];
    }

    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return "Görünüşe göre API anahtarı ayarlanmamış. Hedefine ulaşmak için paranı düzenli biriktirmeye devam et!";
    }

    final now = DateTime.now();
    final totalDays = deadlineDate.difference(createdAt).inDays;
    final remainingDays = deadlineDate.difference(now).inDays;
    final progressPercentage = (currentAmount / targetAmount) * 100;
    
    final prompt = '''
Sen "Finance AI" adında bir kişisel finans koçusun.
Kullanıcının "$title" isimli bir kumbara hedefi var.
Hedeflenen Tutar: $targetAmount TL
Şu Ana Kadar Biriken: $currentAmount TL (%${progressPercentage.toStringAsFixed(1)})
Hedef Bitiş Tarihi: ${deadlineDate.toIso8601String()} (Kalan Gün: $remainingDays)
Toplam Verilen Süre: $totalDays gün.

Senden istenen: Kullanıcıya en fazla 2-3 cümlelik samimi ve motive edici bir değerlendirme sunman.
Matematiksel olarak gidişatını oranla. Eğer süre yarılanmış ama para çok gerideyse, hızlanması gerektiğini dostça hatırlat. Eğer iyi gidiyorsa tebrik et.
Mekanik veya robotik bir dil kullanma.
''';

    try {
      final response = await generateContentWithFallback(
        apiKey: apiKey,
        contents: [Content.text(prompt)],
      );
      return response.text ?? "Rapor oluşturulamadı.";
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('ücretsiz kotası') || errStr.contains('geçersiz')) {
        return "AI rapor oluşturulamadı: ${errStr.replaceAll('Exception: ', '')}";
      }
      return "AI rapor oluşturulamadı: Lütfen internet bağlantınızı kontrol edin.";
    }
  }
}
