import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../utils/firebase_errors.dart';
import '../widgets.dart';
import '../widgets/social_auth_section.dart';
import 'home_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _remember = false;
  final _service = FirebaseService();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final cred = await _service.login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      if (cred != null && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      debugPrint('LOGIN ERROR: $e (${e.runtimeType})');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyFirebaseError(e)),
            backgroundColor: kError,
          ),
        );
      }
    }
    setState(() => _loading = false);
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
                const _XmumLogoHero(),
                const SizedBox(height: 16),
                Text(
                  localizations.appName,
                  style: xmumFont(
                    color: kWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pursue Excellence, Strive for Perfection',
                  style: xmumFont(
                    color: kAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 28),
                _AuthSegmentedControl(
                  activeTab: 0,
                  loginLabel: localizations.login,
                  signupLabel: localizations.signup,
                  onSignupTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.welcome,
                      style: xmumFont(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: isDark ? kDarkText : kTextDark,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to access your campus companion',
                      style: xmumFont(
                        fontSize: 14,
                        color: isDark ? kDarkTextMuted : kTextMuted,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _FieldLabel(localizations.email, isDark: isDark),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? 'Enter your email' : null,
                      style: xmumFont(fontSize: 16, color: isDark ? kDarkText : kTextDark),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined, size: 22,
                            color: isDark ? kDarkTextMuted : kTextMuted),
                        hintText: 'Enter ${localizations.email}',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FieldLabel(localizations.password, isDark: isDark),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      validator: (v) => v!.isEmpty ? 'Enter your password' : null,
                      style: xmumFont(fontSize: 16, color: isDark ? kDarkText : kTextDark),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline, size: 22,
                            color: isDark ? kDarkTextMuted : kTextMuted),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            size: 22,
                            color: isDark ? kDarkTextMuted : kTextMuted,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        hintText: 'Enter ${localizations.password}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _remember,
                                onChanged: (v) => setState(() => _remember = v!),
                                activeColor: kPrimary,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me',
                              style: xmumFont(
                                fontSize: 13,
                                color: isDark ? kDarkTextMuted : kTextMuted,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          localizations.forgotPassword,
                          style: xmumFont(
                            fontSize: 13,
                            color: kPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _loading
                        ? const Center(child: CircularProgressIndicator(color: kPrimary))
                        : ParkButton(
                            label: localizations.login,
                            icon: Icons.login_rounded,
                            onPressed: _login,
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
                        Text(
                          localizations.dontHaveAccount,
                          style: xmumFont(
                            color: isDark ? kDarkTextMuted : kTextMuted,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                          ),
                          child: Text(
                            localizations.signup,
                            style: xmumFont(
                              color: kSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
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
}

class _XmumLogoHero extends StatelessWidget {
  const _XmumLogoHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [kGoldGlow, kMediumShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          'assets/images/xmum_navigate_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              gradient: xmumPremiumGradient,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.school_rounded, color: kWhite, size: 48),
          ),
        ),
      ),
    );
  }
}

class _AuthSegmentedControl extends StatelessWidget {
  final int activeTab;
  final String loginLabel;
  final String signupLabel;
  final VoidCallback onSignupTap;

  const _AuthSegmentedControl({
    required this.activeTab,
    required this.loginLabel,
    required this.signupLabel,
    required this.onSignupTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: xmumGlassDecoration(opacity: 0.12),
      child: Row(
        children: [
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
                  loginLabel,
                  style: xmumFont(
                    color: kPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onSignupTap,
              child: Container(
                height: 42,
                margin: const EdgeInsets.all(4),
                child: Center(
                  child: Text(
                    signupLabel,
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
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _FieldLabel(this.label, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: xmumFont(
        fontSize: 14,
        color: isDark ? kDarkTextMuted : kTextMuted,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
