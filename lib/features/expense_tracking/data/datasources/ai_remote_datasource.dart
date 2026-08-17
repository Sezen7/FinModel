import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/gemini_helper.dart';
import '../models/expense_model.dart';

abstract class AiRemoteDataSource {
  Future<ExpenseModel> extractAndCategorizeExpenseFromImage(Uint8List imageBytes, String mimeType);
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  AiRemoteDataSourceImpl();

  @override
  Future<ExpenseModel> extractAndCategorizeExpenseFromImage(Uint8List imageBytes, String mimeType) async {
    // 1. SharedPreferences'tan kullanıcı API anahtarını kontrol et
    final prefs = await SharedPreferences.getInstance();
    String? apiKey = prefs.getString('USER_GEMINI_API_KEY');

    // 2. Yoksa .env dosyasından oku
    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      apiKey = dotenv.env['GEMINI_API_KEY'];
    }

    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      throw Exception('Lütfen .env dosyasındaki GEMINI_API_KEY alanını kendi anahtarınızla güncelleyin veya profil sayfasından geçerli bir API anahtarı ekleyin.');
    }

    final imagePart = DataPart(mimeType, imageBytes);
    
    final prompt = '''
Aşağıdaki fiş/fatura görselini incele ve üzerindeki yazıları okuyarak metin çıkar.
Çıkardığın metne göre harcamayı analiz et ve SADECE geçerli bir JSON objesi dön.

Kurallar:
1. "title" alanı harcamanın yapıldığı mağaza veya firma adı olsun. Fişte büyük harflerle yazılan bir kurumsal isim varsa onu kullan.
2. "amount" alanı KDV dahil toplam harcama tutarı olsun (noktalı double değer). Bulamazsan 0.0 dön.
3. "category" alanı bu harcamanın türü olsun. Şunlardan birini seç: "Market", "Yeme-İçme", "Ulaşım", "Alışveriş", "Eğlence", "Eğitim", "Fatura", "Diğer". Metne/Ürünlere en uygun olanı seç.

Örnek Dönüş Formatı:
{
  "title": "Migros",
  "amount": 150.75,
  "category": "Market"
}
''';

    final content = [
      Content.multi([TextPart(prompt), imagePart])
    ];

    try {
      final response = await generateContentWithFallback(
        apiKey: apiKey,
        contents: content,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Yapay zeka yanıt veremedi.');
      }

      // Gemini bazen yanıtında ekstra metinler veya markdown formatı döndürebilir.
      // En güvenli yöntem: Yanıt içindeki ilk '{' ile son '}' işaretleri arasını almaktır.
      String rawText = response.text!.trim();
      final int startIndex = rawText.indexOf('{');
      final int endIndex = rawText.lastIndexOf('}');
      
      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        rawText = rawText.substring(startIndex, endIndex + 1);
      } else {
        throw Exception('Geçerli bir JSON verisi bulunamadı.');
      }

      final jsonMap = json.decode(rawText);
      
      return ExpenseModel(
        id: '', // Will be assigned by BLoC or DB
        userId: '', 
        title: jsonMap['title']?.toString() ?? 'Bilinmeyen Firma',
        amount: (jsonMap['amount'] as num?)?.toDouble() ?? 0.0,
        category: jsonMap['category']?.toString() ?? 'Diğer',
        date: DateTime.now(),
      );
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('ücretsiz kotası') || errStr.contains('geçersiz')) {
        rethrow;
      }
      throw Exception('Yapay zeka veriyi JSON formatına çeviremedi veya yanıt hatası aldı: $e');
    }
  }
}
