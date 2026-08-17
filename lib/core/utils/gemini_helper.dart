import 'package:google_generative_ai/google_generative_ai.dart';

/// Helper function to attempt generation using a list of Gemini models in sequence.
/// Translates common errors (like quota limitations or invalid keys) into user-friendly Turkish messages.
Future<GenerateContentResponse> generateContentWithFallback({
  required String apiKey,
  required Iterable<Content> contents,
  GenerationConfig? generationConfig,
}) async {
  final models = [
    'gemini-3.5-flash',
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-flash',
    'gemini-1.5-flash-latest',
    'gemini-1.5-pro',
  ];

  Object? lastError;

  for (final modelName in models) {
    try {
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        generationConfig: generationConfig,
      );
      final response = await model.generateContent(contents);
      return response;
    } catch (e) {
      lastError = e;
      final errStr = e.toString().toLowerCase();
      
      // If it's a quota or rate limit error, it is an account-level issue.
      // Retrying other models won't help, so we break and handle the quota error.
      if (errStr.contains('quota') || errStr.contains('rate-limit') || errStr.contains('exceeded')) {
        break;
      }
    }
  }

  final errStr = lastError.toString();
  
  if (errStr.contains('quota') || errStr.contains('limit: 0') || errStr.contains('limit:0') || errStr.contains('Quota exceeded')) {
    throw Exception(
      'API Anahtarınızın ücretsiz kotası Google tarafından 0 olarak sınırlandırılmış. '
      'Bu sorunu çözmek için Google AI Studio hesabınıza kart tanımlayarak "Pay-as-you-go" '
      '(Kullandıkça Öde) planına geçmelisiniz (yine de belirli sınırlara kadar ücretsizdir) '
      'ya da farklı bir Google hesabından yeni bir API anahtarı oluşturup uygulamaya girmelisiniz.'
    );
  } else if (errStr.contains('API key not valid') || errStr.contains('key is invalid') || errStr.contains('key not valid')) {
    throw Exception('Girdiğiniz Gemini API anahtarı geçersiz. Lütfen anahtarınızı kontrol ederek tekrar deneyin.');
  }

  throw Exception(lastError ?? 'Yapay zeka modeliyle bağlantı kurulamadı.');
}
