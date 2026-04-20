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

  // Focus nodes for proper IME management - prevents focus loop crashes
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;

  final _supabase = SupabaseService();

  @override
  void initState() {
    super.initState();
    // Add focus listeners for debugging IME issues
    _emailFocus.addListener(_onEmailFocusChange);
    _passwordFocus.addListener(_onPasswordFocusChange);
    debugPrint('[LoginScreen] Initialized - focus nodes created');
  }

  void _onEmailFocusChange() {
    debugPrint('[LoginScreen] Email focus changed: ${_emailFocus.hasFocus}');
  }

  void _onPasswordFocusChange() {
    debugPrint(
        '[LoginScreen] Password focus changed: ${_passwordFocus.hasFocus}');
  }

  @override
  void dispose() {
    // Remove listeners and dispose focus nodes
    _emailFocus.removeListener(_onEmailFocusChange);
    _passwordFocus.removeListener(_onPasswordFocusChange);
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    debugPrint('[LoginScreen] Disposed - focus nodes cleaned up');
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
    // Show password reset dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PasswordResetDialog(
        supabaseService: _supabase,
      ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo
              Container(
                width: 140,
                height: 140,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo_mark.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              Image.asset(
                'assets/images/mobifund_logo.png',
                height: 50,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                'Group Finance Made Simple',
                style: AppTheme.body.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 48),

              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      focusNode:
                          _emailFocus, // Explicit focus node prevents IME loop
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        // Move to password field on submit
                        _passwordFocus.requestFocus();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'name@example.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        final value = v.trim();
                        final okEmail = RegExp(r'^.+@.+\..+$').hasMatch(value);
                        if (!okEmail) return 'Enter a valid email address';
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _passwordCtrl,
                      focusNode:
                          _passwordFocus, // Explicit focus node prevents IME loop
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        // Submit form when done
                        _login();
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
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

                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _forgotPassword,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppTheme.body,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// Password Reset Dialog
/// Guides users through SMS OTP-based password reset
class _PasswordResetDialog extends StatefulWidget {
  final SupabaseService supabaseService;

  const _PasswordResetDialog({required this.supabaseService});

  @override
  State<_PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<_PasswordResetDialog> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _isLoading = false;
  int _step = 1; // 1: Phone, 2: OTP, 3: New Password
  String? _errorMsg;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'Phone number is required');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.supabaseService.sendPasswordResetOtp(_phoneCtrl.text.trim());
      setState(() {
        _step = 2;
        _errorMsg = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent to your phone'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMsg = 'Failed to send OTP: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'OTP is required');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final verified = await widget.supabaseService.verifyPasswordResetOtp(
        _phoneCtrl.text.trim(),
        _otpCtrl.text.trim(),
      );

      if (!verified) {
        setState(() => _errorMsg = 'Invalid OTP or OTP expired');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _step = 3;
        _errorMsg = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP verified! Set your new password'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMsg = 'Verification failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_newPasswordCtrl.text.isEmpty) {
      setState(() => _errorMsg = 'New password is required');
      return;
    }
    if (_newPasswordCtrl.text.length < 6) {
      setState(() => _errorMsg = 'Password must be at least 6 characters');
      return;
    }
    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      setState(() => _errorMsg = 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // For now, we can't directly reset password without being logged in
      // Show contact support message
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Contact support with your phone number to complete password reset',
            ),
            backgroundColor: AppTheme.warning,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMsg = 'Password reset failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        _step == 1
            ? 'Reset Password'
            : _step == 2
                ? 'Verify OTP'
                : 'Set New Password',
        style: AppTheme.headline,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_step == 1) ...[
              Text(
                'Enter your phone number to receive a password reset code',
                style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '0712 345 678',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                enabled: !_isLoading,
              ),
            ] else if (_step == 2) ...[
              Text(
                'Enter the OTP sent to +${_phoneCtrl.text}',
                style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _otpCtrl,
                decoration: const InputDecoration(
                  labelText: 'OTP Code',
                  hintText: '123456',
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
                ),
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
              ),
            ] else ...[
              Text(
                'Set your new password',
                style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPasswordCtrl,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordCtrl,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                enabled: !_isLoading,
              ),
            ],
            if (_errorMsg != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMsg!,
                  style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : (_step == 1
                  ? _sendOtp
                  : _step == 2
                      ? _verifyOtp
                      : _resetPassword),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  _step == 1
                      ? 'Send OTP'
                      : _step == 2
                          ? 'Verify'
                          : 'Reset Password',
                ),
        ),
      ],
    );
  }
}
