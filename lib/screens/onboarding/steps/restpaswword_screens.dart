import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/communiter_provider.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../router/app_router.dart';
import '../../../services/storage_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ResetPasswordScreen — ouverte via le deep link envoyé par
// AuthService.resetPassword() (io.supabase.flutter://reset-password/).
// À ce stade, supabase_flutter a déjà échangé le token du lien contre une
// session valide (évènement AuthChangeEvent.passwordRecovery) : il ne reste
// qu'à demander le nouveau mot de passe et l'appliquer.
// ─────────────────────────────────────────────────────────────────────────────
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordCtrl.text.trim();
    final confirm  = _confirmCtrl.text.trim();

    if (password.length < 6) {
      setState(() => _error = 'Le mot de passe doit contenir au moins 6 caractères.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Les mots de passe ne correspondent pas.');
      return;
    }

    setState(() { _submitting = true; _error = null; });
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );
      if (!mounted) return;

      // On a une session valide (recovery) : on la traite comme une
      // connexion normale et on rentre directement dans l'app.
      clearPasswordRecoveryRedirect();
      StorageService.setOnboardingCompleted(true);
      ref.read(userProfileProvider.notifier).reload();
      ref.invalidate(postsNotifierProvider);
      ref.invalidate(eventsNotifierProvider);
      ref.invalidate(partnersNotifierProvider);
      context.go('/');
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() { _error = e.message; _submitting = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Erreur : $e'; _submitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.lockKeyhole, color: cs.primary, size: 26),
              ),
              const SizedBox(height: 20),
              Text('Nouveau mot de passe',
                style: GoogleFonts.outfit(
                  fontSize: 24, fontWeight: FontWeight.w800, color: cs.onSurface)),
              const SizedBox(height: 8),
              Text(
                'Choisis un nouveau mot de passe pour ton compte.',
                style: GoogleFonts.inter(
                  fontSize: 13.5, color: cs.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 32),

              _PasswordField(
                controller: _passwordCtrl,
                hint: 'Nouveau mot de passe',
                obscure: _obscure1,
                onToggleObscure: () => setState(() => _obscure1 = !_obscure1),
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: 12),
              _PasswordField(
                controller: _confirmCtrl,
                hint: 'Confirmer le mot de passe',
                obscure: _obscure2,
                onToggleObscure: () => setState(() => _obscure2 = !_obscure2),
                onChanged: (_) => setState(() => _error = null),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                  style: GoogleFonts.inter(
                    fontSize: 12.5, fontWeight: FontWeight.w500, color: const Color(0xFFB00020))),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary),
                        )
                      : Text('Valider',
                          style: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final ValueChanged<String> onChanged;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggleObscure,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: cs.onSurface.withValues(alpha: 0.4), fontSize: 14),
        prefixIcon: Icon(LucideIcons.lock, color: cs.onSurface.withValues(alpha: 0.5), size: 19),
        suffixIcon: GestureDetector(
          onTap: onToggleObscure,
          child: Icon(
            obscure ? LucideIcons.eyeOff : LucideIcons.eye,
            color: cs.onSurface.withValues(alpha: 0.5), size: 19,
          ),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      ),
    );
  }
}
