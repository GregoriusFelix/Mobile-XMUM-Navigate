import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../config/social_auth_config.dart';
import '../models/user_model.dart';

/// Thrown when the user dismisses a social sign-in flow.
class SocialSignInCancelled implements Exception {}

class FirebaseService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: !kIsWeb && (Platform.isIOS || Platform.isMacOS)
        ? SocialAuthConfig.googleIosClientId
        : null,
    serverClientId: SocialAuthConfig.googleWebClientId,
  );

  bool get isAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ─── AUTH ────────────────────────────────────────────────

  Future<UserCredential?> register(String email, String password) async {
    _ensureAvailable();
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> login(String email, String password) async {
    _ensureAvailable();
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    _ensureAvailable();

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw SocialSignInCancelled();

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential?> signInWithApple() async {
    _ensureAvailable();

    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    final userCredential = await _auth.signInWithCredential(oauthCredential);

    // Apple only provides the display name on the first authorization.
    final displayName = _appleDisplayName(appleCredential);
    if (displayName != null && userCredential.user != null) {
      await userCredential.user!.updateDisplayName(displayName);
    }

    return userCredential;
  }

  Future<UserCredential?> signInWithFacebook() async {
    _ensureAvailable();

    if (!SocialAuthConfig.isFacebookConfigured) {
      throw StateError(
        'Facebook login is not configured. Set your App ID and Client Token in lib/config/social_auth_config.dart.',
      );
    }

    final result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    switch (result.status) {
      case LoginStatus.success:
        final accessToken = result.accessToken;
        if (accessToken == null) {
          throw FirebaseAuthException(
            code: 'invalid-credential',
            message: 'Facebook did not return an access token.',
          );
        }
        final credential = FacebookAuthProvider.credential(accessToken.tokenString);
        return await _auth.signInWithCredential(credential);
      case LoginStatus.cancelled:
        throw SocialSignInCancelled();
      case LoginStatus.failed:
        throw FirebaseAuthException(
          code: 'facebook-auth-failed',
          message: result.message ?? 'Facebook sign-in failed.',
        );
      case LoginStatus.operationInProgress:
        throw FirebaseAuthException(
          code: 'facebook-auth-in-progress',
          message: 'Facebook sign-in is already in progress.',
        );
    }
  }

  Future<void> ensureUserProfile(User firebaseUser) async {
    final existing = await getUserProfile(firebaseUser.uid);
    if (existing != null) return;

    final user = UserModel(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName?.trim().isNotEmpty == true
          ? firebaseUser.displayName!.trim()
          : _nameFromEmail(firebaseUser.email),
      email: firebaseUser.email ?? '',
      bio: '',
      role: 'Student',
      profilePictureUrl: firebaseUser.photoURL,
    );
    await createUserProfile(user);
  }

  Future<void> logout() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
      FacebookAuth.instance.logOut(),
    ]);
  }

  User? get currentUser => _auth.currentUser;

  // ─── CRUD: USER PROFILE ──────────────────────────────────

  Future<void> createUserProfile(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(uid, doc.data()!);
    }
    return null;
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> deleteUserProfile(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  // ─── SAVED LOCATIONS ───────────────────────────────────────

  Future<void> saveLocation(String uid, String locationId) async {
    final user = await getUserProfile(uid);
    if (user == null) return;

    final updatedLocations = [...user.savedLocations];
    if (!updatedLocations.contains(locationId)) {
      updatedLocations.add(locationId);
      await updateUserProfile(uid, {'savedLocations': updatedLocations});
    }
  }

  Future<void> unsaveLocation(String uid, String locationId) async {
    final user = await getUserProfile(uid);
    if (user == null) return;

    final updatedLocations = user.savedLocations.where((id) => id != locationId).toList();
    await updateUserProfile(uid, {'savedLocations': updatedLocations});
  }

  Future<bool> isLocationSaved(String uid, String locationId) async {
    final user = await getUserProfile(uid);
    return user?.savedLocations.contains(locationId) ?? false;
  }

  // ─── USER LOCATIONS (CRUD) ───────────────────────────────

  Future<String> addUserLocation(Map<String, dynamic> locationData) async {
    _ensureAvailable();
    final docRef = await _firestore.collection('user_locations').add(locationData);
    return docRef.id;
  }

  Future<void> updateUserLocation(String locationId, Map<String, dynamic> locationData) async {
    _ensureAvailable();
    await _firestore.collection('user_locations').doc(locationId).update(locationData);
  }

  Future<void> deleteUserLocation(String locationId) async {
    _ensureAvailable();
    await _firestore.collection('user_locations').doc(locationId).delete();
  }

  Future<List<Map<String, dynamic>>> getUserLocations(String uid) async {
    _ensureAvailable();
    final snapshot = await _firestore
        .collection('user_locations')
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<Map<String, dynamic>?> getUserLocationById(String locationId) async {
    _ensureAvailable();
    final doc = await _firestore.collection('user_locations').doc(locationId).get();
    if (!doc.exists) return null;
    
    final data = doc.data();
    if (data != null) {
      data['id'] = doc.id;
    }
    return data;
  }

  // ─── STORAGE: PROFILE PICTURES (BASE64 IN FIRESTORE) ───────────────────────────────

  Future<String?> uploadProfilePicture(String uid, File imageFile) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      
      // Resize image to reduce size (max 500x500)
      // Note: For production, you'd want proper image resizing
      // For now, we'll just compress the base64
      
      // Convert to base64
      final base64String = base64Encode(bytes);
      
      // Check size (Firestore limit is 1MB per document)
      // Base64 is ~33% larger than original
      if (base64String.length > 1000000) {
        throw Exception('Image is too large. Please choose a smaller image (max ~750KB).');
      }
      
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('Upload error: $e');
      rethrow;
    }
  }

  // ─── HELPERS ─────────────────────────────────────────────

  void _ensureAvailable() {
    if (!isAvailable) {
      throw StateError('Firebase is not initialized. Run flutterfire configure first.');
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String? _appleDisplayName(AuthorizationCredentialAppleID credential) {
    final givenName = credential.givenName?.trim();
    final familyName = credential.familyName?.trim();
    if (givenName == null && familyName == null) return null;
    return [givenName, familyName].whereType<String>().where((s) => s.isNotEmpty).join(' ');
  }

  String _nameFromEmail(String? email) {
    if (email == null || email.isEmpty) return 'User';
    final localPart = email.split('@').first;
    return localPart.isEmpty ? 'User' : localPart;
  }
}
