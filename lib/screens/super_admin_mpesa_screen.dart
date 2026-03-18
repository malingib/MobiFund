import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class SuperAdminMpesaScreen extends StatefulWidget {
  const SuperAdminMpesaScreen({super.key});

  @override
  State<SuperAdminMpesaScreen> createState() => _SuperAdminMpesaScreenState();
}

class _SuperAdminMpesaScreenState extends State<SuperAdminMpesaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _consumerKey = TextEditingController();
  final _consumerSecret = TextEditingController();
  final _passkey = TextEditingController();
  final _shortcode = TextEditingController();
  String _env = 'sandbox';

  bool _saving = false;
  bool _obscure = true;

  @override
  void dispose() {
    _consumerKey.dispose();
    _consumerSecret.dispose();
    _passkey.dispose();
    _shortcode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<AppState>().setPlatformMpesaConfig(
            mpesaEnv: _env,
            consumerKey: _consumerKey.text.trim(),
            consumerSecret: _consumerSecret.text.trim(),
            passkey: _passkey.text.trim(),
            shortcode: _shortcode.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('M-Pesa configuration saved'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.isPlatformAdmin) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(title: const Text('M-Pesa (Super Admin)')),
        body: const Center(
          child: Text('Forbidden', style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('M-Pesa (Super Admin)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daraja Credentials',
                style: AppTheme.headline.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'These are stored encrypted in Supabase and used by the server-side STK push function.',
                style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _env,
                decoration: const InputDecoration(labelText: 'Environment'),
                items: const [
                  DropdownMenuItem(value: 'sandbox', child: Text('Sandbox')),
                  DropdownMenuItem(value: 'production', child: Text('Production')),
                ],
                onChanged: (v) => setState(() => _env = v ?? 'sandbox'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _consumerKey,
                decoration: const InputDecoration(labelText: 'Consumer Key'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _consumerSecret,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Consumer Secret',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passkey,
                obscureText: _obscure,
                decoration: const InputDecoration(labelText: 'Passkey'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _shortcode,
                decoration: const InputDecoration(labelText: 'Shortcode'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

