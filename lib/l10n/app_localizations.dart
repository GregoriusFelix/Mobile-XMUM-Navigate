import 'package:flutter/material.dart';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  final Locale locale;

  AppLocalizations(this.locale);

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'XMUM Navigate',
      'home': 'Home',
      'explore': 'Explore',
      'navigate': 'Navigate',
      'help': 'Help',
      'account': 'Account',
      'profile': 'Profile',
      'settings': 'Settings',
      'notifications': 'Notifications',
      'locationServices': 'Location Services',
      'darkMode': 'Dark Mode',
      'language': 'Language',
      'changePassword': 'Change Password',
      'privacyPolicy': 'Privacy Policy',
      'dataStorage': 'Data & Storage',
      'about': 'About',
      'logout': 'Logout',
      'deleteAccount': 'Delete Account',
      'campusAlerts': 'Campus alerts and reminders',
      'requiredForNavigation': 'Required for navigation',
      'switchToDarkTheme': 'Switch to dark theme',
      'updateYourPassword': 'Update your password',
      'howWeUseYourData': 'How we use your data',
      'manageCachedData': 'Manage cached data',
      'getAnswersToCommonQuestions': 'Get answers to common questions',
      'version': 'Version 1.0.0',
      'map': 'Map',
      'food': 'Food',
      'venues': 'Venues',
      'navigateCampus': 'Navigate Campus',
      'canteen': 'Canteen',
      'open': 'Open',
      'closed': 'Closed',
      'rating': 'Rating',
      'distance': 'Distance',
      'priceRange': 'Price Range',
      'menu': 'Menu',
      'popularItems': 'Popular Items',
      'operatingHours': 'Operating Hours',
      'call': 'Call',
      'currentlyOpen': 'Currently Open',
      'currentlyClosed': 'Currently Closed',
      'navigationStarted': 'Navigation started!',
      'callPlaced': 'Call placed!',
      'editProfile': 'Edit Profile',
      'updateYourInformation': 'Update your information',
      'academicInfo': 'Academic Info',
      'viewYourAcademicDetails': 'View your academic details',
      'activityHistory': 'Activity History',
      'viewYourRecentActivities': 'View your recent activities',
      'signOut': 'Sign Out',
      'helpAndFAQ': 'Help & FAQ',
      'getAssistance': 'Get assistance',
      'aboutXMUMNavigate': 'About XMUM Navigate',
      'needHelp': 'Need help?',
      'browseOurFAQs': 'Browse our FAQs or send us a message below.',
      'frequentlyAskedQuestions': 'Frequently Asked Questions',
      'sendUsAMessage': 'Send Us a Message',
      'describeYourIssue': 'Describe your issue or question...',
      'sendMessage': 'Send Message',
      'messageSent': 'Message sent! We\'ll get back to you soon.',
      'supportEmail': 'support@xmumnavigate.com',
      'supportPhone': '+60 3-8966 xxxx',
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',
      'confirmNewPassword': 'Confirm New Password',
      'updatePassword': 'Update Password',
      'passwordUpdated': 'Password updated successfully!',
      'pleaseFillAllFields': 'Please fill in all fields',
      'passwordMinLength': 'Password must be at least 6 characters',
      'passwordsDoNotMatch': 'New passwords do not match',
      'welcome': 'Welcome',
      'login': 'Login',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'forgotPassword': 'Forgot Password?',
      'dontHaveAccount': 'Don\'t have an account?',
      'alreadyHaveAccount': 'Already have an account?',
      'createAccount': 'Create Account',
      'fullName': 'Full Name',
      'role': 'Role',
      'student': 'Student',
      'staff': 'Staff',
      'bio': 'Bio',
      'tellUsAboutYourself': 'Tell us about yourself',
      'register': 'Register',
      'loginSuccess': 'Login successful!',
      'registrationSuccess': 'Registration successful!',
      'hi': 'Hi',
      'wallet': 'Wallet',
      'balance': 'Balance',
      'goNow': 'Go Now',
      'history': 'History',
      'services': 'Services',
      'campusMap': 'Campus Map',
      'library': 'Library',
      'transport': 'Transport',
      'facilities': 'Facilities',
      'capacity': 'Capacity',
      'type': 'Type',
      'location': 'Location',
      'availableForBooking': 'Available for Booking',
      'currentlyBooked': 'Currently Booked',
      'viewOnMap': 'View on Map',
      'bookVenue': 'Book Venue',
      'bookingRequestSent': 'Booking request sent!',
      'availableFacilities': 'Available Facilities',
      'from': 'From',
      'to': 'To',
      'duration': 'Duration',
      'getDirections': 'Get Directions',
      'selectLocation': 'Select Location',
      'searchBuildings': 'Search buildings...',
      'search': 'Search',
      'all': 'All',
      'appPreferences': 'App Preferences',
      'languageAndRegion': 'Language & Region',
      'privacyAndSecurity': 'Privacy & Security',
      'support': 'Support',
      'aiAssistant': 'AI Assistant',
      'aiAssistantTitle': 'XMUM AI Assistant',
      'aiAssistantSubtitle': 'Ask questions about campus',
      'notificationsEnabled': 'Campus alerts enabled',
      'notificationsDisabled': 'Campus alerts disabled',
      'locationEnabled': 'Location services enabled',
      'locationDisabled': 'Location services disabled. Navigation may be limited.',
      'cancel': 'Cancel',
      'aboutDescription': 'Your premium campus companion for Xiamen University Malaysia. Navigate buildings, discover dining, and explore campus life with ease.',
      'aboutUniversity': 'University',
      'aboutCopyright': '© 2026 XMUM Navigate. All rights reserved.',
      'privacyIntro': 'XMUM Navigate respects your privacy. This policy explains how we collect, use, and protect your information.',
      'privacyDataCollection': 'Data We Collect',
      'privacyDataCollectionBody': 'We collect your email, name, and profile information when you create an account. Location data is only used when you enable location services for campus navigation.',
      'privacyDataUsage': 'How We Use Data',
      'privacyDataUsageBody': 'Your data is used to personalize your campus experience, provide navigation services, and send campus alerts when notifications are enabled.',
      'privacyDataSharing': 'Data Sharing',
      'privacyDataSharingBody': 'We do not sell your personal data. Information is only shared with Firebase services for authentication and data storage, as required to operate the app.',
      'privacyYourRights': 'Your Rights',
      'privacyYourRightsBody': 'You can update your profile, change your password, or delete your account at any time from the Profile screen.',
      'privacySecurity': 'Security',
      'privacySecurityBody': 'We use Firebase Authentication with encrypted connections. Passwords are never stored in plain text.',
      'cachedData': 'Cached Data',
      'cacheDescription': 'App preferences and cached data stored on your device.',
      'clearCache': 'Clear Cache',
      'clearCacheConfirm': 'This will clear cached data while keeping your preferences. Continue?',
      'cacheCleared': 'Cache cleared successfully',
      'getStarted': 'Get Started',
      'continue_': 'Continue',
      'skip': 'Skip',
      'discoverCampus': 'Discover Campus',
      'discoverCampusSubtitle': 'Find buildings, facilities & services around XMUM',
      'interactiveMap': 'Interactive Map',
      'interactiveMapSubtitle': 'Explore the full XMUM campus with live navigation',
      'smartDirections': 'Smart Directions',
      'smartDirectionsSubtitle': 'Get walking routes to any destination on campus',
      'changePasswordHint': 'Enter your current password and choose a new one',
    },
    'ms': {
      'appName': 'XMUM Navigate',
      'home': 'Utama',
      'explore': 'Terokai',
      'navigate': 'Navigasi',
      'help': 'Bantuan',
      'account': 'Akaun',
      'profile': 'Profil',
      'settings': 'Tetapan',
      'notifications': 'Notifikasi',
      'locationServices': 'Perkhidmatan Lokasi',
      'darkMode': 'Mod Gelap',
      'language': 'Bahasa',
      'changePassword': 'Tukar Kata Laluan',
      'privacyPolicy': 'Dasar Privasi',
      'dataStorage': 'Data & Penyimpanan',
      'about': 'Perihal',
      'logout': 'Log Keluar',
      'deleteAccount': 'Hapus Akaun',
      'campusAlerts': 'Amaran dan peringatan kampus',
      'requiredForNavigation': 'Diperlukan untuk navigasi',
      'switchToDarkTheme': 'Tukar ke tema gelap',
      'updateYourPassword': 'Kemaskini kata laluan anda',
      'howWeUseYourData': 'Bagaimana kami menggunakan data anda',
      'manageCachedData': 'Urus data cache',
      'getAnswersToCommonQuestions': 'Dapatkan jawapan kepada soalan lazim',
      'version': 'Versi 1.0.0',
      'map': 'Peta',
      'food': 'Makanan',
      'venues': 'Tempat',
      'navigateCampus': 'Navigasi Kampus',
      'canteen': 'Kantin',
      'open': 'Buka',
      'closed': 'Tutup',
      'rating': 'Penilaian',
      'distance': 'Jarak',
      'priceRange': 'Julat Harga',
      'menu': 'Menu',
      'popularItems': 'Item Popular',
      'operatingHours': 'Waktu Operasi',
      'call': 'Hubungi',
      'currentlyOpen': 'Sedang Buka',
      'currentlyClosed': 'Sedang Tutup',
      'navigationStarted': 'Navigasi bermula!',
      'callPlaced': 'Panggilan dibuat!',
      'editProfile': 'Edit Profil',
      'updateYourInformation': 'Kemaskini maklumat anda',
      'academicInfo': 'Maklumat Akademik',
      'viewYourAcademicDetails': 'Lihat butiran akademik anda',
      'activityHistory': 'Sejarah Aktiviti',
      'viewYourRecentActivities': 'Lihat aktiviti terkini anda',
      'signOut': 'Log Keluar',
      'helpAndFAQ': 'Bantuan & Soalan Lazim',
      'getAssistance': 'Dapatkan bantuan',
      'aboutXMUMNavigate': 'Perihal XMUM Navigate',
      'needHelp': 'Perlukan bantuan?',
      'browseOurFAQs': 'Lihat soalan lazim kami atau hantar mesej di bawah.',
      'frequentlyAskedQuestions': 'Soalan Lazim',
      'sendUsAMessage': 'Hantar Mesej',
      'describeYourIssue': 'Huraikan isu atau soalan anda...',
      'sendMessage': 'Hantar Mesej',
      'messageSent': 'Mesej dihantar! Kami akan menghubungi anda tidak lama lagi.',
      'supportEmail': 'support@xmumnavigate.com',
      'supportPhone': '+60 3-8966 xxxx',
      'currentPassword': 'Kata Laluan Semasa',
      'newPassword': 'Kata Laluan Baru',
      'confirmNewPassword': 'Sahkan Kata Laluan Baru',
      'updatePassword': 'Kemaskini Kata Laluan',
      'passwordUpdated': 'Kata laluan berjaya dikemaskini!',
      'pleaseFillAllFields': 'Sila isi semua ruangan',
      'passwordMinLength': 'Kata laluan mesti sekurang-kurangnya 6 aksara',
      'passwordsDoNotMatch': 'Kata laluan baru tidak sepadan',
      'welcome': 'Selamat Datang',
      'login': 'Log Masuk',
      'signup': 'Daftar',
      'email': 'E-mel',
      'password': 'Kata Laluan',
      'forgotPassword': 'Lupa Kata Laluan?',
      'dontHaveAccount': 'Tiada akaun?',
      'alreadyHaveAccount': 'Sudah mempunyai akaun?',
      'createAccount': 'Cipta Akaun',
      'fullName': 'Nama Penuh',
      'role': 'Peranan',
      'student': 'Pelajar',
      'staff': 'Kakitangan',
      'bio': 'Bio',
      'tellUsAboutYourself': 'Beritahu kami tentang diri anda',
      'register': 'Daftar',
      'loginSuccess': 'Log masuk berjaya!',
      'registrationSuccess': 'Pendaftaran berjaya!',
      'hi': 'Hai',
      'wallet': 'Dompet',
      'balance': 'Baki',
      'goNow': 'Pergi Sekarang',
      'history': 'Sejarah',
      'services': 'Perkhidmatan',
      'campusMap': 'Peta Kampus',
      'library': 'Perpustakaan',
      'transport': 'Pengangkutan',
      'facilities': 'Kemudahan',
      'capacity': 'Kapasiti',
      'type': 'Jenis',
      'location': 'Lokasi',
      'availableForBooking': 'Tersedia untuk Tempahan',
      'currentlyBooked': 'Sedang Ditempah',
      'viewOnMap': 'Lihat di Peta',
      'bookVenue': 'Tempah Tempat',
      'bookingRequestSent': 'Permintaan tempahan dihantar!',
      'availableFacilities': 'Kemudahan Tersedia',
      'from': 'Dari',
      'to': 'Ke',
      'duration': 'Tempoh',
      'getDirections': 'Dapatkan Arah',
      'selectLocation': 'Pilih Lokasi',
      'searchBuildings': 'Cari bangunan...',
      'search': 'Cari',
      'all': 'Semua',
      'appPreferences': 'Keutamaan Aplikasi',
      'languageAndRegion': 'Bahasa & Kawasan',
      'privacyAndSecurity': 'Privasi & Keselamatan',
      'support': 'Sokongan',
      'aiAssistant': 'Pembantu AI',
      'aiAssistantTitle': 'Pembantu AI XMUM',
      'aiAssistantSubtitle': 'Tanya soalan tentang kampus',
      'notificationsEnabled': 'Amaran kampus diaktifkan',
      'notificationsDisabled': 'Amaran kampus dinyahaktifkan',
      'locationEnabled': 'Perkhidmatan lokasi diaktifkan',
      'locationDisabled': 'Perkhidmatan lokasi dinyahaktifkan. Navigasi mungkin terhad.',
      'cancel': 'Batal',
      'aboutDescription': 'Rakan kampus premium anda untuk Universiti Xiamen Malaysia. Navigasi bangunan, temui tempat makan, dan terokai kehidupan kampus dengan mudah.',
      'aboutUniversity': 'Universiti',
      'aboutCopyright': '© 2026 XMUM Navigate. Hak cipta terpelihara.',
      'privacyIntro': 'XMUM Navigate menghormati privasi anda. Dasar ini menerangkan bagaimana kami mengumpul, menggunakan, dan melindungi maklumat anda.',
      'privacyDataCollection': 'Data Yang Kami Kumpul',
      'privacyDataCollectionBody': 'Kami mengumpul e-mel, nama, dan maklumat profil anda semasa anda membuat akaun. Data lokasi hanya digunakan apabila anda mengaktifkan perkhidmatan lokasi untuk navigasi kampus.',
      'privacyDataUsage': 'Cara Kami Menggunakan Data',
      'privacyDataUsageBody': 'Data anda digunakan untuk memperibadikan pengalaman kampus, menyediakan perkhidmatan navigasi, dan menghantar amaran kampus apabila notifikasi diaktifkan.',
      'privacyDataSharing': 'Perkongsian Data',
      'privacyDataSharingBody': 'Kami tidak menjual data peribadi anda. Maklumat hanya dikongsi dengan perkhidmatan Firebase untuk pengesahan dan penyimpanan data.',
      'privacyYourRights': 'Hak Anda',
      'privacyYourRightsBody': 'Anda boleh mengemas kini profil, menukar kata laluan, atau memadam akaun anda pada bila-bila masa dari skrin Profil.',
      'privacySecurity': 'Keselamatan',
      'privacySecurityBody': 'Kami menggunakan Firebase Authentication dengan sambungan disulitkan. Kata laluan tidak pernah disimpan dalam teks biasa.',
      'cachedData': 'Data Cache',
      'cacheDescription': 'Keutamaan aplikasi dan data cache yang disimpan pada peranti anda.',
      'clearCache': 'Kosongkan Cache',
      'clearCacheConfirm': 'Ini akan mengosongkan data cache sambil mengekalkan keutamaan anda. Teruskan?',
      'cacheCleared': 'Cache berjaya dikosongkan',
      'getStarted': 'Mula Sekarang',
      'continue_': 'Teruskan',
      'skip': 'Langkau',
      'discoverCampus': 'Terokai Kampus',
      'discoverCampusSubtitle': 'Cari bangunan, kemudahan & perkhidmatan di sekitar XMUM',
      'interactiveMap': 'Peta Interaktif',
      'interactiveMapSubtitle': 'Terokai keseluruhan kampus XMUM dengan navigasi langsung',
      'smartDirections': 'Arah Pintar',
      'smartDirectionsSubtitle': 'Dapatkan laluan berjalan kaki ke mana-mana destinasi di kampus',
      'changePasswordHint': 'Masukkan kata laluan semasa anda dan pilih yang baharu',
    },
  };

  Map<String, String> get _strings => _localizedValues[locale.languageCode] ?? _localizedValues['en']!;

  String get appName => _strings['appName'] ?? 'XMUM Navigate';
  String get home => _strings['home'] ?? 'Home';
  String get explore => _strings['explore'] ?? 'Explore';
  String get navigate => _strings['navigate'] ?? 'Navigate';
  String get help => _strings['help'] ?? 'Help';
  String get account => _strings['account'] ?? 'Account';
  String get profile => _strings['profile'] ?? 'Profile';
  String get settings => _strings['settings'] ?? 'Settings';
  String get notifications => _strings['notifications'] ?? 'Notifications';
  String get locationServices => _strings['locationServices'] ?? 'Location Services';
  String get darkMode => _strings['darkMode'] ?? 'Dark Mode';
  String get language => _strings['language'] ?? 'Language';
  String get changePassword => _strings['changePassword'] ?? 'Change Password';
  String get privacyPolicy => _strings['privacyPolicy'] ?? 'Privacy Policy';
  String get dataStorage => _strings['dataStorage'] ?? 'Data & Storage';
  String get about => _strings['about'] ?? 'About';
  String get logout => _strings['logout'] ?? 'Logout';
  String get deleteAccount => _strings['deleteAccount'] ?? 'Delete Account';
  String get campusAlerts => _strings['campusAlerts'] ?? 'Campus alerts and reminders';
  String get requiredForNavigation => _strings['requiredForNavigation'] ?? 'Required for navigation';
  String get switchToDarkTheme => _strings['switchToDarkTheme'] ?? 'Switch to dark theme';
  String get updateYourPassword => _strings['updateYourPassword'] ?? 'Update your password';
  String get howWeUseYourData => _strings['howWeUseYourData'] ?? 'How we use your data';
  String get manageCachedData => _strings['manageCachedData'] ?? 'Manage cached data';
  String get getAnswersToCommonQuestions => _strings['getAnswersToCommonQuestions'] ?? 'Get answers to common questions';
  String get version => _strings['version'] ?? 'Version 1.0.0';
  String get map => _strings['map'] ?? 'Map';
  String get food => _strings['food'] ?? 'Food';
  String get venues => _strings['venues'] ?? 'Venues';
  String get navigateCampus => _strings['navigateCampus'] ?? 'Navigate Campus';
  String get canteen => _strings['canteen'] ?? 'Canteen';
  String get open => _strings['open'] ?? 'Open';
  String get closed => _strings['closed'] ?? 'Closed';
  String get rating => _strings['rating'] ?? 'Rating';
  String get distance => _strings['distance'] ?? 'Distance';
  String get priceRange => _strings['priceRange'] ?? 'Price Range';
  String get menu => _strings['menu'] ?? 'Menu';
  String get popularItems => _strings['popularItems'] ?? 'Popular Items';
  String get operatingHours => _strings['operatingHours'] ?? 'Operating Hours';
  String get call => _strings['call'] ?? 'Call';
  String get currentlyOpen => _strings['currentlyOpen'] ?? 'Currently Open';
  String get currentlyClosed => _strings['currentlyClosed'] ?? 'Currently Closed';
  String get navigationStarted => _strings['navigationStarted'] ?? 'Navigation started!';
  String get callPlaced => _strings['callPlaced'] ?? 'Call placed!';
  String get editProfile => _strings['editProfile'] ?? 'Edit Profile';
  String get updateYourInformation => _strings['updateYourInformation'] ?? 'Update your information';
  String get academicInfo => _strings['academicInfo'] ?? 'Academic Info';
  String get viewYourAcademicDetails => _strings['viewYourAcademicDetails'] ?? 'View your academic details';
  String get activityHistory => _strings['activityHistory'] ?? 'Activity History';
  String get viewYourRecentActivities => _strings['viewYourRecentActivities'] ?? 'View your recent activities';
  String get signOut => _strings['signOut'] ?? 'Sign Out';
  String get helpAndFAQ => _strings['helpAndFAQ'] ?? 'Help & FAQ';
  String get getAssistance => _strings['getAssistance'] ?? 'Get assistance';
  String get aboutXMUMNavigate => _strings['aboutXMUMNavigate'] ?? 'About XMUM Navigate';
  String get needHelp => _strings['needHelp'] ?? 'Need help?';
  String get browseOurFAQs => _strings['browseOurFAQs'] ?? 'Browse our FAQs or send us a message below.';
  String get frequentlyAskedQuestions => _strings['frequentlyAskedQuestions'] ?? 'Frequently Asked Questions';
  String get sendUsAMessage => _strings['sendUsAMessage'] ?? 'Send Us a Message';
  String get describeYourIssue => _strings['describeYourIssue'] ?? 'Describe your issue or question...';
  String get sendMessage => _strings['sendMessage'] ?? 'Send Message';
  String get messageSent => _strings['messageSent'] ?? 'Message sent! We\'ll get back to you soon.';
  String get supportEmail => _strings['supportEmail'] ?? 'support@xmumnavigate.com';
  String get supportPhone => _strings['supportPhone'] ?? '+60 3-8966 xxxx';
  String get currentPassword => _strings['currentPassword'] ?? 'Current Password';
  String get newPassword => _strings['newPassword'] ?? 'New Password';
  String get confirmNewPassword => _strings['confirmNewPassword'] ?? 'Confirm New Password';
  String get updatePassword => _strings['updatePassword'] ?? 'Update Password';
  String get passwordUpdated => _strings['passwordUpdated'] ?? 'Password updated successfully!';
  String get pleaseFillAllFields => _strings['pleaseFillAllFields'] ?? 'Please fill in all fields';
  String get passwordMinLength => _strings['passwordMinLength'] ?? 'Password must be at least 6 characters';
  String get passwordsDoNotMatch => _strings['passwordsDoNotMatch'] ?? 'New passwords do not match';
  String get welcome => _strings['welcome'] ?? 'Welcome';
  String get login => _strings['login'] ?? 'Login';
  String get signup => _strings['signup'] ?? 'Sign Up';
  String get email => _strings['email'] ?? 'Email';
  String get password => _strings['password'] ?? 'Password';
  String get forgotPassword => _strings['forgotPassword'] ?? 'Forgot Password?';
  String get dontHaveAccount => _strings['dontHaveAccount'] ?? 'Don\'t have an account?';
  String get alreadyHaveAccount => _strings['alreadyHaveAccount'] ?? 'Already have an account?';
  String get createAccount => _strings['createAccount'] ?? 'Create Account';
  String get fullName => _strings['fullName'] ?? 'Full Name';
  String get role => _strings['role'] ?? 'Role';
  String get student => _strings['student'] ?? 'Student';
  String get staff => _strings['staff'] ?? 'Staff';
  String get bio => _strings['bio'] ?? 'Bio';
  String get tellUsAboutYourself => _strings['tellUsAboutYourself'] ?? 'Tell us about yourself';
  String get register => _strings['register'] ?? 'Register';
  String get loginSuccess => _strings['loginSuccess'] ?? 'Login successful!';
  String get registrationSuccess => _strings['registrationSuccess'] ?? 'Registration successful!';
  String get hi => _strings['hi'] ?? 'Hi';
  String get wallet => _strings['wallet'] ?? 'Wallet';
  String get balance => _strings['balance'] ?? 'Balance';
  String get goNow => _strings['goNow'] ?? 'Go Now';
  String get history => _strings['history'] ?? 'History';
  String get services => _strings['services'] ?? 'Services';
  String get campusMap => _strings['campusMap'] ?? 'Campus Map';
  String get library => _strings['library'] ?? 'Library';
  String get transport => _strings['transport'] ?? 'Transport';
  String get facilities => _strings['facilities'] ?? 'Facilities';
  String get capacity => _strings['capacity'] ?? 'Capacity';
  String get type => _strings['type'] ?? 'Type';
  String get location => _strings['location'] ?? 'Location';
  String get availableForBooking => _strings['availableForBooking'] ?? 'Available for Booking';
  String get currentlyBooked => _strings['currentlyBooked'] ?? 'Currently Booked';
  String get viewOnMap => _strings['viewOnMap'] ?? 'View on Map';
  String get bookVenue => _strings['bookVenue'] ?? 'Book Venue';
  String get bookingRequestSent => _strings['bookingRequestSent'] ?? 'Booking request sent!';
  String get availableFacilities => _strings['availableFacilities'] ?? 'Available Facilities';
  String get from => _strings['from'] ?? 'From';
  String get to => _strings['to'] ?? 'To';
  String get duration => _strings['duration'] ?? 'Duration';
  String get getDirections => _strings['getDirections'] ?? 'Get Directions';
  String get selectLocation => _strings['selectLocation'] ?? 'Select Location';
  String get searchBuildings => _strings['searchBuildings'] ?? 'Search buildings...';
  String get search => _strings['search'] ?? 'Search';
  String get all => _strings['all'] ?? 'All';
  String get appPreferences => _strings['appPreferences'] ?? 'App Preferences';
  String get languageAndRegion => _strings['languageAndRegion'] ?? 'Language & Region';
  String get privacyAndSecurity => _strings['privacyAndSecurity'] ?? 'Privacy & Security';
  String get support => _strings['support'] ?? 'Support';
  String get aiAssistant => _strings['aiAssistant'] ?? 'AI Assistant';
  String get aiAssistantTitle => _strings['aiAssistantTitle'] ?? 'XMUM AI Assistant';
  String get aiAssistantSubtitle => _strings['aiAssistantSubtitle'] ?? 'Ask questions about campus';
  String get notificationsEnabled => _strings['notificationsEnabled'] ?? 'Campus alerts enabled';
  String get notificationsDisabled => _strings['notificationsDisabled'] ?? 'Campus alerts disabled';
  String get locationEnabled => _strings['locationEnabled'] ?? 'Location services enabled';
  String get locationDisabled => _strings['locationDisabled'] ?? 'Location services disabled. Navigation may be limited.';
  String get cancel => _strings['cancel'] ?? 'Cancel';
  String get aboutDescription => _strings['aboutDescription'] ?? 'Your premium campus companion for Xiamen University Malaysia.';
  String get aboutUniversity => _strings['aboutUniversity'] ?? 'University';
  String get aboutCopyright => _strings['aboutCopyright'] ?? '© 2026 XMUM Navigate. All rights reserved.';
  String get privacyIntro => _strings['privacyIntro'] ?? 'XMUM Navigate respects your privacy.';
  String get privacyDataCollection => _strings['privacyDataCollection'] ?? 'Data We Collect';
  String get privacyDataCollectionBody => _strings['privacyDataCollectionBody'] ?? '';
  String get privacyDataUsage => _strings['privacyDataUsage'] ?? 'How We Use Data';
  String get privacyDataUsageBody => _strings['privacyDataUsageBody'] ?? '';
  String get privacyDataSharing => _strings['privacyDataSharing'] ?? 'Data Sharing';
  String get privacyDataSharingBody => _strings['privacyDataSharingBody'] ?? '';
  String get privacyYourRights => _strings['privacyYourRights'] ?? 'Your Rights';
  String get privacyYourRightsBody => _strings['privacyYourRightsBody'] ?? '';
  String get privacySecurity => _strings['privacySecurity'] ?? 'Security';
  String get privacySecurityBody => _strings['privacySecurityBody'] ?? '';
  String get cachedData => _strings['cachedData'] ?? 'Cached Data';
  String get cacheDescription => _strings['cacheDescription'] ?? 'App preferences and cached data stored on your device.';
  String get clearCache => _strings['clearCache'] ?? 'Clear Cache';
  String get clearCacheConfirm => _strings['clearCacheConfirm'] ?? 'This will clear cached data while keeping your preferences. Continue?';
  String get cacheCleared => _strings['cacheCleared'] ?? 'Cache cleared successfully';
  String get getStarted => _strings['getStarted'] ?? 'Get Started';
  String get continue_ => _strings['continue_'] ?? 'Continue';
  String get skip => _strings['skip'] ?? 'Skip';
  String get discoverCampus => _strings['discoverCampus'] ?? 'Discover Campus';
  String get discoverCampusSubtitle => _strings['discoverCampusSubtitle'] ?? 'Find buildings, facilities & services around XMUM';
  String get interactiveMap => _strings['interactiveMap'] ?? 'Interactive Map';
  String get interactiveMapSubtitle => _strings['interactiveMapSubtitle'] ?? 'Explore the full XMUM campus with live navigation';
  String get smartDirections => _strings['smartDirections'] ?? 'Smart Directions';
  String get smartDirectionsSubtitle => _strings['smartDirectionsSubtitle'] ?? 'Get walking routes to any destination on campus';
  String get changePasswordHint => _strings['changePasswordHint'] ?? 'Enter your current password and choose a new one';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ms'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
