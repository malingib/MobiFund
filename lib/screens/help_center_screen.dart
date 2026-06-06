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
      'a':
          'Go to the Members tab and click on "Add New Member". Fill in their details and click save.',
    },
    {
      'q': 'What are the billing tiers?',
      'a':
          'We offer Free, Pro, and Enterprise tiers. Pro adds advanced analytics, while Enterprise includes custom support and unlimited members.',
    },
    {
      'q': 'How do I reconcile with M-Pesa?',
      'a':
          'Go to the M-Pesa Recon tool in the dashboard. It automatically matches your M-Pesa statements with app contributions.',
    },
    {
      'q': 'Is my data secure?',
      'a':
          'Yes, we use bank-level encryption (AES-256) and secure Supabase backend to ensure your data is always safe.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Help Center'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.softGradient),
        child: Column(
          children: [
            _buildHero(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                children: [
                  _buildSectionTitle('Frequently Asked Questions'),
                  const SizedBox(height: 12),
                  ..._faqs.map((faq) => _buildFaqTile(faq)),
                  const SizedBox(height: 28),
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
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.support_agent_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Help Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Find quick answers or reach support without leaving the app.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search for articles, guides...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                hintStyle: TextStyle(color: Colors.white70),
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
      style: AppTheme.headline.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildFaqTile(Map<String, String> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
