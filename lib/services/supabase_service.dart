import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/models.dart';
import '../models/module_models.dart';

/// Supabase Backend Service
///
/// Handles all backend operations including:
/// - Authentication
/// - Data sync (online)
/// - Real-time subscriptions
/// - Remote procedure calls
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // ⚠️  IMPORTANT: Load credentials from environment variables
  // The .env file must be kept secure and NEVER committed to version control
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://ttwubbbbmdwmnkavrqtl.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0d3ViYmJibWR3bW5rYXZycXRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM0MjYyNzQsImV4cCI6MjA4OTAwMjI3NH0.1DfYcbNpRMFdO_J8SSwjRAt_kl5IvOKjZCZ7v1vsM8A';

  // ⚠️  WARNING: Service role key should ONLY be used in Edge Functions
  // Never expose this in client-side code in production
  static String get serviceRoleKey =>
      dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

  SupabaseClient? _client;

  /// Get Supabase client
  SupabaseClient get client {
    _client ??= Supabase.instance.client;
    return _client!;
  }

  /// Initialize Supabase
  Future<void> init() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Supabase init error: $e');
      rethrow;
    }
  }

  /// Check if user is authenticated via Supabase
  bool get isLoggedIn => client.auth.currentUser != null;

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Get current user ID
  String? get currentUserId => currentUser?.id;

  // ─────────────────────────────────────────
  // AUTHENTICATION
  // ─────────────────────────────────────────

  /// Sign up with phone/password via Supabase Auth
  Future<AuthResponse> signUp({
    required String phone,
    required String password,
    String? email,
    String? name,
  }) async {
    try {
      // Always use phone-derived email for Supabase password auth.
      // This keeps login-by-phone consistent even if the user provided a real email.
      final emailForAuth = '${_normalizePhone(phone)}@mobifund.local';

      final response = await client.auth.signUp(
        email: emailForAuth,
        password: password,
        data: {
          'phone': _normalizePhone(phone),
          'name': name ?? '',
          'email': (email ?? '').trim(),
        },
      );

      // Create user profile record
      if (response.user != null) {
        await _upsertUserProfile(
          userId: response.user!.id,
          name: name ?? '',
          phone: _normalizePhone(phone),
          email: email,
        );
      }

      debugPrint('Sign up successful: ${response.user?.id}');
      return response;
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  /// Sign in with phone/password via Supabase Auth
  Future<AuthResponse> signIn({
    required String phone,
    required String password,
  }) async {
    try {
      // If user provided email-format input, use it directly, else convert phone
      final isEmail = phone.contains('@');
      final emailForAuth =
          isEmail ? phone : '${_normalizePhone(phone)}@mobifund.local';

      AuthResponse response;
      try {
        response = await client.auth.signInWithPassword(
          email: emailForAuth,
          password: password,
        );
      } on AuthException catch (e) {
        // Back-compat: older accounts may have been created with a real email as
        // the auth email. If login-by-phone fails, look up the email from the
        // profile table and retry.
        final isInvalidCreds =
            e.message.toLowerCase().contains('invalid login credentials');
        if (isEmail || !isInvalidCreds) rethrow;

        final normalized = _normalizePhone(phone);
        final variants = _phoneVariants(phone);
        if (!variants.contains(normalized)) variants.add(normalized);

        final profile = await client
            .from('users')
            .select('email')
            .inFilter('phone', variants)
            .limit(1)
            .maybeSingle();

        final profileEmail = (profile?['email'] as String?)?.trim();
        if (profileEmail == null || profileEmail.isEmpty) rethrow;

        response = await client.auth.signInWithPassword(
          email: profileEmail,
          password: password,
        );
      }

      debugPrint('Sign in successful: ${response.user?.id}');
      return response;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
    debugPrint('User signed out');
  }

  /// Send password reset email.
  ///
  /// Accepts either an email address or a phone number.
  Future<void> resetPassword(String identifier) async {
    final input = identifier.trim();
    final email = input.contains('@')
        ? input
        : '${_normalizePhone(input)}@mobifund.local';
    await client.auth.resetPasswordForEmail(email);
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // ─────────────────────────────────────────
  // USER PROFILE
  // ─────────────────────────────────────────

  Future<void> _upsertUserProfile({
    required String userId,
    required String name,
    required String phone,
    String? email,
  }) async {
    try {
      await client.from('users').upsert({
        'auth_id': userId,
        'name': name,
        'phone': phone,
        'email': email,
      }, onConflict: 'auth_id');
    } catch (e) {
      debugPrint('Upsert user profile error: $e');
    }
  }

  // ─────────────────────────────────────────
  // ORGANIZATIONS
  // ─────────────────────────────────────────

  /// Create organization
  Future<Organization> createOrganization(Organization org) async {
    try {
      final response = await client
          .from('organizations')
          .insert(org.toSupabase())
          .select()
          .single();

      return Organization.fromMap(response);
    } catch (e) {
      debugPrint('Create org error: $e');
      rethrow;
    }
  }

  /// Get all organizations for current user
  Future<List<Organization>> getOrganizations() async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];

      final List response = await client.from('organizations').select('''
            *,
            org_members!inner(user_id)
          ''').eq('org_members.user_id', userId).eq('is_active', true);

      return response
          .map((m) => Organization.fromMap(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get orgs error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────
  // PLATFORM DASHBOARD (SUPER ADMIN)
  // ─────────────────────────────────────────

  /// Platform-only: cross-org directory (aggregated + non-PII)
  Future<List<Map<String, dynamic>>> fetchPlatformOrgDirectory() async {
    final resp = await client
        .from('platform_org_directory')
        .select()
        .order('created_at', ascending: false);
    return (resp as List).cast<Map<String, dynamic>>();
  }

  /// Platform-only: fetch org by id (used for support mode entry)
  Future<Organization?> getOrganizationById(String orgId) async {
    final row = await client
        .from('organizations')
        .select()
        .eq('id', orgId)
        .maybeSingle();
    if (row == null) return null;
    return Organization.fromMap(row);
  }

  // ─────────────────────────────────────────
  // SUPPORT OVERRIDE (platform)
  // ─────────────────────────────────────────

  Future<Map<String, dynamic>> startSupportSession({
    required String orgId,
    required String reason,
    int ttlMinutes = 30,
  }) async {
    final data = await callEdgeFunction(
      functionName: 'support-start-session',
      body: {
        'org_id': orgId,
        'reason': reason,
        'ttl_minutes': ttlMinutes,
      },
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<void> endSupportSession({required String sessionId}) async {
    await callEdgeFunction(
      functionName: 'support-end-session',
      body: {'session_id': sessionId},
    );
  }

  // ─────────────────────────────────────────
  // ORGANIZATION MEMBERS
  // ─────────────────────────────────────────

  /// Add member to organization
  Future<OrgMember> addOrgMember(OrgMember member) async {
    try {
      final response = await client
          .from('org_members')
          .insert(member.toSupabase())
          .select()
          .single();

      return OrgMember.fromMap(response);
    } catch (e) {
      debugPrint('Add org member error: $e');
      rethrow;
    }
  }

  /// Get members of organization
  Future<List<OrgMember>> getOrgMembers(String orgId) async {
    try {
      final response = await client
          .from('org_members')
          .select()
          .eq('org_id', orgId)
          .eq('is_active', true);

      return (response as List).map((m) => OrgMember.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Get org members error: $e');
      return [];
    }
  }

  /// Update member role
  Future<void> updateMemberRole(
      String orgId, String userId, UserRole role) async {
    await client
        .from('org_members')
        .update({'role': role.code})
        .eq('org_id', orgId)
        .eq('user_id', userId);
  }

  // ─────────────────────────────────────────
  // MODULES
  // ─────────────────────────────────────────

  /// Activate module for organization
  Future<void> activateModule(String orgId, ModuleType moduleType,
      {Map<String, dynamic>? config}) async {
    try {
      await client.rpc('activate_module', params: {
        'p_org_id': orgId,
        'p_module_type': moduleType.code,
        'p_config': config != null ? jsonEncode(config) : null,
      });
    } catch (e) {
      // Fallback to insert/update
      final existing = await client
          .from('org_modules')
          .select()
          .eq('org_id', orgId)
          .eq('module_type', moduleType.code)
          .maybeSingle();

      if (existing != null) {
        await client.from('org_modules').update(
            {'is_active': true, 'config': config}).eq('id', existing['id']);
      } else {
        await client.from('org_modules').insert({
          'org_id': orgId,
          'module_type': moduleType.code,
          'is_active': true,
          'config': config,
        });
      }
    }
  }

  /// Get activated modules for organization
  Future<List<OrgModule>> getOrgModules(String orgId) async {
    try {
      final response = await client
          .from('org_modules')
          .select()
          .eq('org_id', orgId)
          .eq('is_active', true);

      return (response as List).map((m) => OrgModule.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Get modules error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────
  // MEMBERS
  // ─────────────────────────────────────────

  /// Sync members to Supabase
  Future<void> syncMembers(List<OrgMember> members) async {
    try {
      if (members.isEmpty) return;
      final data = members.map((m) => m.toSupabase()).toList();
      await client.from('org_members').upsert(data, onConflict: 'id');
      debugPrint('Synced ${members.length} members to Supabase');
    } catch (e) {
      debugPrint('Sync members error: $e');
    }
  }

  /// Get members from Supabase
  Future<List<OrgMember>> fetchMembers(String orgId) async {
    try {
      final response = await client
          .from('org_members')
          .select()
          .eq('org_id', orgId)
          .eq('is_active', true)
          .order('joined_at');

      return (response as List).map((m) => OrgMember.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Fetch members error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────
  // CONTRIBUTIONS
  // ─────────────────────────────────────────

  /// Sync contributions to Supabase
  Future<void> syncContributions(List<Contribution> contributions) async {
    try {
      if (contributions.isEmpty) return;
      final data = contributions.map((c) => c.toSupabase()).toList();
      await client.from('contributions').upsert(data, onConflict: 'id');
      debugPrint('Synced ${contributions.length} contributions');
    } catch (e) {
      debugPrint('Sync contributions error: $e');
    }
  }

  /// Get contributions from Supabase
  Future<List<Contribution>> fetchContributions(String orgId) async {
    try {
      final response = await client
          .from('contributions')
          .select()
          .eq('org_id', orgId)
          .order('date', ascending: false);

      return (response as List).map((c) => Contribution.fromMap(c)).toList();
    } catch (e) {
      debugPrint('Fetch contributions error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────
  // EXPENSES
  // ─────────────────────────────────────────

  /// Sync expenses to Supabase
  Future<void> syncExpenses(List<Expense> expenses) async {
    try {
      if (expenses.isEmpty) return;
      final data = expenses.map((e) => e.toSupabase()).toList();
      await client.from('expenses').upsert(data, onConflict: 'id');
      debugPrint('Synced ${expenses.length} expenses');
    } catch (e) {
      debugPrint('Sync expenses error: $e');
    }
  }

  /// Get expenses from Supabase
  Future<List<Expense>> fetchExpenses(String orgId) async {
    try {
      final response = await client
          .from('expenses')
          .select()
          .eq('org_id', orgId)
          .eq('is_active', true)
          .order('date', ascending: false);

      return (response as List).map((e) => Expense.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Fetch expenses error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────
  // LOANS
  // ─────────────────────────────────────────

  /// Sync loans to Supabase
  Future<void> syncLoans(List<Loan> loans) async {
    try {
      if (loans.isEmpty) return;
      final data = loans.map((l) => l.toSupabase()).toList();
      await client.from('loans').upsert(data, onConflict: 'id');
      debugPrint('Synced ${loans.length} loans');
    } catch (e) {
      debugPrint('Sync loans error: $e');
    }
  }

  /// Get loans from Supabase
  Future<List<Loan>> fetchLoans(String orgId) async {
    try {
      final response = await client
          .from('loans')
          .select()
          .eq('org_id', orgId)
          .order('application_date', ascending: false);

      return (response as List).map((l) => Loan.fromMap(l)).toList();
    } catch (e) {
      debugPrint('Fetch loans error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────
  // REAL-TIME SUBSCRIPTIONS
  // ─────────────────────────────────────────

  /// Subscribe to organization changes
  void subscribeToOrg(String orgId,
      Function(String event, Map<String, dynamic> data) callback) {
    client
        .channel('org:$orgId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'members',
          filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'org_id',
              value: orgId),
          callback: (payload) => callback('members', payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'contributions',
          filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'org_id',
              value: orgId),
          callback: (payload) => callback('contributions', payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'expenses',
          filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'org_id',
              value: orgId),
          callback: (payload) => callback('expenses', payload.newRecord),
        )
        .subscribe();
  }

  /// Unsubscribe from all channels
  void unsubscribeAll() {
    client.removeAllChannels();
  }

  // ─────────────────────────────────────────
  // EDGE FUNCTIONS
  // ─────────────────────────────────────────

  /// Call Supabase Edge Function
  Future<dynamic> callEdgeFunction({
    required String functionName,
    dynamic body,
  }) async {
    try {
      final response = await client.functions.invoke(
        functionName,
        body: body,
      );
      return response.data;
    } catch (e) {
      debugPrint('Edge function error ($functionName): $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────
  // STORAGE
  // ─────────────────────────────────────────

  /// Upload file to Supabase Storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
  }) async {
    try {
      await client.storage.from(bucket).uploadBinary(path, fileBytes);
      final publicUrl = client.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Upload file error: $e');
      rethrow;
    }
  }

  /// Delete file from storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await client.storage.from(bucket).remove([path]);
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────

  /// Normalize phone to 254XXXXXXXXX format
  static String _normalizePhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (clean.startsWith('254') && clean.length == 12) return clean;
    if (clean.startsWith('0') && clean.length == 10) {
      return '254${clean.substring(1)}';
    }
    if (clean.length == 9) return '254$clean';
    return clean;
  }

  static List<String> _phoneVariants(String phone) {
    final clean = phone.trim().replaceAll(RegExp(r'[\s\-\+]'), '');
    final normalized = _normalizePhone(clean);
    final last9 = normalized.length >= 9
        ? normalized.substring(normalized.length - 9)
        : normalized;
    final with0 = last9.length == 9 ? '0$last9' : clean;
    return {
      phone.trim(),
      clean,
      normalized,
      with0,
      last9,
    }.where((v) => v.isNotEmpty).toList();
  }
}
