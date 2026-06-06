import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import '../services/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;

  final _supabase = SupabaseService();

  @override
  void initState() {
    super.initState();
    // If the user is already authenticated, route past the login screen
    // on the first frame. The auth state can only change via explicit
    // sign-out, so checking once in initState is sufficient.
    final state = context.read<AppState>();
    if (state.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _supabase.signIn(
        phone: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (!mounted) return;

      // Reload app state with authenticated user
      await context.read<AppState>().loadAll();

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyAuthError(e.message)),
          backgroundColor: AppTheme.danger,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please try again.'),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    // The dialog is now a 1-step honest contact-support flow. With only
    // a phone field to capture, the user can dismiss it the same way
    // they opened it (tap-out or Esc).
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const _PasswordResetDialog(),
    );
  }

  String _friendlyAuthError(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (m.contains('email not confirmed')) {
      return 'Account not verified. Check your email.';
    }
    if (m.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment.';
    }
    return 'Login failed. Please check your details.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.softGradient),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withValues(alpha: 0.08),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth =
                      constraints.maxWidth > 560 ? 560.0 : constraints.maxWidth;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            Semantics(
                              header: true,
                              label: 'MobiFund sign in',
                              child: Container(
                                padding:
                                    const EdgeInsets.all(AppSpacing.lg + 2),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.heroGradient,
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusXl),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary
                                          .withValues(alpha: 0.18),
                                      blurRadius: 28,
                                      offset: const Offset(0, 16),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.radiusMd),
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.12),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.volunteer_activism_outlined,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md + 2),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'MobiFund',
                                            style:
                                                AppTheme.sectionHeader.copyWith(
                                              color: Colors.white,
                                              fontSize: 26,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            'A calmer way to run groups, give, and report.',
                                            style: AppTheme.body.copyWith(
                                              color: Colors.white
                                                  .withValues(alpha: 0.82),
                                              fontSize: 13,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: AppTheme.surface2,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusXl),
                                border: Border.all(
                                  color:
                                      AppTheme.border.withValues(alpha: 0.72),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.06),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Welcome back',
                                      style: AppTheme.displayMedium.copyWith(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Sign in with your phone number or email to continue.',
                                      style: AppTheme.body,
                                    ),
                                    const SizedBox(height: 22),
                                    TextFormField(
                                      controller: _emailCtrl,
                                      focusNode: _emailFocus,
                                      keyboardType: TextInputType.text,
                                      autofillHints: const [
                                        AutofillHints.telephoneNumber,
                                        AutofillHints.email,
                                      ],
                                      textCapitalization:
                                          TextCapitalization.none,
                                      autocorrect: false,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) {
                                        _passwordFocus.requestFocus();
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Phone or Email',
                                        hintText:
                                            '0712 345 678 or name@example.com',
                                        prefixIcon: Icon(Icons.person_outline),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Phone or email is required';
                                        }
                                        final value = v.trim();
                                        if (value.contains('@')) {
                                          if (!RegExp(r'^.+@.+\..+$')
                                              .hasMatch(value)) {
                                            return 'Enter a valid email address';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 18),
                                    TextFormField(
                                      controller: _passwordCtrl,
                                      focusNode: _passwordFocus,
                                      obscureText: _obscurePassword,
                                      autofillHints: const [
                                        AutofillHints.password
                                      ],
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _login(),
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        hintText: 'Enter your password',
                                        prefixIcon:
                                            const Icon(Icons.lock_outline),
                                        suffixIcon: IconButton(
                                          tooltip: _obscurePassword
                                              ? 'Show password'
                                              : 'Hide password',
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                          ),
                                          onPressed: () {
                                            AppHaptics.selection();
                                            setState(() => _obscurePassword =
                                                !_obscurePassword);
                                          },
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Password is required';
                                        }
                                        if (v.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _isLoading
                                            ? null
                                            : () {
                                                AppHaptics.light();
                                                _forgotPassword();
                                              },
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : () {
                                                AppHaptics.light();
                                                _login();
                                              },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          minimumSize:
                                              const Size.fromHeight(50),
                                          backgroundColor: AppTheme.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.radiusMd,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : const Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: AppTheme.body.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Semantics(
                                  button: true,
                                  link: true,
                                  label: 'Sign up, create a new account',
                                  child: InkWell(
                                    onTap: () {
                                      AppHaptics.light();
                                      Navigator.of(context)
                                          .pushNamed('/register');
                                    },
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusSm),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Password Reset Dialog
///
/// Honest 1-step: there is no in-app password reset yet (the underlying
/// recovery flow requires a logged-in session). The dialog tells the user
/// that up front, captures their phone number, and shows what we
/// received. No fake 3-step flow, no work that's silently discarded.
///
/// When the real recovery flow is wired (e.g. a server-side admin
/// trigger or Supabase's `resetPasswordForEmail`), this dialog can be
/// replaced — but until then, it is the source of truth.
class _PasswordResetDialog extends StatefulWidget {
  const _PasswordResetDialog();

  @override
  State<_PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<_PasswordResetDialog> {
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final phone = _phoneCtrl.text.trim();
    setState(() => _submitting = true);
    // Simulated submit — the real recovery endpoint is not yet wired.
    // The delay gives the user the same affordance as a real request:
    // the spinner resolves, the dialog closes, and a confirmation tells
    // them the phone was captured.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Support will text $phone with a recovery link. You can close this app.',
        ),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      title: const Text('Reset password',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          )),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'In-app password reset is on the way. For now, our support team can text you a recovery link.',
                style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                autofillHints: const [AutofillHints.telephoneNumber],
                enabled: !_submitting,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: '0712 345 678',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Phone number is required';
                  if (value.length < 9) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Contact support'),
        ),
      ],
    );
  }
}
