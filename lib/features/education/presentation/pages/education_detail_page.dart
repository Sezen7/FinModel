import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class EducationDetailPage extends StatefulWidget {
  final String topicKey; // "compound_interest", "budget_50_30_20", "emergency_fund", "basic_concepts", "tax_law"

  const EducationDetailPage({super.key, required this.topicKey});

  @override
  State<EducationDetailPage> createState() => _EducationDetailPageState();
}

class _EducationDetailPageState extends State<EducationDetailPage> {
  // Calculators State
  // 1. Compound Interest
  final _initialCtrl = TextEditingController(text: '1000');
  final _monthlyCtrl = TextEditingController(text: '100');
  final _rateCtrl = TextEditingController(text: '20');
  final _yearsCtrl = TextEditingController(text: '5');
  double _compoundResult = 0.0;

  // 2. 50/30/20 Rule
  final _incomeCtrl = TextEditingController(text: '25000');

  // 3. Emergency Fund
  final _expensesCtrl = TextEditingController(text: '12000');

  @override
  void initState() {
    super.initState();
    _calculateCompoundInterest();
  }

  @override
  void dispose() {
    _initialCtrl.dispose();
    _monthlyCtrl.dispose();
    _rateCtrl.dispose();
    _yearsCtrl.dispose();
    _incomeCtrl.dispose();
    _expensesCtrl.dispose();
    super.dispose();
  }

  void _calculateCompoundInterest() {
    final double p = double.tryParse(_initialCtrl.text) ?? 0.0;
    final double PMT = double.tryParse(_monthlyCtrl.text) ?? 0.0;
    final double r = (double.tryParse(_rateCtrl.text) ?? 0.0) / 100.0;
    final double t = double.tryParse(_yearsCtrl.text) ?? 0.0;

    if (t <= 0) return;

    // Monthly compounding compound interest formula:
    // Future Value of Initial: A = P * (1 + r/12)^(12*t)
    // Future Value of Annuity: B = PMT * (((1 + r/12)^(12*t) - 1) / (r/12))
    const double n = 12.0; // compounded monthly
    final double ratePerPeriod = r / n;
    final double totalPeriods = n * t;

    double futureValueInitial = p;
    double futureValueAnnuity = 0.0;

    if (ratePerPeriod > 0) {
      // Compound with rate
      double growthFactor = 1.0;
      for (int i = 0; i < totalPeriods; i++) {
        growthFactor *= (1.0 + ratePerPeriod);
      }
      futureValueInitial = p * growthFactor;
      futureValueAnnuity = PMT * ((growthFactor - 1.0) / ratePerPeriod);
    } else {
      // Simple sum if interest rate is 0
      futureValueInitial = p;
      futureValueAnnuity = PMT * totalPeriods;
    }

    setState(() {
      _compoundResult = futureValueInitial + futureValueAnnuity;
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = '';
    Widget content = const SizedBox();

    if (widget.topicKey == 'compound_interest') {
      title = 'Bileşik Faiz Nedir?';
      content = _buildCompoundInterestContent();
    } else if (widget.topicKey == 'budget_50_30_20') {
      title = '50/30/20 Bütçeleme Kuralı';
      content = _build503020Content();
    } else if (widget.topicKey == 'emergency_fund') {
      title = 'Acil Durum Fonu';
      content = _buildEmergencyFundContent();
    } else if (widget.topicKey == 'basic_concepts') {
      title = 'Temel Finansal Kavramlar';
      content = _buildBasicConceptsContent();
    } else if (widget.topicKey == 'tax_law') {
      title = 'Vergi & Hukuk';
      content = _buildTaxLawContent();
    }

    return Scaffold(
      backgroundColor: kBgDark,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: content,
      ),
    );
  }

  // ─── 1. Bileşik Faiz İçeriği ────────────────────────────────────────────────
  Widget _buildCompoundInterestContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCoverCard(
          icon: Icons.trending_up_rounded,
          color: kPurple,
          text: 'Bileşik faiz, Albert Einstein tarafından "Dünyanın 8. Harikası" olarak tanımlanmıştır. Paranızın sadece ilk yatırdığınız anaparadan değil, zamanla biriken faizlerden de faiz kazanmasını sağlar.',
        ),
        const SizedBox(height: 24),
        _buildHeaderSection('Nasıl Çalışır?', 'Örneğin, her yıl %10 getiri sağlayan bir fona 1.000 ₺ yatırırsanız, 1. yılın sonunda 100 ₺ kazanarak 1.100 ₺’ye ulaşırsınız. 2. yılda faiziniz sadece 1.000 ₺ üzerinden değil, 1.100 ₺ üzerinden hesaplanır ve 110 ₺ kazandırır. Zamanla bu büyüme çığ gibi büyüyen bir kartopuna dönüşür.'),
        const SizedBox(height: 32),
        const Text('🧮 Bileşik Faiz Simülatörü', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildGlassCard(
          child: Column(
            children: [
              _buildInputRow('Başlangıç Tutarı (₺)', _initialCtrl),
              _buildInputRow('Aylık İlave Tasarruf (₺)', _monthlyCtrl),
              _buildInputRow('Yıllık Tahmini Getiri (%)', _rateCtrl),
              _buildInputRow('Yatırım Süresi (Yıl)', _yearsCtrl),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _calculateCompoundInterest,
                style: ElevatedButton.styleFrom(backgroundColor: kPurple, minimumSize: const Size(double.infinity, 48)),
                child: const Text('Hesapla', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),
              Text('Gelecekteki Toplam Birikim', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                '₺ ${_compoundResult.toStringAsFixed(2)}',
                style: const TextStyle(color: kGreen, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Zaman en büyük müttefiğinizdir! Süreyi ne kadar artırırsanız, bileşik faizin gücü o kadar dramatikleşir.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── 2. 50/30/20 Bütçeleme Kuralı ────────────────────────────────────────────
  Widget _build503020Content() {
    return ValueListenableBuilder(
      valueListenable: _incomeCtrl,
      builder: (context, val, child) {
        final double income = double.tryParse(_incomeCtrl.text) ?? 0.0;
        final double needs = income * 0.5;
        final double wants = income * 0.3;
        final double savings = income * 0.2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoverCard(
              icon: Icons.pie_chart_rounded,
              color: kGreen,
              text: 'Kişisel finansın en popüler ve uygulaması en kolay bütçeleme kuralıdır. Gelirinizi üç net kategoriye bölerek paranızı suçluluk hissetmeden yönetmenizi sağlar.',
            ),
            const SizedBox(height: 24),
            _buildHeaderSection('Üç Temel Kategori', 'Kural, aylık net gelirinizi şu şekilde planlamayı önerir:\n\n•  %50 İhtiyaçlar: Hayatınızı sürdürmek için zorunlu olan harcamalar (ev kirası, faturalar, mutfak alışverişi, ulaşım).\n\n•  %30 İstekler: Yaşam kalitenizi artıran eğlenceli harcamalar (dışarıda yemek, seyahat, hobiler, abonelikler).\n\n•  %20 Tasarruflar: Geleceğinizi inşa eden yatırımlar (kumbara hedefleri, borç kapatma, acil durum fonu).'),
            const SizedBox(height: 32),
            const Text('🧮 50/30/20 Bütçe Simülatörü', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Aylık Net Gelirinizi Yazın:', style: TextStyle(color: Colors.white, fontSize: 13)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _incomeCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixText: '₺ ',
                      prefixStyle: const TextStyle(color: kGreen, fontSize: 18),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.03),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kGreen),
                      ),
                    ),
                    onChanged: (v) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 28),
                  
                  // Visual distribution bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 24,
                      child: Row(
                        children: [
                          Expanded(flex: 50, child: Container(color: kTeal, child: const Center(child: Text('%50', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))))),
                          Expanded(flex: 30, child: Container(color: kYellow, child: const Center(child: Text('%30', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10))))),
                          Expanded(flex: 20, child: Container(color: kPurple, child: const Center(child: Text('%20', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildCategoryResultTile('İhtiyaçlar (%50)', 'Hayatta kalmak için zorunlu harcamalar', needs, kTeal),
                  const SizedBox(height: 14),
                  _buildCategoryResultTile('İstekler (%30)', 'Hayatın keyifli yönleri, hobileriniz', wants, kYellow),
                  const SizedBox(height: 14),
                  _buildCategoryResultTile('Tasarruf & Yatırım (%20)', 'Geleceğiniz ve kumbaralarınız', savings, kPurple),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── 3. Acil Durum Fonu İçeriği ──────────────────────────────────────────────
  Widget _buildEmergencyFundContent() {
    return ValueListenableBuilder(
      valueListenable: _expensesCtrl,
      builder: (context, val, child) {
        final double expenses = double.tryParse(_expensesCtrl.text) ?? 0.0;
        final double minFund = expenses * 3;
        final double maxFund = expenses * 6;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoverCard(
              icon: Icons.shield_rounded,
              color: kRed,
              text: 'Hayat sürprizlerle doludur. İş kaybı, sağlık sorunları veya acil araç tamiri gibi beklenmedik durumlarda borçlanmadan ayakta kalabilmeniz için gereken finansal kalkandır.',
            ),
            const SizedBox(height: 24),
            _buildHeaderSection('Ne Kadar Biriktirmeli?', 'Finansal danışmanlar, aylık asgari zorunlu giderlerinizin en az **3 ila 6 katı** büyüklüğünde bir nakit rezervine sahip olmanızı önerir. Bu fon kolay erişilebilir olmalı (örneğin faizli bir günlük vadeli mevduat hesabı), yatırımlarda kilitli olmamalıdır.'),
            const SizedBox(height: 32),
            const Text('🧮 Acil Durum Fonu Hesaplayıcı', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Aylık Asgari Zorunlu Giderleriniz (₺):', style: TextStyle(color: Colors.white, fontSize: 13)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _expensesCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixText: '₺ ',
                      prefixStyle: const TextStyle(color: kRed, fontSize: 18),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.03),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kRed),
                      ),
                    ),
                    onChanged: (v) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 28),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniFundCard('Giriş Seviyesi (3 Ay)', '₺${minFund.toStringAsFixed(0)}', kYellow),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildMiniFundCard('Tam Koruma (6 Ay)', '₺${maxFund.toStringAsFixed(0)}', kGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.tips_and_updates_rounded, color: kYellow, size: 20),
                      SizedBox(width: 8),
                      Text('Tasarruf Koçu Önerisi:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Acil durum fonunuzu oluşturmak için hemen birikim hedeflerinden "Acil Durum Kumbarası" oluşturun ve her ay maaşınızın %10\'unu otomatik olarak buraya ekleyin!',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── 4. Temel Finansal Kavramlar ───────────────────────────────────────────
  Widget _buildBasicConceptsContent() {
    final concepts = [
      _Concept(
        icon: Icons.trending_up_rounded,
        color: kPurple,
        title: 'Enflasyon',
        body:
            'Enflasyon, bir ekonomideki mal ve hizmet fiyatlarının genel düzeyinin zaman içinde sürekli artmasıdır. Yıllık %20 enflasyonda, bu yıl 100 TL olan şey gelecek yıl 120 TL olacaktır. Bu nedenle nakit tutmak, satın alma gücünüzü eritir. Para birikterken enflasyonun üzerinde getiri sağlayan araçlar kullanmanız gerekir.',
      ),
      _Concept(
        icon: Icons.swap_horiz_rounded,
        color: kTeal,
        title: 'Likidite',
        body:
            'Likidite, bir varlığı ne kadar hızlı ve kolay nakde çevirebileceğinizin ölçüsüdür. Nakit en likit varlıktır. Ev ise düşlik likiditeye sahip bir varlıktır — satmak zaman alır. Acil durum fonunuzu her zaman yüksek likidite sağlayan hesaplarda tutun.',
      ),
      _Concept(
        icon: Icons.pie_chart_rounded,
        color: kGreen,
        title: 'Diversifikasyon (Portföy Dağılımı)',
        body:
            'Tüm yumurtaları aynı sepete koymayın! Farklı varlık sınıflarına (hisse, tahvil, altın, döviz, dükkanda mevduat) yatırım yaparak riski dağıtırsınız. Bir yatırım zarar etse bile diğerleri onu telafi eder. Bu, risk yönetiminin temelidir.',
      ),
      _Concept(
        icon: Icons.currency_lira_rounded,
        color: kYellow,
        title: 'Net Değer (Net Worth)',
        body:
            'Net değeriniz = Varlıklarınız − Borçlarınız. Örneğin: Evinizin değeri 3.000.000 TL, kredi borcunuz 1.000.000 TL, tasarrufunuz 500.000 TL ise net değeriniz 2.500.000 TL’dir. Bu değeri her yıl artirmayı hedefleyin; finansal bağımsızlığın en net göstergesidir.',
      ),
      _Concept(
        icon: Icons.percent_rounded,
        color: kRed,
        title: 'Faiz Oranı & APR',
        body:
            'Faiz, aldığınız borç için ödediğiniz veya verdiğiniz borç için aldığınız bedeldir. Yıllık faiz oranı (APR) ile efektif yıllık faiz arasındaki farktan haberdar olun. Bileşik faizde APR, nominal orandan daha yüksek gerçek maliyeti gösterir.',
      ),
      _Concept(
        icon: Icons.balance_rounded,
        color: kPurple,
        title: 'Borç/Gelir Oranı (DTI)',
        body:
            'Borç/Gelir Oranı (Debt-to-Income), aylık borç ödemelerinizin aylık brüt gelire bölümünün yüzdesini gösterir. Bankalar genellikle DTI’nın %43’ün altında olmasını ister. %36 altı “sáğlıklı”, %50 üzeri “riski” kabul edilir.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCoverCard(
          icon: Icons.menu_book_rounded,
          color: kPurple,
          text:
              'Finansal bağımsızlık yolculuğunuzda en önemli adım; temel kavramları anlamaktır. Enflasyon, faiz, likidite ve diversifikasyon gibi terimler artık gizemli olmaktan çıkacak!',
        ),
        const SizedBox(height: 28),
        ...concepts.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildConceptCard(c),
            )),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildConceptCard(_Concept c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.color.withOpacity(0.2), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: c.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(c.icon, color: c.color, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                c.title,
                style: TextStyle(
                    color: c.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            c.body,
            style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 13,
                height: 1.55),
          ),
        ],
      ),
    );
  }

  // ─── 5. Vergi & Hukuk ────────────────────────────────────────────────────────
  Widget _buildTaxLawContent() {
    final topics = [
      _Concept(
        icon: Icons.receipt_long_rounded,
        color: kTeal,
        title: 'Gelir Vergisi',
        body:
            'Türkiye’de bireyler elde ettikleri gelir üzerinden artan oranlı gelir vergisi öder. 2024 yılı dilimleri: 0–70.000 TL arası %15, 70.000–150.000 TL arası %20, 150.000–370.000 TL arası %27, 370.000–1.900.000 TL arası %35, 1.900.000 TL üstesi %40 oranında vergilendirilir. Ücretsiz çalışanlar için bu vergi işveren tarafından stopaj yoluyla kesilir.',
      ),
      _Concept(
        icon: Icons.store_rounded,
        color: kPurple,
        title: 'KDV (Katma Değer Vergisi)',
        body:
            'KDV, mal ve hizmetlerin üretiminden tüketimine kadar her aşamada eklenen bir tüketim vergisidir. Türkiye’de genel KDV oranı %20’dir (2024’te %18’den artırılmıştır). Gıda, ilaç, kitap gibi bazı ürünlerde indirimli oranlar (%1 ve %10) uygulanır.',
      ),
      _Concept(
        icon: Icons.account_balance_rounded,
        color: kGreen,
        title: 'SGK ve Sosyal Güvenlik',
        body:
            'Çalışanlar, maaşlarından SGK primini (%14 işçi, %20.5 işveren payi) öderler. Primödemeler; emeklilik, hastalık, iş kazası ve işsizlik sigortalarını kapsar. 4A (SSK), 4B (Bağ-Kur), 4C (Emekli Sandığı) ayrımı, ödenecek primler ve emeklilik koşullarını belirler.',
      ),
      _Concept(
        icon: Icons.home_rounded,
        color: kYellow,
        title: 'Emlak ve Tapu İşlemleri',
        body:
            'Gayrimenkul satın alırken tapu harcı (satış bedelinin %4’ü) ödenir. Belirli koullarda KDV de (örneğin net 150 m² altı konutlarda %1) uygulanabilir. Kira geliri elde edenlerin yıllık kira beyannamesi vermesi zorunludur. 2024 itibarıyla 33.000 TL’ye kadar kira geliri vergiden istisnadır.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCoverCard(
          icon: Icons.gavel_rounded,
          color: kTeal,
          text:
              'Vergi ve hukuki yükümlülüklerinizi bilmek, hem yasal hem de finansal açıdan sizi korur. Cehaleti mazeret kabul etmez; ancak bilmek size büyük avantaj sağlar.',
        ),
        const SizedBox(height: 28),
        ...topics.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildConceptCard(c),
            )),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kRed.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kRed.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: kRed, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Önemli: Bu bilgiler genel bilgilendirme amaçlıdır. Vergi kararı almadan önce lütfen lisanslı bir mali müşavire danışın.',
                  style: TextStyle(color: kRed.withOpacity(0.9), fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ─── Yardımcı Arayüz Bileşenleri ───────────────────────────────────────────
  Widget _buildCoverCard({required IconData icon, required Color color, required String text}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(String subtitle, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.5)),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInputRow(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13))),
          Expanded(
            flex: 2,
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: Colors.white.withOpacity(0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryResultTile(String title, String subtitle, double amount, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
            ],
          ),
        ),
        Text('₺ ${amount.toStringAsFixed(0)}', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMiniFundCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          const SizedBox(height: 6),
          Text(amount, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─── Data Model for Concept Cards ──────────────────────────────────────────
class _Concept {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _Concept({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
}
