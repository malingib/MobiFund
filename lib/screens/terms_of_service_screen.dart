import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Terms of Service',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.softGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  borderRadius: BorderRadius.circular(28),
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
                    const Text(
                      'Terms of Service',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The rules that govern how the service should be used.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface2,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
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
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface2,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}
