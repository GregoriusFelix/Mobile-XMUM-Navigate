import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../utils/firebase_errors.dart';
import '../utils/firebase_status.dart';
import '../utils/network_diagnostics.dart';
import '../widgets.dart';
import '../widgets/social_auth_section.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  String _selectedRole = 'Student';
  bool _loading = false;
  bool _obscure = true;
  final _service = FirebaseService();

  final List<String> _roles = ['Student', 'Parent', 'Visitor'];

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!FirebaseStatus.ready) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FirebaseStatus.initError ??
                'Firebase is not ready. Restart the app after checking your connection.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final networkIssue = await NetworkDiagnostics.registrationBlockReason();
    if (networkIssue != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(networkIssue),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await _service.register(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      if (cred == null) return;

      final user = UserModel(
        uid: cred.user!.uid,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        role: _selectedRole,
      );

      try {
        await _service.createUserProfile(user);
      } catch (profileError) {
        await _service.logout();
        debugPrint('PROFILE ERROR: $profileError (${profileError.runtimeType})');
        rethrow;
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      debugPrint('REGISTER ERROR: $e (${e.runtimeType})');
      debugPrint('REGISTER DETAILS: ${firebaseErrorDetails(e)}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyFirebaseError(e)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _setLoading(bool value) async {
    if (mounted) setState(() => _loading = value);
  }

  Future<void> _socialSignIn(Future<UserCredential?> Function() signIn) {
    return handleSocialSignIn(
      context: context,
      service: _service,
      setLoading: _setLoading,
      signIn: signIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context);
    final isDark = themeProvider.isDark;
    
    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      body: Column(
        children: [
          XmumHeaderPattern(
            padding: const EdgeInsets.fromLTRB(24, 72, 24, 36),
            child: Column(
              children: [
                const XmumLogo(size: 80, showText: false),
                const SizedBox(height: 16),
                Text(
                  localizations.appName,
                  style: xmumFont(
                    color: kWhite,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Join the XMUM community',
                  style: xmumFont(color: kAccent, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 28),
                Container(
                  height: 50,
                  decoration: xmumGlassDecoration(opacity: 0.12),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          child: Container(
                            height: 42,
                            margin: const EdgeInsets.all(4),
                            child: Center(
                              child: Text(
                                localizations.login,
                                style: xmumFont(
                                  color: kWhite.withValues(alpha: 0.75),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 42,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [kSoftShadow],
                          ),
                          child: Center(
                            child: Text(
                              localizations.signup,
                              style: xmumFont(
                                color: kPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (FirebaseStatus.usingEmulator) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Dev mode: using local Firebase emulator',
                          style: TextStyle(fontSize: 11, color: kPrimary),
                        ),
                      ),
                    ],
                    if (!FirebaseStatus.ready) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          FirebaseStatus.initError ??
                              'Firebase is not connected. Registration will not work until Firebase is ready.',
                          style: const TextStyle(fontSize: 12, color: kTextDark, height: 1.4),
                        ),
                      ),
                    ],
                    Text("Let's Get Started!",
                        style: xmumFont(fontSize: 26, fontWeight: FontWeight.w800, color: isDark ? kDarkText : kTextDark, letterSpacing: -0.8)),
                    const SizedBox(height: 28),
                    _field(localizations.fullName, _nameCtrl, Icons.person_outline,
                        validator: (v) => v!.isEmpty ? 'Enter your name' : null),
                    const SizedBox(height: 20),
                    _field(localizations.email, _emailCtrl, Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.isEmpty ? 'Enter your email' : null),
                    const SizedBox(height: 20),
                    _field(localizations.password, _passwordCtrl, Icons.lock_outline,
                        obscure: _obscure,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 22, color: isDark ? kDarkTextMuted : kTextMuted),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (v) => v!.length < 6 ? 'Minimum 6 characters' : null),
                    const SizedBox(height: 20),
                    _field(localizations.bio, _bioCtrl, Icons.info_outline, maxLines: 2),
                    const SizedBox(height: 20),
                    // Role selector
                    Text('I am a...', style: TextStyle(fontSize: 13, color: isDark ? kDarkTextMuted : kTextMuted, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: _roles.map((role) {
                        final selected = _selectedRole == role;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedRole = role),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? kPrimary : (isDark ? kDarkCard : kWhite),
                                border: Border.all(
                                  color: selected ? kPrimary : (isDark ? kDarkDivider : kDivider),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(role,
                                  textAlign: TextAlign.center,
                                  style: xmumFont(
                                    color: selected ? kWhite : kTextMuted,
                                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 12,
                                  )),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    _loading
                        ? const Center(child: CircularProgressIndicator(color: kPrimary))
                        : ParkButton(
                            label: localizations.signup,
                            icon: Icons.person_add_rounded,
                            onPressed: _register,
                          ),
                    const SizedBox(height: 28),
                    SocialAuthSection(
                      loading: _loading,
                      isDark: isDark,
                      onGoogle: () => _socialSignIn(_service.signInWithGoogle),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(localizations.alreadyHaveAccount, style: TextStyle(color: isDark ? kDarkTextMuted : kTextMuted, fontSize: 14, fontWeight: FontWeight.w500)),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          child: Text(localizations.login, style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: -0.2)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {bool obscure = false, TextInputType? keyboardType, Widget? suffixIcon,
        String? Function(String?)? validator, int maxLines = 1}) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: isDark ? kDarkTextMuted : kTextMuted, fontWeight: FontWeight.w600, letterSpacing: -0.2)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(fontSize: 16, color: isDark ? kDarkText : kTextDark),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 22, color: isDark ? kDarkTextMuted : kTextMuted),
            suffixIcon: suffixIcon,
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: isDark ? kDarkTextMuted : const Color(0xFF94A3B8), fontSize: 15),
          ),
        ),
      ],
    );
  }
}
