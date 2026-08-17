import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      appBar: AppBar(
        title: const Text('Gizlilik ve Güvenlik Politikası', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kBgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FinModel Pro Gizlilik ve Güvenlik Beyanı',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Son Güncelleme: 17 Ağustos 2026',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
              ),
              const Divider(color: Colors.white12, height: 28),
              _buildSection(
                '1. Toplanan Veriler ve Kullanım Amacı',
                'FinModel Pro, kullanıcıların harcamalarını, bütçelerini ve tasarruf hedeflerini güvenle takip edebilmeleri amacıyla Firebase altyapısını kullanmaktadır. Girilen veriler yalnızca kullanıcının kendi hesabına özel olarak saklanır.',
              ),
              _buildSection(
                '2. Yapay Zeka (Google Gemini) Entegrasyonu',
                'Uygulama içerisindeki fiş tarama (OCR) ve Robo-Advisor finansal koçluk özellikleri için Google Gemini API kullanılmaktadır. Yüklenen fiş görüntüleri veya iletilen finansal soru metinleri yalnızca ilgili analizin üretilmesi için şifrelenmiş kanaldan işlenir ve üçüncü taraflarla reklam amaçlı paylaşılmaz.',
              ),
              _buildSection(
                '3. Kamera ve Depolama İzinleri',
                'Kamera ve Galeri erişim izinleri yalnızca kullanıcının fiş/fatura fotoğrafı yüklemek istemesi durumunda talep edilir. Kullanıcı izni olmadan hiçbir arka plan taraması yapılmaz.',
              ),
              _buildSection(
                '4. Hesap ve Veri Silme Hakkı (GDPR / KVKK)',
                'Kullanıcılar diledikleri zaman uygulamadaki kayıtlı tüm harcama, borç ve hedef verilerini silebilir veya hesaplarının tamamen kapatılmasını talep edebilirler.',
              ),
              _buildSection(
                '5. İletişim ve Destek',
                'Gizlilik politikamız ve veri güvenliğinizle ilgili tüm sorularınız için destek ekibimizle iletişime geçebilirsiniz.',
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'FinModel Pro © 2026 Tüm Hakları Saklıdır.',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: kTeal, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
