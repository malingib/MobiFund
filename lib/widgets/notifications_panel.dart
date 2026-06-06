import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'shared_widgets.dart';

/// Notifications derived from real activity in [AppState] — there's no
/// separate notifications table on the backend. Each feed item is a
/// projection of a contribution, expense, or scheduled MGR payout. The
/// bell badge is computed by comparing the newest item's timestamp with
/// the last-seen timestamp persisted in SharedPreferences.

const _lastSeenKey = 'notifications.lastSeenAt';

/// Public surface — call from the AppBar bell. Shows the bottom sheet AND
/// marks all currently-visible items as seen on dismiss.
Future<void> showNotificationsSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surface2,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => const _NotificationsSheet(),
  );

  // Mark seen on dismiss — the user has now had a chance to read them.
  // Stamp with `now` so any item created after this point is still "new".
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_lastSeenKey, DateTime.now().toIso8601String());
  // Nudge listeners so the AppBar badge re-evaluates.
  NotificationsBadge.notifySeen();
}

/// Inline badge widget for the AppBar bell. Wraps the icon and shows a
/// small unread dot when there is at least one item newer than the
/// last-seen timestamp. Listens to AppState so it updates on sync.
class NotificationsBadge extends StatefulWidget {
  final Widget child;

  const NotificationsBadge({super.key, required this.child});

  // Lightweight pub/sub so `showNotificationsSheet` can poke the badge
  // after it stamps a new last-seen timestamp without us routing through
  // AppState for transient UI plumbing.
  static final ValueNotifier<int> _seenTick = ValueNotifier(0);
  static void notifySeen() => _seenTick.value = _seenTick.value + 1;

  @override
  State<NotificationsBadge> createState() => _NotificationsBadgeState();
}

class _NotificationsBadgeState extends State<NotificationsBadge> {
  DateTime? _lastSeen;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadLastSeen();
    NotificationsBadge._seenTick.addListener(_loadLastSeen);
  }

  @override
  void dispose() {
    NotificationsBadge._seenTick.removeListener(_loadLastSeen);
    super.dispose();
  }

  Future<void> _loadLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastSeenKey);
    if (!mounted) return;
    setState(() {
      _lastSeen = raw == null ? null : DateTime.tryParse(raw);
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = _buildItems(state);
    final unread = !_loaded
        ? 0
        : items.where((i) {
            if (_lastSeen == null) return true;
            return i.timestamp.isAfter(_lastSeen!);
          }).length;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (unread > 0)
          Positioned(
            right: 6,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: AppTheme.danger,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppTheme.bg, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                unread > 9 ? '9+' : '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = _buildItems(state);

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: AppTheme.headline.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (items.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                          _lastSeenKey,
                          DateTime.now().toIso8601String(),
                        );
                        NotificationsBadge.notifySeen();
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),
            Flexible(
              child: items.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.fromLTRB(20, 24, 20, 32),
                      child: AppEmptyState(
                        icon: Icons.notifications_none_outlined,
                        title: 'You are all caught up',
                        message:
                            'Contributions, expenses, and scheduled payouts will show up here as your group records activity.',
                      ),
                    )
                  : _GroupedList(items: items),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupedList extends StatelessWidget {
  final List<_NotifItem> items;
  const _GroupedList({required this.items});

  @override
  Widget build(BuildContext context) {
    // Group by calendar day, newest day first.
    final byDay = <DateTime, List<_NotifItem>>{};
    for (final item in items) {
      final key = DateTime(
          item.timestamp.year, item.timestamp.month, item.timestamp.day);
      byDay.putIfAbsent(key, () => []).add(item);
    }
    final dayKeys = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
      itemCount: dayKeys.length,
      itemBuilder: (context, index) {
        final day = dayKeys[index];
        final group = byDay[day]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              child: Text(
                _dayLabel(day),
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  fontSize: 11,
                ),
              ),
            ),
            ...group.map((item) => _NotifRow(item: item)),
          ],
        );
      },
    );
  }

  String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (day == today) return 'TODAY';
    if (day == yesterday) return 'YESTERDAY';
    return formatDate(day).toUpperCase();
  }
}

class _NotifRow extends StatelessWidget {
  final _NotifItem item;
  const _NotifRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _timeLabel(item.timestamp),
            style: AppTheme.caption.copyWith(
              color: AppTheme.textLight,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return formatShortDate(t);
  }
}

// ─────────────────────────────────────────
// FEED CONSTRUCTION
// Pulls from AppState (contributions, expenses, MGR cycles) and projects
// each into a uniform _NotifItem. No backend call — these are live
// derivations from in-memory state.
// ─────────────────────────────────────────

class _NotifItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final IconData icon;
  final Color color;

  _NotifItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.icon,
    required this.color,
  });
}

List<_NotifItem> _buildItems(AppState state) {
  final items = <_NotifItem>[];

  String memberName(String memberId) {
    final m = state.members.firstWhere(
      (m) => m.id == memberId,
      orElse: () => OrgMember(
        orgId: state.currentOrg?.id ?? '',
        userId: '',
        name: 'A member',
      ),
    );
    return m.name;
  }

  // Cap each source so the feed stays glanceable. Treasurers want
  // signal, not a transaction log — they have the Reports page for that.
  final recentContribs = [...state.contributions]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  for (final c in recentContribs.take(15)) {
    items.add(_NotifItem(
      id: 'c-${c.id}',
      title: '${memberName(c.memberId)} contributed',
      body:
          '${formatKes(c.amount)} recorded on ${formatShortDate(c.date)}',
      timestamp: c.createdAt,
      icon: Icons.arrow_downward_rounded,
      color: AppTheme.success,
    ));
  }

  final recentExpenses = [...state.expenses]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  for (final e in recentExpenses.take(15)) {
    final desc = (e.description == null || e.description!.isEmpty)
        ? e.type
        : e.description!;
    items.add(_NotifItem(
      id: 'e-${e.id}',
      title: 'Expense logged',
      body: '${formatKes(e.amount)} • $desc',
      timestamp: e.createdAt,
      icon: Icons.arrow_upward_rounded,
      color: AppTheme.danger,
    ));
  }

  // Upcoming MGR payouts inside the next 14 days → forward-looking
  // notification. Use the scheduled startDate as the "timestamp" so it
  // sorts naturally next to recent activity.
  final now = DateTime.now();
  for (final cycle in state.merryGoRoundCycles) {
    if (cycle.status != 'active' && cycle.status != 'planning') continue;
    final delta = cycle.startDate.difference(now);
    if (delta.isNegative || delta.inDays > 14) continue;
    items.add(_NotifItem(
      id: 'mgr-${cycle.id}',
      title: 'Upcoming payout — ${cycle.name}',
      body:
          '${formatKes(cycle.contributionAmount)} per member • ${formatShortDate(cycle.startDate)}',
      timestamp: cycle.startDate,
      icon: Icons.event_outlined,
      color: AppTheme.primary,
    ));
  }

  // Offline indicator — surfaces as a notification when relevant. Stamp
  // with `now` so it always sits at the top while it's true.
  if (!state.isOnline) {
    items.add(_NotifItem(
      id: 'offline',
      title: "You're offline",
      body:
          'Showing your last saved data. Changes sync automatically when you reconnect.',
      timestamp: now,
      icon: Icons.cloud_off_outlined,
      color: AppTheme.warning,
    ));
  }

  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  // Hard cap the visible feed.
  return items.take(40).toList();
}
