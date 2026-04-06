import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import 'platform_org_detail_screen.dart';

class PlatformShell extends StatefulWidget {
  const PlatformShell({super.key});

  @override
  State<PlatformShell> createState() => _PlatformShellState();
}

class _PlatformShellState extends State<PlatformShell> {
  final _supabase = SupabaseService();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (!state.isPlatformAdmin) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          backgroundColor: AppTheme.bg,
          elevation: 0,
          title: const Text('Platform Dashboard'),
        ),
        body: const Center(
          child: Text('Forbidden: platform admin required'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: Text(
          'Platform Dashboard',
          style: AppTheme.headline.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _supabase.fetchPlatformOrgDirectory(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Failed to load org directory:\n${snap.error}',
                  style: AppTheme.body.copyWith(color: AppTheme.danger),
                ),
              ),
            );
          }
          final rows = snap.data ?? const [];
          if (rows.isEmpty) {
            return const Center(child: Text('No organizations found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final r = rows[i];
              final orgId = (r['org_id'] ?? '').toString();
              final name = (r['org_name'] ?? 'Unknown Org').toString();
              final tier = (r['tier'] ?? 'free').toString();
              final memberCount = (r['member_count'] ?? 0).toString();

              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlatformOrgDetailScreen(row: r),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.apartment,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tier: ${tier.toUpperCase()} • Members: $memberCount',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          orgId.substring(0, orgId.length >= 6 ? 6 : orgId.length),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, color: AppTheme.textLight),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

