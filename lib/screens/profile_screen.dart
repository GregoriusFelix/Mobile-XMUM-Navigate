import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../models/campus_location.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../utils/firebase_errors.dart';
import '../widgets.dart';
import 'welcome_screen.dart';
import 'saved_locations_screen.dart';
import 'routes_history_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = FirebaseService();
  UserModel? _user;
  bool _loading = true;

  // Edit form controllers
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  String _selectedRole = 'Student';
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // READ — Fetch user profile from Firestore
  Future<void> _loadProfile() async {
    final uid = _service.currentUser?.uid;
    if (uid == null) return;
    final user = await _service.getUserProfile(uid);
    setState(() {
      _user = user;
      _loading = false;
      if (user != null) {
        _nameCtrl.text = user.name;
        _bioCtrl.text = user.bio;
        _phoneCtrl.text = user.phoneNumber ?? '';
        _emailCtrl.text = user.email;
        _selectedRole = user.role;
      }
    });
  }

  // UPDATE — Save edited profile fields to Firestore
  Future<void> _updateProfile() async {
    final uid = _service.currentUser?.uid;
    if (uid == null) return;
    try {
      String? profilePictureUrl = _user?.profilePictureUrl;

      // Upload new image if picked
      if (_pickedImage != null) {
        profilePictureUrl = await _service.uploadProfilePicture(uid, _pickedImage!);
      }

      await _service.updateUserProfile(uid, {
        'name': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'role': _selectedRole,
        'phoneNumber': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
      );
      _loadProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyFirebaseError(e)), backgroundColor: Colors.red),
      );
    }
  }

  // Pick profile image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // Update email with re-authentication
  Future<void> _updateEmail() async {
    if (_currentPasswordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your current password'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final user = _service.currentUser;
      if (user == null) return;

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordCtrl.text,
      );

      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(_emailCtrl.text.trim());

      await _service.updateUserProfile(user.uid, {'email': _emailCtrl.text.trim()});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email updated successfully. Please verify your new email.'), backgroundColor: Colors.green),
      );
      _loadProfile();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyFirebaseError(e)), backgroundColor: Colors.red),
      );
    }
  }

  // Update password with re-authentication
  Future<void> _updatePassword() async {
    if (_currentPasswordCtrl.text.isEmpty || _newPasswordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both current and new password'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final user = _service.currentUser;
      if (user == null) return;

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordCtrl.text,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordCtrl.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully'), backgroundColor: Colors.green),
      );
      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyFirebaseError(e)), backgroundColor: Colors.red),
      );
    }
  }

  int _getValidSavedLocationsCount() {
    final savedLocationIds = _user?.savedLocations ?? [];
    final validLocations = savedLocationIds
        .map((id) => CampusLocations.getLocationById(id))
        .where((location) => location != null)
        .toList();
    return validLocations.length;
  }

  // DELETE — Delete profile and sign out
  Future<void> _deleteAccount() async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(localizations.deleteAccount),
        content: const Text('This will permanently delete your profile. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(localizations.login)), // Using login as Cancel
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(localizations.deleteAccount, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final uid = _service.currentUser?.uid;
      if (uid != null) {
        await _service.deleteUserProfile(uid);
        await _service.logout();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (_) => false,
          );
        }
      }
    }
  }

  void _showEditSheet() {
    print('Edit Profile button pressed');
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: isDark ? kDarkCard : kWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(28, 28, 28, MediaQuery.of(sheetContext).viewInsets.bottom + 28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? kDarkText : kTextDark, letterSpacing: -0.6)),
                const SizedBox(height: 24),
                // Profile Image
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      await _pickImage();
                      setModalState(() {});
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: kMapGreen,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: kAccent.withValues(alpha: 0.5), width: 2),
                      ),
                      child: _pickedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(26),
                              child: Image.file(_pickedImage!, fit: BoxFit.cover),
                            )
                          : _user?.profilePictureUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(26),
                                  child: _user!.profilePictureUrl!.startsWith('data:')
                                      ? Image.memory(
                                          base64Decode(_user!.profilePictureUrl!.split(',').last),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Center(
                                            child: Text(
                                              _user?.name.isNotEmpty == true ? _user!.name[0].toUpperCase() : 'U',
                                              style: xmumFont(fontSize: 42, fontWeight: FontWeight.w800, color: kPrimary),
                                            ),
                                          ),
                                        )
                                      : Image.network(
                                          _user!.profilePictureUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Center(
                                            child: Text(
                                              _user?.name.isNotEmpty == true ? _user!.name[0].toUpperCase() : 'U',
                                              style: xmumFont(fontSize: 42, fontWeight: FontWeight.w800, color: kPrimary),
                                            ),
                                          ),
                                        ),
                                )
                              : Center(
                                  child: Text(
                                    _user?.name.isNotEmpty == true ? _user!.name[0].toUpperCase() : 'U',
                                    style: xmumFont(fontSize: 42, fontWeight: FontWeight.w800, color: kPrimary),
                                  ),
                                ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      await _pickImage();
                      setModalState(() {});
                    },
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Change Photo'),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  style: TextStyle(fontSize: 16, color: isDark ? kDarkText : kTextDark),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline, color: isDark ? kDarkTextMuted : kTextMuted),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioCtrl,
                  maxLines: 2,
                  style: TextStyle(fontSize: 16, color: isDark ? kDarkText : kTextDark),
                  decoration: InputDecoration(
                    labelText: 'Bio',
                    prefixIcon: Icon(Icons.info_outline, color: isDark ? kDarkTextMuted : kTextMuted),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 16, color: isDark ? kDarkText : kTextDark),
                  decoration: InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    prefixIcon: Icon(Icons.phone_outlined, color: isDark ? kDarkTextMuted : kTextMuted),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  style: TextStyle(fontSize: 16, color: isDark ? kDarkText : kTextDark),
                  items: ['Student', 'Parent', 'Visitor']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedRole = v!),
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.badge_outlined, color: isDark ? kDarkTextMuted : kTextMuted),
                  ),
                ),
                const SizedBox(height: 16),
                // Email Change Button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showEmailChangeSheet();
                  },
                  icon: const Icon(Icons.email_outlined, size: 18),
                  label: const Text('Change Email'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                // Password Change Button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showPasswordChangeSheet();
                  },
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: const Text('Change Password'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _updateProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kRadiusLg),
                    ),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEmailChangeSheet() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: isDark ? kDarkCard : kWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(28, 28, 28, MediaQuery.of(sheetContext).viewInsets.bottom + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change Email', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? kDarkText : kTextDark, letterSpacing: -0.6)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontSize: 16, color: isDark ? kDarkText : kTextDark),
              decoration: InputDecoration(
                labelText: 'New Email',
                prefixIcon: Icon(Icons.email_outlined, color: isDark ? kDarkTextMuted : kTextMuted),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentPasswordCtrl,
              obscureText: true,
              style: TextStyle(fontSize: 16, color: isDark ? kDarkText : kTextDark),
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline, color: isDark ? kDarkTextMuted : kTextMuted),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _updateEmail,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kRadiusLg),
                ),
              ),
              child: const Text('Update Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showPasswordChangeSheet() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: isDark ? kDarkCard : kWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(28, 28, 28, MediaQuery.of(sheetContext).viewInsets.bottom + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? kDarkText : kTextDark, letterSpacing: -0.6)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _currentPasswordCtrl,
              obscureText: true,
              style: TextStyle(fontSize: 16, color: isDark ? kDarkText : kTextDark),
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline, color: isDark ? kDarkTextMuted : kTextMuted),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordCtrl,
              obscureText: true,
              style: TextStyle(fontSize: 16, color: isDark ? kDarkText : kTextDark),
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_outline, color: isDark ? kDarkTextMuted : kTextMuted),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _updatePassword,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kRadiusLg),
                ),
              ),
              child: const Text('Update Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    
    if (_loading) return const Center(child: CircularProgressIndicator(color: kPrimary));

    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            XmumHeaderPattern(
              padding: const EdgeInsets.fromLTRB(24, 72, 24, 40),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: kAccent.withValues(alpha: 0.5), width: 2),
                      boxShadow: const [kGoldGlow, kMediumShadow],
                    ),
                    child: _user?.profilePictureUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: _user!.profilePictureUrl!.startsWith('data:')
                                ? Image.memory(
                                    base64Decode(_user!.profilePictureUrl!.split(',').last),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(
                                        _user?.name.isNotEmpty == true ? _user!.name[0].toUpperCase() : 'U',
                                        style: xmumFont(fontSize: 42, fontWeight: FontWeight.w800, color: kPrimary),
                                      ),
                                    ),
                                  )
                                : Image.network(
                                    _user!.profilePictureUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(
                                        _user?.name.isNotEmpty == true ? _user!.name[0].toUpperCase() : 'U',
                                        style: xmumFont(fontSize: 42, fontWeight: FontWeight.w800, color: kPrimary),
                                      ),
                                    ),
                                  ),
                          )
                        : Center(
                            child: Text(
                              _user?.name.isNotEmpty == true ? _user!.name[0].toUpperCase() : 'U',
                              style: xmumFont(fontSize: 42, fontWeight: FontWeight.w800, color: kPrimary),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(_user?.name ?? 'User',
                      style: xmumFont(color: kWhite, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
                  const SizedBox(height: 6),
                  Text(_user?.email ?? '',
                      style: xmumFont(color: kWhite.withValues(alpha: 0.85), fontSize: 14)),
                  const SizedBox(height: 12),
                  XmumBadge(
                    label: _user?.role ?? 'Student',
                    color: kAccent,
                    icon: Icons.verified_rounded,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bio
                  if (_user?.bio.isNotEmpty == true) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? kDarkCard : kWhite,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('About', style: TextStyle(fontSize: 14, color: isDark ? kDarkTextMuted : kTextMuted, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                          const SizedBox(height: 8),
                          Text(_user!.bio, style: TextStyle(fontSize: 15, color: isDark ? kDarkText : kTextDark, height: 1.6, fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Actions
                  XmumSectionTitle(title: 'Account', isDark: isDark),
                  const SizedBox(height: 12),
                  _settingsCard([
                    _tile(Icons.edit_outlined, 'Edit Profile', 'Update your details', onTap: _showEditSheet, isDark: isDark),
                    _tile(Icons.bookmark_outline, 'Saved Locations', '${_getValidSavedLocationsCount()} places saved', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedLocationsScreen())), isDark: isDark),
                    _tile(Icons.history, 'Routes History', 'View past routes', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoutesHistoryScreen())), isDark: isDark),
                  ], isDark: isDark),
                  const SizedBox(height: 24),
                  XmumSectionTitle(title: 'Support', isDark: isDark),
                  const SizedBox(height: 12),
                  _settingsCard([
                    _tile(Icons.help_outline, 'Help & FAQ', 'Get assistance', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())), isDark: isDark),
                    _tile(Icons.info_outline, 'About XMUM Navigate', 'v1.0.0', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())), isDark: isDark),
                  ], isDark: isDark),
                  const SizedBox(height: 24),

                  // Logout
                  GestureDetector(
                    onTap: () async {
                      await _service.logout();
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                          (_) => false,
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFE0E0)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Delete account
                  GestureDetector(
                    onTap: _deleteAccount,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Delete Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsCard(List<Widget> children, {required bool isDark}) {
    return Container(
      decoration: xmumPremiumCard(isDark: isDark),
      child: Column(children: children),
    );
  }

  Widget _tile(IconData icon, String title, String subtitle, {VoidCallback? onTap, required bool isDark}) {
    return InkWell(
      onTap: onTap,
      splashColor: kPrimary.withValues(alpha: 0.1),
      highlightColor: kPrimary.withValues(alpha: 0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isDark ? kDarkDivider : kDivider)),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: kPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: xmumFont(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? kDarkText : kTextDark)),
            const SizedBox(height: 4),
            Text(subtitle, style: xmumFont(fontSize: 13, color: isDark ? kDarkTextMuted : kTextMuted)),
          ])),
          Icon(Icons.chevron_right_rounded, color: isDark ? kDarkTextMuted : kTextMuted, size: 20),
        ]),
      ),
    );
  }
}
