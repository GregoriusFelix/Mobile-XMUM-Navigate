import 'package:firebase_auth/firebase_auth.dart';

import '../services/firebase_service.dart';

String friendlyFirebaseError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Enable it in Firebase Console → Authentication → Sign-in method.';
      case 'network-request-failed':
        return 'Cannot reach Firebase servers. Check your internet connection, try mobile data instead of campus WiFi, or use an Android emulator with Google Play Services.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'invalid-credential':
        return 'The supplied auth credential is incorrect, malformed or has expired. Please check your email and password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but a different sign-in method. Try signing in with email/password.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Sign-in was cancelled.';
      case 'facebook-auth-failed':
        return 'Facebook sign-in failed. Check your Facebook App ID and that Facebook login is enabled in Firebase Console.';
      case 'facebook-auth-in-progress':
        return 'Facebook sign-in is already in progress. Please wait.';
      default:
        return error.message ?? 'Authentication failed (${error.code}).';
    }
  }

  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return 'Profile could not be saved. Deploy Firestore rules that allow users to write their own profile (users/{userId}).';
      case 'unavailable':
        return 'Firebase is temporarily unavailable. Check your internet connection and try again.';
      case 'unauthenticated':
        return 'You are not signed in. Please log in and try again.';
      default:
        if (error.plugin == 'cloud_firestore') {
          return 'Could not save profile to Firestore (${error.code}).';
        }
        return error.message ?? 'Firebase error (${error.code}).';
    }
  }

  if (error is SocialSignInCancelled) {
    return 'Sign-in was cancelled.';
  }

  if (error is StateError) {
    final message = error.message;
    if (message.contains('Firebase is not initialized') ||
        message.contains('not configured')) {
      return 'Firebase is not configured. Run flutterfire configure in the project folder.';
    }
  }

  final message = error.toString();
  if (message.contains('FirebaseOptions') ||
      message.contains('YOUR_PROJECT_ID') ||
      message.contains('No Firebase App')) {
    return 'Firebase is not configured yet. Run flutterfire configure in the project folder.';
  }
  if (message.contains('PERMISSION_DENIED') ||
      message.contains('permission-denied')) {
    return 'Firestore access denied. Check your security rules in Firebase Console.';
  }
  if (message.contains('network') || message.contains('Network')) {
    return 'Network error. Check your internet connection and try again.';
  }

  return 'Something went wrong. Please try again.';
}

String firebaseErrorDetails(Object error) {
  if (error is FirebaseAuthException) {
    return 'Auth error: ${error.code}';
  }
  if (error is FirebaseException) {
    return '${error.plugin} error: ${error.code}';
  }
  return error.runtimeType.toString();
}
