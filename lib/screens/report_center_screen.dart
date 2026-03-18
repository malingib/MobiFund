import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/report_service.dart';
import '../theme/app_theme.dart';

class ReportCenterScreen extends StatefulWidget {
  const ReportCenterScreen({super.key});

  @override
  State<ReportCenterScreen> createState() => _ReportCenterScreenState();
}

class _ReportCenterScreenState extends State<ReportCenterScreen> {
  bool _isGenerating = false;

  Future<void> _handleReportTap(BuildContext context, String type) async {
    final state = context.read<AppState>();
    final orgName = state.currentOrg?.name ?? 'My Chama';

    setState(() => _isGenerating = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      switch (type) {
        case 'Income Statement':
        case 'PDF Export':
          await ReportService.generateFinancialStatement(
            orgName: orgName,
            contributions: state.contributions,
            expenses: state.expenses,
          );
          break;
        case 'Excel / CSV':
          await ReportService.exportToExcel(
            orgName: orgName,
            contributions: state.contributions,
            expenses: state.expenses,
            members: state.members,
          );
          break;
        case 'Contribution Summary':
          // For now, use the same financial statement as it includes contributions
          await ReportService.generateFinancialStatement(
            orgName: orgName,
            contributions: state.contributions,
            expenses: state.expenses,
          );
          break;
        default:
          messenger.showSnackBar(
            SnackBar(content: Text('$type generation coming soon')),
          );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(
            title: const Text('Report Center'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSection(
                  context,
                  title: 'Financial Statements',
                  reports: [
                    _ReportItem(
                      title: 'Income Statement',
                      description: 'Detailed view of revenues and expenses',
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppTheme.primary,
                    ),
                    _ReportItem(
                      title: 'Balance Sheet',
                      description: 'Assets, liabilities, and equity overview',
                      icon: Icons.pie_chart_outline,
                      color: AppTheme.info,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  context,
                  title: 'Member Reports',
                  reports: [
                    _ReportItem(
                      title: 'Contribution Summary',
                      description: 'Member-wise contribution breakdown',
                      icon: Icons.people_outline,
                      color: AppTheme.success,
                    ),
                    _ReportItem(
                      title: 'Loan Performance',
                      description: 'Status and repayment health of all loans',
                      icon: Icons.trending_up_outlined,
                      color: AppTheme.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  context,
                  title: 'Export Options',
                  reports: [
                    _ReportItem(
                      title: 'PDF Export',
                      description: 'Generate professional PDF reports',
                      icon: Icons.picture_as_pdf_outlined,
                      color: AppTheme.danger,
                    ),
                    _ReportItem(
                      title: 'Excel / CSV',
                      description: 'Download raw data for analysis',
                      icon: Icons.table_chart_outlined,
                      color: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_isGenerating)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Generating Report...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
        gradient: AppTheme.primaryGradient,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.analytics_outlined, color: Colors.white, size: 40),
          SizedBox(height: 16),
          Text(
            'Generate Financial Reports',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Analyze your chama\'s financial health with detailed insights.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required List<_ReportItem> reports}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.headline.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 12),
        Column(
          children: reports.map((r) => _buildReportTile(context, r)).toList(),
        ),
      ],
    );
  }

  Widget _buildReportTile(BuildContext context, _ReportItem report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: report.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(report.icon, color: report.color),
        ),
        title: Text(
          report.title,
          style: AppTheme.body.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          report.description,
          style: AppTheme.caption,
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: AppTheme.textLight),
        onTap: () => _handleReportTap(context, report.title),
      ),
    );
  }
}

class _ReportItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _ReportItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
