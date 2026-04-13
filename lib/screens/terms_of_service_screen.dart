import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: const Text(
          'Terms of Service',
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
            _section('1. Acceptance of Terms'),
            const Text(
              'By accessing and using Mobifund, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by these terms, please do not use this service.',
            ),
            const SizedBox(height: 24),
            _section('2. Description of Service'),
            const Text(
              'Mobifund is a group finance management platform that enables organizations to manage contributions, expenses, loans, and other financial activities. The service provides tools for tracking transactions, generating reports, and facilitating group savings.',
            ),
            const SizedBox(height: 24),
            _section('3. User Accounts'),
            const Text(
              'You are responsible for maintaining the confidentiality of your account credentials. You agree to accept responsibility for all activities that occur under your account. You must notify us immediately of any unauthorized use of your account.',
            ),
            const SizedBox(height: 24),
            _section('4. Data Privacy'),
            const Text(
              'We collect and process your personal data in accordance with applicable data protection laws. Your financial data is encrypted and stored securely. We do not share your data with third parties without your consent, except as required by law.',
            ),
            const SizedBox(height: 24),
            _section('5. Financial Transactions'),
            const Text(
              'All financial transactions recorded in Mobifund are for tracking purposes only. The platform does not hold or transfer funds directly. Users are responsible for ensuring the accuracy of recorded transactions.',
            ),
            const SizedBox(height: 24),
            _section('6. Prohibited Uses'),
            const Text(
              'You may not use Mobifund for any illegal or unauthorized purpose. You must not violate any laws or infringe upon any intellectual property rights.',
            ),
            const SizedBox(height: 24),
            _section('7. Termination'),
            const Text(
              'We reserve the right to terminate or suspend your account at any time for violations of these terms or for any other reason with or without notice.',
            ),
            const SizedBox(height: 24),
            _section('8. Limitation of Liability'),
            const Text(
              'Mobifund and its developers shall not be liable for any indirect, incidental, special, or consequential damages resulting from the use or inability to use the service.',
            ),
            const SizedBox(height: 24),
            _section('9. Changes to Terms'),
            const Text(
              'We reserve the right to modify these terms at any time. Continued use of the service after changes constitutes acceptance of the new terms.',
            ),
            const SizedBox(height: 24),
            _section('10. Contact Information'),
            const Text(
              'For questions about these Terms of Service, please contact us through the Help Center in the app.',
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
}
