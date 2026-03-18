import 'package:flutter/foundation.dart';
import 'local_db.dart';
import 'supabase_service.dart';

/// Sync Service
///
/// Handles synchronization between local SQLite database and Supabase backend
///
/// Sync Strategy:
/// 1. Local-first: All operations happen locally first
/// 2. Background sync: When online, sync to Supabase
/// 3. Conflict resolution: Last write wins (based on updated_at)
/// 4. Offline queue: Failed syncs are retried
class SyncService {
  static final SupabaseService _supabase = SupabaseService();

  /// Push unsynced local data to Supabase
  static Future<void> pushUnsynced() async {
    try {
      if (!_supabase.isLoggedIn) {
        debugPrint('Sync: User not logged in, skipping push');
        return;
      }

      debugPrint('Sync: Starting push of unsynced data...');

      // Push members
      final unsyncedMembers = await LocalDb.getUnsyncedMembers();
      if (unsyncedMembers.isNotEmpty) {
        await _supabase.syncMembers(unsyncedMembers);
        for (var m in unsyncedMembers) {
          await LocalDb.markMemberSynced(m.id);
        }
        debugPrint('Sync: Pushed ${unsyncedMembers.length} members');
      }

      // Push contributions
      final unsyncedContributions = await LocalDb.getUnsyncedContributions();
      if (unsyncedContributions.isNotEmpty) {
        await _supabase.syncContributions(unsyncedContributions);
        for (var c in unsyncedContributions) {
          await LocalDb.markContributionSynced(c.id);
        }
        debugPrint(
            'Sync: Pushed ${unsyncedContributions.length} contributions');
      }

      // Push expenses
      final unsyncedExpenses = await LocalDb.getUnsyncedExpenses();
      if (unsyncedExpenses.isNotEmpty) {
        await _supabase.syncExpenses(unsyncedExpenses);
        for (var e in unsyncedExpenses) {
          await LocalDb.markExpenseSynced(e.id);
        }
        debugPrint('Sync: Pushed ${unsyncedExpenses.length} expenses');
      }

      // Push loans
      final unsyncedLoans = await LocalDb.getUnsyncedLoans();
      if (unsyncedLoans.isNotEmpty) {
        await _supabase.syncLoans(unsyncedLoans);
        for (var l in unsyncedLoans) {
          await LocalDb.markLoanSynced(l.id);
        }
        debugPrint('Sync: Pushed ${unsyncedLoans.length} loans');
      }

      debugPrint('Sync: Push complete');
    } catch (e) {
      debugPrint('Sync push error: $e');
      // Don't rethrow - allow app to continue working offline
    }
  }

  /// Pull latest data from Supabase into local DB
  static Future<void> pullAll({String? orgId}) async {
    try {
      if (!_supabase.isLoggedIn) {
        debugPrint('Sync: User not logged in, skipping pull');
        return;
      }

      debugPrint('Sync: Starting pull from Supabase...');

      // Resolve org ID
      String targetOrgId = orgId ?? '';
      if (targetOrgId.isEmpty) {
        final orgs = await _supabase.getOrganizations();
        if (orgs.isEmpty) {
          debugPrint('Sync: No organizations found in Supabase');
          return;
        }
        targetOrgId = orgs.first.id;
      }

      // Pull members
      final members = await _supabase.fetchMembers(targetOrgId);
      for (var m in members) {
        await LocalDb.insertMember(m.copyWith(synced: true));
      }
      debugPrint('Sync: Pulled ${members.length} members');

      // Pull contributions
      final contributions = await _supabase.fetchContributions(targetOrgId);
      for (var c in contributions) {
        await LocalDb.insertContribution(c.copyWith(synced: true));
      }
      debugPrint('Sync: Pulled ${contributions.length} contributions');

      // Pull expenses
      final expenses = await _supabase.fetchExpenses(targetOrgId);
      for (var e in expenses) {
        await LocalDb.insertExpense(e.copyWith(synced: true));
      }
      debugPrint('Sync: Pulled ${expenses.length} expenses');

      // Pull loans
      final loans = await _supabase.fetchLoans(targetOrgId);
      for (var l in loans) {
        await LocalDb.insertLoan(l);
      }
      debugPrint('Sync: Pulled ${loans.length} loans');

      debugPrint('Sync: Pull complete');
    } catch (e) {
      debugPrint('Sync pull error: $e');
      // Don't rethrow - allow app to continue working offline
    }
  }

  /// Full sync (push then pull)
  static Future<void> syncAll({String? orgId}) async {
    await pushUnsynced();
    await pullAll(orgId: orgId);
  }

  /// Soft-delete member on Supabase
  static Future<void> deleteRemoteMember(String memberId) async {
    try {
      await _supabase.client
          .from('members')
          .update({'is_active': false}).eq('id', memberId);
    } catch (e) {
      debugPrint('Delete remote member error: $e');
    }
  }

  /// Hard-delete contribution on Supabase (use with caution)
  static Future<void> deleteRemoteContribution(String contributionId) async {
    try {
      await _supabase.client
          .from('contributions')
          .delete()
          .eq('id', contributionId);
    } catch (e) {
      debugPrint('Delete remote contribution error: $e');
    }
  }

  /// Soft-delete expense on Supabase
  static Future<void> deleteRemoteExpense(String expenseId) async {
    try {
      await _supabase.client
          .from('expenses')
          .update({'is_active': false}).eq('id', expenseId);
    } catch (e) {
      debugPrint('Delete remote expense error: $e');
    }
  }

  /// Subscribe to real-time updates
  static void subscribeToOrg(
      String orgId, Function(String, Map<String, dynamic>) callback) {
    _supabase.subscribeToOrg(orgId, callback);
  }

  /// Unsubscribe from all channels
  static void unsubscribeAll() {
    _supabase.unsubscribeAll();
  }
}
