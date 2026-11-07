import '../models/campus_location.dart';

class LocationDisplay {
  final String status;
  final String hours;
  final String emoji;
  final double rating;
  final int reviewCount;
  final List<String> facilities;
  final String longDescription;

  const LocationDisplay({
    required this.status,
    required this.hours,
    required this.emoji,
    required this.rating,
    required this.reviewCount,
    required this.facilities,
    required this.longDescription,
  });
}

LocationDisplay locationDisplayFor(CampusLocation location) {
  switch (location.category) {
    case 'Food':
      return LocationDisplay(
        status: 'Open',
        hours: '7:00 AM - 9:00 PM',
        emoji: _foodEmoji(location.name),
        rating: 4.3,
        reviewCount: 1200,
        facilities: ['Halal', 'Seating Area', 'WiFi'],
        longDescription:
            '${location.description}. A popular dining spot on the XMUM campus with a wide menu and affordable prices.',
      );
    case 'Facilities':
      return LocationDisplay(
        status: 'Open',
        hours: '24 Hours',
        emoji: '⭐',
        rating: 4.2,
        reviewCount: 890,
        facilities: ['AC', 'WiFi', 'Accessible'],
        longDescription:
            '${location.description}. A campus facility at XMUM equipped with modern amenities for students and staff.',
      );
    case 'Office':
      return LocationDisplay(
        status: 'Open',
        hours: '24 Hours',
        emoji: '💻',
        rating: 3.9,
        reviewCount: 450,
        facilities: ['Large Capacity', 'Covered Area', 'Easy Access'],
        longDescription:
            '${location.description}. Location where internal thing happens',
      );
    case 'Entrance':
      return LocationDisplay(
        status: 'Open',
        hours: '24 Hours',
        emoji: '🚪',
        rating: 4.0,
        reviewCount: 320,
        facilities: ['Security Guard', 'Visitor Access'],
        longDescription:
            '${location.description}. A main campus entrance at XMUM with security control.',
      );
    case 'Dorm':
      return LocationDisplay(
        status: 'Open',
        hours: '24 Hours',
        emoji: '🛏️',
        rating: 4.0,
        reviewCount: 320,
        facilities: ['Security Guard', 'Visitor Access'],
        longDescription:
            '${location.description}. Building where student can rest',
      );
    default:
      return LocationDisplay(
        status: 'Open',
        hours: '8:00 AM - 10:00 PM',
        emoji: '🏫',
        rating: 4.1,
        reviewCount: 600,
        facilities: ['Classrooms', 'WiFi', 'Projector'],
        longDescription:
            '${location.description}. An academic block at XMUM with modern learning facilities.',
      );
  }
}

String _foodEmoji(String name) {
  if (name.contains('Canteen') || name.contains('LY3')) return '🍜';
  if (name.contains('Café') || name.contains('Cafe')) return '☕';
  if (name.contains('Subway')) return '🥖';
  if (name.contains('Khababish')) return '🍔';
  return '🍽️';
}

String _facilityEmoji(String name) {
  if (name.contains('Library')) return '📚';
  if (name.contains('Sports')) return '🏀';
  if (name.contains('Gym')) return '💪';
  if (name.contains('Auditorium')) return '🎭';
  return '🏢';
}

String categoryLabel(String category) {
  switch (category) {
    case 'Food': return 'Food';
    case 'Facility': return 'Facility';
    case 'Parking': return 'Parking';
    case 'Entrance': return 'Entrance';
    case 'Academic': return 'Academic';
    default: return category;
  }
}
