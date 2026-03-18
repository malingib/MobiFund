import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/module_models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class SharesScreen extends StatefulWidget {
  const SharesScreen({super.key});

  @override
  State<SharesScreen> createState() => _SharesScreenState();
}

class _SharesScreenState extends State<SharesScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final shares = state.shares;
    final totalValue = shares.fold(0.0, (sum, s) => sum + s.totalValue);
    final totalShares = shares.fold(0, (sum, s) => sum + s.numberOfShares);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Summary Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Icon(Icons.pie_chart, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                Text(
                  formatKes(totalValue),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Total Share Value',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalShares shares owned',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Buy Shares Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showBuySharesDialog(context),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Buy Shares'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Shares List
          SectionCard(
            title: 'My Shares',
            child: shares.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('No shares yet', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  )
                : Column(
                    children: shares.map((share) => _shareTile(share)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _shareTile(Share share) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.show_chart, color: AppTheme.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${share.numberOfShares} shares @ ${formatKes(share.pricePerShare)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(share.purchaseDate),
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            formatKes(share.totalValue),
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _showBuySharesDialog(BuildContext context) {
    final state = context.read<AppState>();
    final sharesCtrl = TextEditingController();
    const pricePerShare = 1000.0; // Configurable in production

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Buy Shares'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Price per share: ${formatKes(pricePerShare)}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: sharesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Shares',
                hintText: 'e.g. 10',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (ctx) {
                final shares = int.tryParse(sharesCtrl.text) ?? 0;
                final total = shares * pricePerShare;
                return Text(
                  'Total: ${formatKes(total)}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final shares = int.tryParse(sharesCtrl.text) ?? 0;
              if (shares > 0) {
                state.purchaseShares(Share(
                  orgId: state.currentOrg!.id,
                  memberId: state.currentUserId,
                  numberOfShares: shares,
                  pricePerShare: pricePerShare,
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Shares purchased'), backgroundColor: AppTheme.success),
                );
              }
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }
}
