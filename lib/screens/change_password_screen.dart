import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../services/firebase_service.dart';
import '../utils/firebase_errors.dart';
import '../widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _service = FirebaseService();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final localizations = AppLocalizations.of(context);

    if (_currentPasswordCtrl.text.isEmpty ||
        _newPasswordCtrl.text.isEmpty ||
        _confirmPasswordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseFillAllFields)),
      );
      return;
    }

    if (_newPasswordCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.passwordMinLength)),
      );
      return;
    }

    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.passwordsDoNotMatch)),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = _service.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordCtrl.text,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordCtrl.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.passwordUpdated)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyFirebaseError(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      appBar: AppBar(
        title: Text(localizations.changePassword, style: xmumFont(fontWeight: FontWeight.w700)),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: xmumPremiumGradient)),
        foregroundColor: kWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: xmumPremiumCard(isDark: isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.updateYourPassword,
                    style: xmumFont(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? kDarkText : kTextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.changePasswordHint,
                    style: xmumFont(
                      fontSize: 14,
                      color: isDark ? kDarkTextMuted : kTextMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildPasswordField(
                    controller: _currentPasswordCtrl,
                    label: localizations.currentPassword,
                    obscure: _obscureCurrent,
                    onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: _newPasswordCtrl,
                    label: localizations.newPassword,
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: _confirmPasswordCtrl,
                    label: localizations.confirmNewPassword,
                    obscure: _obscureConfirm,
                    onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 28),
                  ParkButton(
                    label: localizations.updatePassword,
                    icon: Icons.lock_reset_rounded,
                    onPressed: _loading ? null : _changePassword,
                  ),
                  if (_loading) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator(color: kPrimary)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: xmumFont(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? kDarkText : kTextDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: xmumFont(color: isDark ? kDarkText : kTextDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? kDarkSurface : kGreyLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kRadiusMd),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: isDark ? kDarkTextMuted : kTextMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
