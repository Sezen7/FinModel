import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'education_detail_page.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      appBar: AppBar(
        title: const Text('Finansal Eğitim'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDailyTip(),
            const SizedBox(height: 32),
            _buildSectionTitle('İnteraktif Kartlar (Tıklayın 🧮)'),
            const SizedBox(height: 16),
            _buildInteractiveCards(),
            const SizedBox(height: 32),
            _buildSectionTitle('Eğitim Kategorileri'),
            const SizedBox(height: 16),
            _buildEducationCategories(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTip() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPurple, kTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Günün Finansal Tüyosu',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Birikim yaparken "önce kendine öde" kuralını uygula. Maaşın yatar yatmaz belirlediğin tutarı ayır.',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInteractiveCards() {
    final cards = [
      _EduCard(
        title: 'Bileşik Faiz Nedir?',
        subtitle: 'Paranın zaman içindeki gücü',
        icon: Icons.trending_up_rounded,
        color: kPurple,
        topicKey: 'compound_interest',
      ),
      _EduCard(
        title: '50/30/20 Kuralı',
        subtitle: 'Bütçelemenin altın kuralı',
        icon: Icons.pie_chart_rounded,
        color: kGreen,
        topicKey: 'budget_50_30_20',
      ),
      _EduCard(
        title: 'Acil Durum Fonu',
        subtitle: 'Güvenliğinizi sağlayın',
        icon: Icons.shield_rounded,
        color: kRed,
        topicKey: 'emergency_fund',
      ),
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EducationDetailPage(topicKey: card.topicKey),
                ),
              );
            },
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kBgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: card.color.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(card.icon, color: card.color, size: 32),
                  const Spacer(),
                  Text(card.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(card.subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEducationCategories(BuildContext context) {
    final categories = [
      {'name': 'Temel Kavramlar', 'icon': Icons.menu_book_rounded, 'count': '12 Ders', 'key': 'basic_concepts'},
      {'name': 'Bütçe Planlama', 'icon': Icons.insights_rounded, 'count': '8 Ders', 'key': 'budget_50_30_20'},
      {'name': 'Borç & Güvenlik', 'icon': Icons.credit_card_off_rounded, 'count': '5 Ders', 'key': 'emergency_fund'},
      {'name': 'Vergi & Hukuk', 'icon': Icons.gavel_rounded, 'count': '4 Ders', 'key': 'tax_law'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EducationDetailPage(topicKey: cat['key'] as String),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat['icon'] as IconData, color: kTeal, size: 28),
                const SizedBox(height: 12),
                Text(cat['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(cat['count'] as String, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EduCard {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String topicKey;

  _EduCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.topicKey,
  });
}
