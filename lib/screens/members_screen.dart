import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _showForm = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _addMember() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final state = context.read<AppState>();
    final member = OrgMember(
      orgId: state.currentOrg!.id,
      userId: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    );
    await state.addMember(member);
    _nameCtrl.clear();
    _phoneCtrl.clear();
    _notesCtrl.clear();
    setState(() {
      _saving = false;
      _showForm = false;
    });
    if (mounted) {
      NotificationService()
          .showSuccess(context, '${member.name} added successfully');
    }
  }

  Future<void> _deleteMember(OrgMember m) async {
    final appState = context.read<AppState>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline, color: AppTheme.danger),
            ),
            const SizedBox(width: 12),
            Text('Remove Member', style: AppTheme.headline),
          ],
        ),
        content: Text(
          'Remove ${m.name}? Their contribution history will remain.',
          style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTheme.body.copyWith(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.danger,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await appState.deleteMember(m.id);
      if (mounted) {
        NotificationService().showInfo(context, '${m.name} removed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.isLoading) {
      return const ListSkeleton();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Stats overview
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Total Members',
                  '${state.members.length}',
                  Icons.people,
                  AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Active',
                  '${state.members.cast<OrgMember>().where((m) => m.id.isNotEmpty && state.getMemberTotal(m.id) > 0).length}',
                  Icons.check_circle,
                  AppTheme.success,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Add member button or form
          if (!_showForm)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.person_add_outlined,
                      color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Add New Member',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Grow your team by adding new members',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _showForm = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Add Member'),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('New Member', style: AppTheme.headline),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Close',
                          onPressed: () {
                            AppHaptics.selection();
                            setState(() => _showForm = false);
                          },
                          color: AppTheme.textLight,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Full Name',
                      hint: 'e.g. Jane Wambui',
                      controller: _nameCtrl,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Phone',
                      hint: 'e.g. 0712 345 678',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Notes',
                      hint: 'Any notes…',
                      controller: _notesCtrl,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _addMember,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Add Member'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Members list
          SectionCard(
            title: 'All Members (${state.members.length})',
            child: state.members.isEmpty
                ? _empty('No members yet')
                : Column(
                    children: state.members.cast<OrgMember>().map((m) {
                      final memberId = m.id;
                      final total = state.getMemberTotal(memberId);
                      final contribCount = state.contributions
                          .where((c) => c.userId == memberId)
                          .length;
                      return _memberTile(m, total, contribCount);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberTile(OrgMember m, double total, int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          MemberAvatar(initials: m.initials, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.name,
                  style: AppTheme.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (m.phone != null)
                      Text(
                        '${m.phone} · ',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    Text(
                      '$count contributions',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatKes(total),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _deleteMember(m),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.danger),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Remove',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _empty(String msg) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.inbox_outlined,
                  size: 48, color: AppTheme.textLight),
              const SizedBox(height: 12),
              Text(
                msg,
                style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
}
