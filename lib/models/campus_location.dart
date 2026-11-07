import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';

class CampusLocation {
  final String id;
  final String name;
  final String description;
  final LatLng position;
  final String category;

  CampusLocation({
    required this.id,
    required this.name,
    required this.description,
    required this.position,
    required this.category,
  });
}

// XMUM Campus locations with approximate coordinates
class CampusLocations {
  static const LatLng xmumCenter = LatLng(2.832899, 101.702819);
  static final List<CampusLocation> _userLocations = [];

  static List<CampusLocation> get allLocations {
    return [..._predefinedLocations, ..._userLocations];
  }

  static final List<CampusLocation> _predefinedLocations = [
    // Dorms
    CampusLocation(
      id: 'LY1',
      name: 'LY1 Block',
      description: 'Student Dorm LY1',
      position: const LatLng(2.833877639537375, 101.70240530368376),
      category: 'Dorm',
    ),
    CampusLocation(
      id: 'LY2',
      name: 'LY2 Block',
      description: 'Student Dorm LY2',
      position: const LatLng(2.8339303742184865, 101.70295409583541),
      category: 'Dorm',
    ),
    CampusLocation(
      id: 'LY4',
      name: 'LY4 Block',
      description: 'Student Dorm LY4',
      position: const LatLng(2.8339615139943306, 101.70430770067419),
      category: 'Dorm',
    ),
    CampusLocation(
      id: 'LY5_Class',
      name: 'LY5 Block',
      description: 'Student Dorm LY5',
      position: const LatLng(2.8340941496769614, 101.70478769380169),
      category: 'Dorm',
    ),
    CampusLocation(
      id: 'LY6',
      name: 'LY6 Block',
      description: 'Student Dorm LY6',
      position: const LatLng(2.834667061391711, 101.70198770967204),
      category: 'Dorm',
    ),
    CampusLocation(
      id: 'LY7',
      name: 'LY7 Block',
      description: 'Student Dorm LY7',
      position: const LatLng(2.8346271109064665, 101.70281649782251),
      category: 'Dorm',
    ),
    CampusLocation(
      id: 'LY8',
      name: 'LY8 Block',
      description: 'Student Dorm LY8',
      position: const LatLng(2.834584926258193, 101.70412933357203),
      category: 'Dorm',
    ),
    CampusLocation(
      id: 'LY9',
      name: 'LY9 Block',
      description: 'Student Dorm LY9',
      position: const LatLng(2.8346664252515517, 101.70499172123955),
      category: 'Dorm',
    ),
    CampusLocation(
      id: 'D1',
      name: 'D1 Block',
      description: 'Student Dorm D1',
      position: const LatLng(2.8333084183847967, 101.70704768778373),
      category: 'Dorm',
    ),
    CampusLocation(
      id: 'D2',
      name: 'D2 Block',
      description: 'Student Dorm D2',
      position: const LatLng(2.833747395730055, 101.70688600102571),
      category: 'Dorm',
    ),
    CampusLocation(
      id: 'D3',
      name: 'D3 Block',
      description: 'Student Dorm D3',
      position: const LatLng(2.833376653221995, 101.70631440418678),
      category: 'Dorm',
    ),
    CampusLocation(
      id: 'D4',
      name: 'D4 Block',
      description: 'Student Dorm D4',
      position: const LatLng(2.8338361009834045, 101.7054171565483),
      category: 'Dorm',
    ),
    CampusLocation(
      id: 'D5',
      name: 'D5 Block',
      description: 'Student Dorm D5',
      position: const LatLng(2.8345866835540554, 101.70540804743533),
      category: 'Dorm',
    ),


    
    // Class Buildings
    CampusLocation(
      id: 'A1',
      name: 'A1 Block',
      description: 'Lecture Building A1',
      position: const LatLng(2.8307211359773667, 101.70239443045162),
      category: 'Class',
    ),
    CampusLocation(
      id: 'A2',
      name: 'A2 Block',
      description: 'Lecture Building A2',
      position: const LatLng(2.8308939979329066, 101.70297285913536),
      category: 'Class',
    ),
    CampusLocation(
      id: 'A3',
      name: 'A3 Block',
      description: 'Lecture Building & Library A3',
      position: const LatLng(2.831189682785216, 101.70380406569397),
      category: 'Class',
    ),
    CampusLocation(
      id: 'A4',
      name: 'A4 Block',
      description: 'Lecture Building A4',
      position: const LatLng(2.8312478701194164, 101.70463653659736),
      category: 'Class',
    ),
    CampusLocation(
      id: 'A5',
      name: 'A5 Block',
      description: 'Lecture Building A5',
      position: const LatLng(2.830963557777099, 101.70531288823545),
      category: 'Class',
    ),
    CampusLocation(
      id: 'B1',
      name: 'B1',
      description: 'Lecture Building B1',
      position: const LatLng(2.8325534915260198, 101.70629660511965),
      category: 'Class',
    ),


    
    // Food & Dining
    CampusLocation(
      id: 'LY3',
      name: 'LY3 Block',
      description: 'Canteen LY3 at 1st and 2nd Floor',
      position: const LatLng(2.8343466368417882, 101.70344851295609),
      category: 'Food',
    ),
    CampusLocation(
      id: 'd6_cafe',
      name: 'D6 Canteen',
      description: 'Canteen D6 at Ground, 1st, 2nd Floor',
      position: const LatLng(2.8340507581648224, 101.70635869388315),
      category: 'Food',
    ),
    CampusLocation(
      id: 'lake_front',
      name: 'LakeFront Café (Music Island)',
      description: 'LakeFront Cafe located inside Music Island',
      position: const LatLng(2.8330985591540445, 101.70317199310577),
      category: 'Food',
    ),


    // Entrances
    CampusLocation(
      id: 'main_gate',
      name: 'Southern Gate',
      description: 'XMUM Southern Gate Entrance',
      position: const LatLng(2.8293386807698093, 101.70403659082316),
      category: 'Entrance',
    ),
    CampusLocation(
      id: 'east_gate',
      name: 'Eastern Gate',
      description: 'XMUM Eastern Gate Entrance',
      position: const LatLng(2.832867476968018, 101.70773761327567),
      category: 'Entrance',
    ),


    // Office
    CampusLocation(
      id: 'SAO',
      name: 'Student Affairs Office',
      description: 'Student Affairs Office (General Enquiry) B1#107',
      position: const LatLng(2.832357331644753, 101.70652019244599),
      category: 'Office',
    ),
    CampusLocation(
      id: 'AO',
      name: 'Accomodaton Office',
      description: 'Student Accomodation Office B1#107',
      position: const LatLng(2.8323335287582876, 101.7064844444463),
      category: 'Office',
    ),
    CampusLocation(
      id: 'ISAO',
      name: 'International Student Affair Office',
      description: 'International Student Affair Office B1#104',
      position: const LatLng(2.832419701500227, 101.70669297996672),
      category: 'Office',
    ),
    CampusLocation(
      id: 'ECA',
      name: 'Extra-Curricular Activities',
      description: 'Extra-Curricular Activities (ECA) B1#103',
      position: const LatLng(2.8324144119706633, 101.70694453994403),
      category: 'Office',
    ),
     CampusLocation(
      id: 'Maintenance',
      name: 'Maintenance Office',
      description: 'Maintenance Office B1#G13',
      position: const LatLng(2.8323377137892987, 101.70711003993102),
      category: 'Office',
    ),
     CampusLocation(
      id: 'IT',
      name: 'IT Office',
      description: 'IT Office B1#G09',
      position: const LatLng(2.8327053360610064, 101.70705310793615),
      category: 'Office',
    ),
    CampusLocation(
      id: 'Finance',
      name: 'Finance Office',
      description: 'Finance Office A3#711',
      position: const LatLng(2.831195213125605, 101.70384438975181),
      category: 'Office',
    ),
    CampusLocation(
      id: 'AA',
      name: 'Academic Affairs Office',
      description: 'Academic Affairs Office (Degree) A3#702',
      position: const LatLng(2.83107851831402, 101.70375770392467),
      category: 'Office',
    ),
    CampusLocation(
      id: 'SFS',
      name: 'School of Foundation Studies',
      description: 'School of Foundation Studies (Foundation) B1#217B',
      position: const LatLng(2.8326270976536723, 101.70667377644352),
      category: 'Office',
    ),


    // Facilities
    CampusLocation(
      id: 'gym',
      name: 'Gym',
      description: 'XMUM Gym at B1 3rd Floor',
      position: const LatLng(2.832725933413566, 101.70676015082579),
      category: 'Facilities',
    ),
    CampusLocation(
      id: 'Swimming_Pool',
      name: 'Swimming Pool',
      description: 'XMUM Swimming Pool at B1 3rd Floor',
      position: const LatLng(2.8325979038735696, 101.70711480080665),
      category: 'Facilities',
    ),
    CampusLocation(
      id: 'badminton',
      name: 'Badminton Court',
      description: 'Badminton Court at B1 (Indoor)',
      position: const LatLng(2.8326782718246237, 101.707374975078),
      category: 'Facilities',
    ),
    CampusLocation(
      id: 'Tennis',
      name: 'Tennis Court',
      description: 'Tennis Court (Outdoor)',
      position: const LatLng(2.831877605848309, 101.70671333018451),
      category: 'Facilities',
    ),
    CampusLocation(
      id: 'Volleyball',
      name: 'Volleyball Court',
      description: 'Volleyball Court (Outdoor)',
      position: const LatLng(2.831872247981373, 101.70725781860807),
      category: 'Facilities',
    ),
    CampusLocation(
      id: 'Football',
      name: 'Football Court',
      description: 'Football Court (Outdoor)',
      position: const LatLng(2.8315480969847466, 101.7066784614678),
      category: 'Facilities',
    ),
    CampusLocation(
      id: 'Basketball',
      name: 'Basketball Court',
      description: 'Football Court (Outdoor)',
      position: const LatLng(2.831542739116284, 101.70732219162372),
      category: 'Facilities',
    ),
    CampusLocation(
      id: 'Track & Field',
      name: 'Track & Field',
      description: 'Track & Field (Outdoor)',
      position: const LatLng(2.8303747231862717, 101.70687962714308),
      category: 'Facilities',
    ),
    CampusLocation(
      id: 'THC',
      name: 'Tan Hua Choon Auditorium Hall',
      description: 'Tan Hua Choon Auditorium Hall beside A1',
      position: const LatLng(2.8303837645895213, 101.70178488410188),
      category: 'Facilities',
    ),
    CampusLocation(
      id: 'B1-114',
      name: 'B1 #114',
      description: 'Lecture Hall B1 #114',
      position: const LatLng(2.8326547303022744, 101.70707163934333),
      category: 'Class',
    ),
    CampusLocation(
      id: 'B1-101',
      name: 'B1 #101 Multi Purpose Hall',
      description: 'Multi Purpose Hall B1 #101',
      position: const LatLng(2.8324506952210693, 101.7070872335933),
      category: 'Facilities',
    ),
  ];

  static Future<void> loadUserLocations(String uid) async {
    try {
      final service = FirebaseService();
      final userLocations = await service.getUserLocations(uid);
      
      _userLocations.clear();
      for (var locData in userLocations) {
        _userLocations.add(
          CampusLocation(
            id: locData['id'] as String,
            name: locData['name'] as String,
            description: locData['description'] as String,
            position: LatLng(
              locData['latitude'] as double,
              locData['longitude'] as double,
            ),
            category: locData['category'] as String,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading user locations: $e');
    }
  }

  static void addUserLocation(CampusLocation location) {
    _userLocations.add(location);
  }

  static void removeUserLocation(String locationId) {
    _userLocations.removeWhere((loc) => loc.id == locationId);
  }

  static CampusLocation? getLocationById(String id) {
    try {
      return allLocations.firstWhere((loc) => loc.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<CampusLocation> getLocationsByCategory(String category) {
    return allLocations.where((loc) => loc.category == category).toList();
  }

  static List<CampusLocation> searchLocations(String query) {
    final lowerQuery = query.toLowerCase();
    return allLocations.where((loc) =>
      loc.name.toLowerCase().contains(lowerQuery) ||
      loc.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}
