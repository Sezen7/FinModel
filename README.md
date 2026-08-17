# FinModel: Yapay Zeka Destekli Kişisel Finans Yönetimi Uygulaması

Bu dosya, projenin mevcut durumunu, kullanılan teknolojileri ve mimari yapısını içeren **Ara Rapor** niteliğinde hazırlanmıştır.

## 📌 Proje Özeti
FinModel, kullanıcıların finansal okuryazarlıklarını artırmayı, harcamalarını takip etmelerini ve tasarruf hedeflerine ulaşmalarını sağlayan, Google Gemini AI entegrasyonlu modern bir mobil uygulamadır.

## 🏗️ Mimari Yapı (Clean Architecture)
Proje, sürdürülebilirlik ve test edilebilirlik prensiplerine uygun olarak **Clean Architecture** (Temiz Mimari) yapısında kurgulanmıştır. Her bir özellik (feature) aşağıdaki üç temel katmandan oluşmaktadır:

1.  **Data (Veri Katmanı):** API çağrıları, veri modelleri (Models) ve veri kaynakları (Data Sources).
2.  **Domain (Alan Katmanı):** İş mantığı (Business Logic), varlıklar (Entities) ve UseCase'ler.
3.  **Presentation (Sunum Katmanı):** Kullanıcı arayüzü (UI) ve State Management (Bloc/Cubit).

## 🛠️ Kullanılan Teknolojiler
-   **Framework:** Flutter
-   **Backend:** Firebase (Auth, Cloud Firestore)
-   **State Management:** Flutter BLoC
-   **Yapay Zeka:** Google Gemini API (google\_generative\_ai)
-   **Bağımlılık Enjeksiyonu:** GetIt
-   **Veri Görselleştirme:** fl\_chart
-   **Yardımcı Kütüphaneler:** Image Picker (OCR için), Shared Preferences, Flutter Dotenv, Equatable.

## ✅ Mevcut Durum ve Tamamlanan Modüller

### 1. Kimlik Doğrulama (Auth)
-   Firebase Authentication entegrasyonu tamamlandı.
-   E-posta/Şifre ile kayıt olma ve giriş yapma özellikleri aktif.
-   Google Ile Giriş (Google Sign-In) altyapısı hazırlandı.

### 2. Harcama Takibi (Expense Tracking)
-   Kullanıcıların harcamalarını manuel olarak girebildiği ekranlar tamamlandı.
-   **AI Destekli OCR:** Gemini API kullanılarak fatura/fiş fotoğraflarından otomatik veri çıkarımı (tutar, tarih, kategori) özelliği prototip aşamasında entegre edildi.
-   Harcamaların listelenmesi ve Firebase ile senkronizasyonu sağlandı.

### 3. Tasarruf Hedefleri (Saving Goals)
-   Kullanıcıların belirli hedefler (örn: araba, tatil) oluşturması sağlandı.
-   Hedef ilerleme takibi ve görselleştirmeler yapıldı.
-   Biriktirme kumbarası (virtual piggy bank) mantığı eklendi.

### 4. Yapay Zeka Destekli Finans Koçu (Robo Advisor)
-   Gemini API aracılığıyla kullanıcının finansal durumuna göre kişiselleştirilmiş raporlar sunma yeteneği eklendi.
-   Tasarruf önerileri ve harcama analizleri için sohbet arayüzü kurgulandı.

### 5. Kullanıcı Arayüzü (UI/UX)
-   Modern, kullanıcı dostu ve karanlık mod uyumlu (Dark Mode) tasarım uygulandı.
-   Varlıkların görselleştirilmesi için grafikler (Charts) entegre edildi.

## 🚀 Gelecek Planları (Sonraki Aşamalar)
-   **Bütçe Yönetimi:** Aylık limitler ve uyarı sisteminin tamamlanması.
-   **Finansal Eğitim:** Kullanıcılara finansal okuryazarlık kazandıracak içerik modülünün eklenmesi.
-   **Borç Yönetimi:** Borç takibi ve geri ödeme planlama arayüzlerinin geliştirilmesi.
-   **Performans Optimizasyonu:** Uygulama genelinde hız ve veri tasarrufu iyileştirmeleri.

## 📋 Kurulum ve Çalıştırma
Projeyi yerel ortamınızda çalıştırmak için:
1.  `.env` dosyasını oluşturun ve `GEMINI_API_KEY` bilgisini ekleyin.
2.  `flutter pub get` komutunu çalıştırın.
3.  `flutter run` ile uygulamayı başlatın.

---
**Öğrenci:** [İsim Soyisim]
**Ders:** [Ders Adı / Bitirme Projesi]
**Tarih:** 7 Nisan 2026
