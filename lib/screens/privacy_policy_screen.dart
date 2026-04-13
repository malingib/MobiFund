import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your privacy is important to us. This policy explains how we collect, use, and protect your personal information.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _section('1. Information We Collect'),
            const Text(
              'We collect information that you provide directly to us, including:',
            ),
            const SizedBox(height: 8),
            _bullet('• Account information (name, email, phone number)'),
            _bullet('• Organization details and membership data'),
            _bullet('• Financial transaction records'),
            _bullet('• Communication preferences'),
            _bullet('• Device and usage information'),
            const SizedBox(height: 24),
            _section('2. How We Use Your Information'),
            const Text(
              'We use the information we collect to:',
            ),
            const SizedBox(height: 8),
            _bullet('• Provide, maintain, and improve our services'),
            _bullet('• Process your transactions and send notifications'),
            _bullet('• Respond to your comments and questions'),
            _bullet('• Develop new features and functionality'),
            _bullet('• Monitor and analyze trends and usage'),
            const SizedBox(height: 24),
            _section('3. Data Security'),
            const Text(
              'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. All data is encrypted both in transit and at rest using industry-standard encryption protocols.',
            ),
            const SizedBox(height: 24),
            _section('4. Data Sharing'),
            const Text(
              'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent. This does not include trusted third parties who assist us in operating our application, conducting our business, or servicing you, as long as those parties agree to keep this information confidential.',
            ),
            const SizedBox(height: 24),
            _section('5. Data Retention'),
            const Text(
              'We retain your personal information for as long as your account is active or as needed to provide you services. You can request deletion of your data at any time, subject to legal obligations to retain certain records.',
            ),
            const SizedBox(height: 24),
            _section('6. Your Rights'),
            const Text(
              'You have the right to:',
            ),
            const SizedBox(height: 8),
            _bullet('• Access your personal data'),
            _bullet('• Correct inaccurate data'),
            _bullet('• Request deletion of your data'),
            _bullet('• Object to processing of your data'),
            _bullet('• Export your data in a portable format'),
            const SizedBox(height: 24),
            _section('7. Children\'s Privacy'),
            const Text(
              'Our service does not address anyone under the age of 18. We do not knowingly collect personal information from children. If you discover that a child has provided us with personal information, please contact us immediately.',
            ),
            const SizedBox(height: 24),
            _section('8. Changes to This Policy'),
            const Text(
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "last updated" date.',
            ),
            const SizedBox(height: 24),
            _section('9. Contact Us'),
            const Text(
              'If you have any questions about this Privacy Policy, please contact us through the Help Center in the app or email us at privacy@mobifund.local.',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Text(
                'Last updated: April 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
