/// OAuth provider configuration for social sign-in.
///
/// Google client IDs are auto-populated from the Firebase project.
/// Facebook credentials must be set after creating an app at
/// https://developers.facebook.com — also update the matching values in
/// `android/app/src/main/res/values/strings.xml` and `ios/Runner/Info.plist`.
class SocialAuthConfig {
  SocialAuthConfig._();

  /// Web client ID (type 3) — required for Google Sign-In on Android.
  static const String googleWebClientId =
      '616222590394-6pr5pbtmkkk0ph5okj4dbt6dq72a94ar.apps.googleusercontent.com';

  /// iOS client ID from Firebase / Google Cloud Console.
  static const String googleIosClientId =
      '616222590394-qq4rgjuj0auvv936is831jnlhh9pkadv.apps.googleusercontent.com';

  /// Facebook App ID — replace with your real value from Meta Developer Console.
  static const String facebookAppId = 'YOUR_FACEBOOK_APP_ID';

  /// Facebook Client Token — replace with your real value from Meta Developer Console.
  static const String facebookClientToken = 'YOUR_FACEBOOK_CLIENT_TOKEN';

  static bool get isFacebookConfigured =>
      facebookAppId.isNotEmpty &&
      facebookAppId != 'YOUR_FACEBOOK_APP_ID' &&
      facebookClientToken.isNotEmpty &&
      facebookClientToken != 'YOUR_FACEBOOK_CLIENT_TOKEN';
}
