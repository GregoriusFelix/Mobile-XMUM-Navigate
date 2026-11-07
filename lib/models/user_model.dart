class UserModel {
  final String uid;
  final String name;
  final String email;
  final String bio;
  final String role; // Student, Parent, Visitor
  final String? profilePictureUrl;
  final String? phoneNumber;
  final List<String> savedLocations; // List of location IDs
  final List<Map<String, dynamic>> routeHistory; // List of route history entries

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.bio,
    required this.role,
    this.profilePictureUrl,
    this.phoneNumber,
    this.savedLocations = const [],
    this.routeHistory = const [],
  });

  // Convert Firestore document → UserModel
  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      bio: map['bio'] ?? '',
      role: map['role'] ?? 'Student',
      profilePictureUrl: map['profilePictureUrl'],
      phoneNumber: map['phoneNumber'],
      savedLocations: List<String>.from(map['savedLocations'] ?? []),
      routeHistory: List<Map<String, dynamic>>.from(map['routeHistory'] ?? []),
    );
  }

  // Convert UserModel → Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'bio': bio,
      'role': role,
      'profilePictureUrl': profilePictureUrl,
      'phoneNumber': phoneNumber,
      'savedLocations': savedLocations,
      'routeHistory': routeHistory,
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? name,
    String? email,
    String? bio,
    String? role,
    String? profilePictureUrl,
    String? phoneNumber,
    List<String>? savedLocations,
    List<Map<String, dynamic>>? routeHistory,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      savedLocations: savedLocations ?? this.savedLocations,
      routeHistory: routeHistory ?? this.routeHistory,
    );
  }
}
