import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/mobifund_logo.png',
                      width: 200,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Mobifund',
                      style: textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Group Finance Tracker',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'About',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mobifund helps groups manage contributions, expenses and members. Designed and built by Mobiwave Innovations Limited.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Column(
                  children: [
                    Text('© 2026 Mobiwave Innovations Limited'),
                    SizedBox(height: 4),
                    Text('Powered by Mobiwave'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
