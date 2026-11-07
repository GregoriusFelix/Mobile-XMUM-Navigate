class RouteHistory {
  final String id;
  final String startLocation;
  final String endLocation;
  final DateTime timestamp;
  final double? distance;
  final String? duration;

  RouteHistory({
    required this.id,
    required this.startLocation,
    required this.endLocation,
    required this.timestamp,
    this.distance,
    this.duration,
  });

  // Convert Firestore document → RouteHistory
  factory RouteHistory.fromMap(String id, Map<String, dynamic> map) {
    return RouteHistory(
      id: id,
      startLocation: map['startLocation'] ?? '',
      endLocation: map['endLocation'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp']) 
          : DateTime.now(),
      distance: map['distance']?.toDouble(),
      duration: map['duration'],
    );
  }

  // Convert RouteHistory → Firestore document
  Map<String, dynamic> toMap() {
    return {
      'startLocation': startLocation,
      'endLocation': endLocation,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'distance': distance,
      'duration': duration,
    };
  }

  // Create a copy with updated fields
  RouteHistory copyWith({
    String? startLocation,
    String? endLocation,
    DateTime? timestamp,
    double? distance,
    String? duration,
  }) {
    return RouteHistory(
      id: id,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      timestamp: timestamp ?? this.timestamp,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
    );
  }
}
