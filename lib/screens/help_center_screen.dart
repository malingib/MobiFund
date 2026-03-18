import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _searchCtrl = TextEditingController();

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I add a new member?',
      'a': 'Go to the Members tab and click on "Add New Member". Fill in their details and click save.',
    },
    {
      'q': 'What are the billing tiers?',
      'a': 'We offer Free, Pro, and Enterprise tiers. Pro adds advanced analytics, while Enterprise includes custom support and unlimited members.',
    },
    {
      'q': 'How do I reconcile with M-Pesa?',
      'a': 'Go to the M-Pesa Recon tool in the dashboard. It automatically matches your M-Pesa statements with app contributions.',
    },
    {
      'q': 'Is my data secure?',
      'a': 'Yes, we use bank-level encryption (AES-256) and secure Supabase backend to ensure your data is always safe.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Help Center'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHero(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionTitle('Frequently Asked Questions'),
                const SizedBox(height: 12),
                ..._faqs.map((faq) => _buildFaqTile(faq)),
                const SizedBox(height: 32),
                _buildSectionTitle('Need more help?'),
                const SizedBox(height: 16),
                _buildContactCard(
                  title: 'Chat with Support',
                  subtitle: 'Our team typically replies in minutes',
                  icon: Icons.chat_bubble_outline,
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 12),
                _buildContactCard(
                  title: 'Email us',
                  subtitle: 'support@mobifund.io',
                  icon: Icons.email_outlined,
                  color: AppTheme.info,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        gradient: AppTheme.primaryGradient,
      ),
      child: Column(
        children: [
          const Text(
            'How can we help you?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search for articles, guides...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: AppTheme.textLight),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.headline.copyWith(fontSize: 18),
    );
  }

  Widget _buildFaqTile(Map<String, String> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: ExpansionTile(
        title: Text(
          faq['q']!,
          style: AppTheme.body.copyWith(fontWeight: FontWeight.w600),
        ),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq['a']!,
              style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.body.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: AppTheme.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textLight),
        ],
      ),
    );
  }
}
