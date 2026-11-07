import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/app_localizations.dart';
import '../models/campus_location.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/audio_service.dart';
import '../utils/location_display.dart';
import '../utils/xmum_page_route.dart';
import 'navigation_screen.dart';
import 'location_detail_screen.dart';
import 'location_form_screen.dart';
import 'venue_filter_screen.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';


class ContentScreen extends StatefulWidget {
  final int initialTabIndex;

  const ContentScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late CampusLocation _selectedMapLocation;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  double _cardHeight = 200;
  final double _minCardHeight = 150;
  final double _closedCardHeight = 150;
  double _maxCardHeight = 0;
  double _dragStartY = 0;
  double _dragStartHeight = 0;
  late final AnimationController _cardAnimController;
  Animation<double>? _cardAnimation;
  VoidCallback? _cardAnimListener;
  final _service = FirebaseService();
  bool _isCurrentLocationSaved = false;

  // Venue recommendation state
  String? _selectedVenueType;
  int? _requiredCapacity;
  List<String> _selectedFacilities = [];
  final bool _showRecommendations = false;
  bool _filtersApplied = false;

  static List<CampusLocation> get _mapLocations => CampusLocations.allLocations
      .where((l) => ['Food', 'Facilities', 'Entrance', 'Dorm', 'Class', 'Office'].contains(l.category))
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    _cardAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _selectedMapLocation = CampusLocations.getLocationById('LY3') ?? _mapLocations.first;
    _getCurrentLocation();
    _updateSaveState();
    AudioService().playBackgroundMusic();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _maxCardHeight = MediaQuery.of(context).size.height * 0.5 + 120;
        _cardHeight = _minCardHeight;
      });
    });
  }

  Future<void> _updateSaveState() async {
    _isCurrentLocationSaved = await _isLocationSaved(_selectedMapLocation.id);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _tabController.dispose();
    _cardAnimController.dispose();
    AudioService().stopBackgroundMusic();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  debugPrint('Location service enabled: $serviceEnabled');
  if (!serviceEnabled) return;

  LocationPermission permission = await Geolocator.checkPermission();
  debugPrint('Current permission: $permission');
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    debugPrint('Permission after request: $permission');
    if (permission == LocationPermission.denied) return;
  }



    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
    });
  }

  Future<BitmapDescriptor> _getResizedMarker(String assetPath, {int size = 32}) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: size, targetHeight: size);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _getMarkerIconForCategory(String category, {bool isSelected = false}) async {
    final size = isSelected ? 200 : 100;
    switch (category) {
      case 'Food':
        return await _getResizedMarker('assets/images/marker_food.png', size: size);
      case 'Facilities':
        return await _getResizedMarker('assets/images/marker_facilities.png', size: size);
      case 'Entrance':
        return await _getResizedMarker('assets/images/marker_entrance.png', size: size);
      case 'Dorm':
        return await _getResizedMarker('assets/images/marker_dorm.png', size: size);
      case 'Class':
        return await _getResizedMarker('assets/images/marker_class.png', size: size);
      case 'Office':
        return await _getResizedMarker('assets/images/marker_office.png', size: size);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  Future<BitmapDescriptor> _getGlowMarker() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = kPrimary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(50, 50), 50, paint);
    final picture = recorder.endRecording();
    final image = await picture.toImage(100, 100);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context);
    final isDark = themeProvider.isDark;
    
    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      appBar: AppBar(
        title: Text(localizations.explore, style: xmumFont(fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? kDarkCard : kWhite,
        foregroundColor: isDark ? kDarkText : kTextDark,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          // Music playing indicator
          StreamBuilder<bool>(
            stream: Stream.periodic(const Duration(seconds: 1), (_) => AudioService().isBackgroundMusicPlaying),
            initialData: AudioService().isBackgroundMusicPlaying,
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.music_note, size: 16, color: kPrimary),
                            const SizedBox(width: 4),
                            Text(
                              'Playing',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationFormScreen()),
              ).then((result) {
                if (result == true) {
                  setState(() {});
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          XmumSegmentedTabBar(
            controller: _tabController,
            isDark: isDark,
            labels: [
              localizations.map,
              localizations.food,
              localizations.venues,
            ],
            icons: const [
              Icons.map_outlined,
              Icons.restaurant_outlined,
              Icons.event_outlined,
            ],
          ),
          Expanded(
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(), 
          children: [
            _buildMapTab(),
            _buildFoodTab(),
            _buildVenuesTab(),
    ],
  ),
),
        ],
      ),
    );
  }

  Widget _buildFoodTab() {
    final restaurants = {
      'Kami Cemerlang': {
        'name': 'Kami Cemerlang',
        'hours': '7:00 AM - 9:00 PM',
        'halal': true,
        'rating': 4.3,
        'menu': [
          {'name': 'Nasi Lemak Special', 'price': 'RM 8.50'},
          {'name': 'Chicken Rice', 'price': 'RM 7.00'},
          {'name': 'Mee Goreng Mamak', 'price': 'RM 6.50'},
          {'name': 'Roti Canai', 'price': 'RM 2.00'},
          {'name': 'Teh Tarik', 'price': 'RM 3.00'},
          {'name': 'Nasi Goreng Kampung', 'price': 'RM 8.00'},
        ]
      },
      'Subway': {
        'name': 'Subway',
        'hours': '8:00 AM - 9:00 PM',
        'halal': true,
        'rating': 4.5,
        'menu': [
          {'name': 'Italian B.M.T', 'price': 'RM 18.90'},
          {'name': 'Chicken Teriyaki', 'price': 'RM 16.90'},
          {'name': 'Tuna', 'price': 'RM 17.90'},
          {'name': 'Veggie Delite', 'price': 'RM 12.90'},
          {'name': 'Meatball Marinara', 'price': 'RM 15.90'},
          {'name': 'Cookies', 'price': 'RM 3.50'},
        ]
      },
      'Keluang Station': {
        'name': 'Keluang Station',
        'hours': '7:30 AM - 8:30 PM',
        'halal': true,
        'rating': 4.1,
        'menu': [
          {'name': 'Nasi Goreng Ayam', 'price': 'RM 7.50'},
          {'name': 'Mee Goreng', 'price': 'RM 6.00'},
          {'name': 'Kuey Teow Goreng', 'price': 'RM 7.00'},
          {'name': 'Nasi Lemak', 'price': 'RM 5.50'},
          {'name': 'Sirap Bandung', 'price': 'RM 2.50'},
        ]
      },
      'Under Tree': {
        'name': 'Under Tree',
        'hours': '10:00 AM - 6:00 PM',
        'halal': true,
        'rating': 4.2,
        'menu': [
          {'name': 'Western Chicken Chop', 'price': 'RM 12.00'},
          {'name': 'Fish & Chips', 'price': 'RM 13.00'},
          {'name': 'Spaghetti Bolognese', 'price': 'RM 11.00'},
          {'name': 'Chicken Burger', 'price': 'RM 9.00'},
          {'name': 'Lemon Tea', 'price': 'RM 4.00'},
        ]
      },
      'Uni Hotpot': {
        'name': 'Uni Hotpot',
        'hours': '11:00 AM - 9:00 PM',
        'halal': true,
        'rating': 4.4,
        'menu': [
          {'name': 'Individual Hotpot (Chicken)', 'price': 'RM 15.00'},
          {'name': 'Individual Hotpot (Beef)', 'price': 'RM 18.00'},
          {'name': 'Individual Hotpot (Seafood)', 'price': 'RM 20.00'},
          {'name': 'Set for 2 (Chicken)', 'price': 'RM 28.00'},
          {'name': 'Set for 2 (Mixed)', 'price': 'RM 35.00'},
        ]
      },
      'Boombeach': {
        'name': 'Boombeach',
        'hours': '11:00 AM - 8:00 PM',
        'halal': true,
        'rating': 4.0,
        'menu': [
          {'name': 'Tom Yum Noodle', 'price': 'RM 8.00'},
          {'name': 'Clear Soup Noodle', 'price': 'RM 7.00'},
          {'name': 'Dry Noodle', 'price': 'RM 7.00'},
          {'name': 'Thai Tea', 'price': 'RM 5.00'},
          {'name': 'Mango Sticky Rice', 'price': 'RM 8.00'},
        ]
      },
      'Korean Resto': {
        'name': 'Korean Resto',
        'hours': '11:00 AM - 8:00 PM',
        'halal': true,
        'rating': 4.3,
        'menu': [
          {'name': 'Kimchi Jjigae', 'price': 'RM 15.00'},
          {'name': 'Bibimbap', 'price': 'RM 14.00'},
          {'name': 'Bulgogi Rice', 'price': 'RM 16.00'},
          {'name': 'Korean Fried Chicken', 'price': 'RM 18.00'},
          {'name': 'TteokbokKi', 'price': 'RM 12.00'},
        ]
      },
      'Japan Resto': {
        'name': 'Japan Resto',
        'hours': '11:00 AM - 8:00 PM',
        'halal': true,
        'rating': 4.2,
        'menu': [
          {'name': 'Chicken Katsu Don', 'price': 'RM 13.00'},
          {'name': 'Salmon Sashimi (5 pcs)', 'price': 'RM 18.00'},
          {'name': 'Tempura Udon', 'price': 'RM 12.00'},
          {'name': 'California Roll', 'price': 'RM 15.00'},
          {'name': 'Miso Soup', 'price': 'RM 4.00'},
        ]
      },
      'Kopitiam': {
        'name': 'Kopitiam',
        'hours': '7:00 AM - 5:00 PM',
        'halal': false,
        'rating': 4.1,
        'menu': [
          {'name': 'Nasi Lemak', 'price': 'RM 4.50'},
          {'name': 'Toast Set', 'price': 'RM 6.00'},
          {'name': 'Half Boiled Eggs', 'price': 'RM 3.00'},
          {'name': 'Kopi O', 'price': 'RM 2.50'},
          {'name': 'Teh O', 'price': 'RM 2.50'},
          {'name': 'Char Kuey Teow', 'price': 'RM 7.00'},
        ]
      },
      'Castle In The Sky': {
        'name': 'Castle In The Sky',
        'hours': '10:00 AM - 6:00 PM',
        'halal': false,
        'rating': 4.3,
        'menu': [
          {'name': 'Pork Chop Rice', 'price': 'RM 12.00'},
          {'name': 'Braised Pork Rice', 'price': 'RM 10.00'},
          {'name': 'Roasted Chicken Rice', 'price': 'RM 9.00'},
          {'name': 'Char Siew Rice', 'price': 'RM 10.00'},
          {'name': 'Wantan Noodle', 'price': 'RM 8.00'},
        ]
      },
      'Thai Taro': {
        'name': 'Thai Taro',
        'hours': '10:00 AM - 6:00 PM',
        'halal': true,
        'rating': 4.0,
        'menu': [
          {'name': 'Green Curry', 'price': 'RM 12.00'},
          {'name': 'Tom Yum Goong', 'price': 'RM 15.00'},
          {'name': 'Pad Thai', 'price': 'RM 10.00'},
          {'name': 'Pineapple Fried Rice', 'price': 'RM 11.00'},
          {'name': 'Thai Iced Tea', 'price': 'RM 5.00'},
        ]
      },
      'City Kitchen': {
        'name': 'City Kitchen',
        'hours': '10:00 AM - 8:00 PM',
        'halal': false,
        'rating': 4.2,
        'menu': [
          {'name': 'Chicken Rice', 'price': 'RM 8.00'},
          {'name': 'Roast Duck Rice', 'price': 'RM 12.00'},
          {'name': 'Wonton Noodle', 'price': 'RM 9.00'},
          {'name': 'Dim Sum (3 pcs)', 'price': 'RM 6.00'},
          {'name': 'Herbal Tea', 'price': 'RM 4.00'},
        ]
      },
      'Pork': {
        'name': 'Pork',
        'hours': '10:00 AM - 8:00 PM',
        'halal': false,
        'rating': 4.1,
        'menu': [
          {'name': 'Braised Pork Belly Rice', 'price': 'RM 11.00'},
          {'name': 'Sweet Sour Pork Rice', 'price': 'RM 10.00'},
          {'name': 'Pork Chop Rice', 'price': 'RM 12.00'},
          {'name': 'Minced Pork Rice', 'price': 'RM 9.00'},
        ]
      },
      'Noodle Green': {
        'name': 'Noodle Green',
        'hours': '10:00 AM - 8:00 PM',
        'halal': true,
        'rating': 4.0,
        'menu': [
          {'name': 'Vegetarian Noodle', 'price': 'RM 7.00'},
          {'name': 'Tofu Rice', 'price': 'RM 6.00'},
          {'name': 'Mixed Veg Rice', 'price': 'RM 7.00'},
          {'name': 'Fried Rice', 'price': 'RM 6.50'},
        ]
      },
      'Khababish': {
        'name': 'Khababish',
        'hours': '11:00 AM - 9:00 PM',
        'halal': true,
        'rating': 4.4,
        'menu': [
          {'name': 'Chicken Kebab Set', 'price': 'RM 15.00'},
          {'name': 'Lamb Kebab Set', 'price': 'RM 18.00'},
          {'name': 'Mixed Grill', 'price': 'RM 25.00'},
          {'name': 'Shawarma', 'price': 'RM 10.00'},
          {'name': 'Hummus', 'price': 'RM 6.00'},
        ]
      },
      'Thumbs Up': {
        'name': 'Thumbs Up',
        'hours': '11:00 AM - 9:00 PM',
        'halal': true,
        'rating': 4.2,
        'menu': [
          {'name': 'Fried Chicken (2 pcs)', 'price': 'RM 8.00'},
          {'name': 'Fried Chicken (3 pcs)', 'price': 'RM 11.00'},
          {'name': 'Chicken Wings (4 pcs)', 'price': 'RM 10.00'},
          {'name': 'Coleslaw', 'price': 'RM 4.00'},
          {'name': 'Mashed Potato', 'price': 'RM 4.00'},
        ]
      },
      'Four Fingers': {
        'name': 'Four Fingers',
        'hours': '11:00 AM - 9:00 PM',
        'halal': true,
        'rating': 4.3,
        'menu': [
          {'name': 'Chicken Wings (4 pcs)', 'price': 'RM 12.00'},
          {'name': 'Chicken Wings (6 pcs)', 'price': 'RM 17.00'},
          {'name': 'Chicken Wings (8 pcs)', 'price': 'RM 22.00'},
          {'name': 'Crispy Chicken Burger', 'price': 'RM 10.00'},
          {'name': 'Fries', 'price': 'RM 5.00'},
        ]
      },
      'Cloud Food': {
        'name': 'Cloud Food',
        'hours': '11:00 AM - 9:00 PM',
        'halal': true,
        'rating': 4.1,
        'menu': [
          {'name': 'Beef Burger', 'price': 'RM 12.00'},
          {'name': 'Chicken Burger', 'price': 'RM 10.00'},
          {'name': 'Fish Burger', 'price': 'RM 11.00'},
          {'name': 'Cheese Burger', 'price': 'RM 13.00'},
          {'name': 'Onion Rings', 'price': 'RM 6.00'},
        ]
      },
      'Coffee Bar': {
        'name': 'Coffee Bar',
        'hours': '9:00 AM - 8:00 PM',
        'halal': true,
        'rating': 4.5,
        'menu': [
          {'name': 'Latte', 'price': 'RM 12.00'},
          {'name': 'Cappuccino', 'price': 'RM 12.00'},
          {'name': 'Americano', 'price': 'RM 10.00'},
          {'name': 'Mocha', 'price': 'RM 13.00'},
          {'name': 'Espresso', 'price': 'RM 8.00'},
        ]
      },
      'Bakery': {
        'name': 'Bakery',
        'hours': '9:00 AM - 6:00 PM',
        'halal': true,
        'rating': 4.3,
        'menu': [
          {'name': 'Croissant', 'price': 'RM 5.00'},
          {'name': 'Pain au Chocolat', 'price': 'RM 6.00'},
          {'name': 'Danish', 'price': 'RM 5.50'},
          {'name': 'Muffin', 'price': 'RM 4.50'},
          {'name': 'Bagel', 'price': 'RM 4.00'},
        ]
      },
      'Ice Cream Station': {
        'name': 'Ice Cream Station',
        'hours': '10:00 AM - 8:00 PM',
        'halal': true,
        'rating': 4.4,
        'menu': [
          {'name': 'Single Scoop', 'price': 'RM 5.00'},
          {'name': 'Double Scoop', 'price': 'RM 8.00'},
          {'name': 'Triple Scoop', 'price': 'RM 11.00'},
          {'name': 'Waffle Cone', 'price': 'RM 3.00'},
          {'name': 'Sundae', 'price': 'RM 10.00'},
        ]
      },
    };

    final canteens = [
      {
        'id': 'LY3',
        'name': 'LY3 Canteen',
        'emoji': '🍜',
        'distance': '800m',
        'halal': true,
        'open': true,
        'hours': '7:00 AM - 9:00 PM',
        'rating': 4.5,
        'floors': {
          '1st Floor': ['Kami Cemerlang', 'Subway', 'Keluang Station', 'Under Tree', 'Uni Hotpot'],
          '2nd Floor': ['Boombeach', 'Korean Resto', 'Japan Resto'],
        }
      },
      {
        'id': 'd6_cafe',
        'name': 'D6 Canteen',
        'emoji': '☕',
        'distance': '300m',
        'halal': true,
        'open': true,
        'hours': '8:00 AM - 6:00 PM',
        'rating': 4.2,
        'floors': {
          'Ground Floor': ['Kopitiam', 'Castle In The Sky', 'Thai Taro'],
          '1st Floor': ['City Kitchen', 'Pork', 'Noodle Green'],
          '2nd Floor': ['Khababish', 'Thumbs Up', 'Four Fingers', 'Cloud Food'],
        }
      },
      {
        'id': 'lake_front',
        'name': 'LakeFront Café',
        'emoji': '☕',
        'distance': '600m',
        'halal': true,
        'open': true,
        'hours': '9:00 AM - 8:00 PM',
        'rating': 4.4,
        'floors': {
          'Ground Floor': ['Coffee Bar', 'Bakery', 'Ice Cream Station'],
        }
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: canteens.length,
      itemBuilder: (context, index) {
        final canteen = canteens[index];
        final isOpen = canteen['open'] == true;
        
        return GestureDetector(
          onTap: () => _showCanteenDetails(context, canteen),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kCardShadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with image and status
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: kSetelLight,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                      ),
                      child: Center(
                        child: Text(canteen['emoji']?.toString() ?? '🍜', style: const TextStyle(fontSize: 44)),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    canteen['name']?.toString() ?? 'Unknown',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isOpen ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isOpen ? Icons.access_time : Icons.access_time_filled,
                                        size: 12,
                                        color: kWhite,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isOpen ? AppLocalizations.of(context).open : AppLocalizations.of(context).closed,
                                        style: const TextStyle(color: kWhite, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 4),
                                Text(
                                  canteen['rating']?.toString() ?? '0.0',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextDark),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.directions_walk_rounded, size: 14, color: kTextMuted),
                                const SizedBox(width: 4),
                                Text(
                                  canteen['distance']?.toString() ?? 'Unknown',
                                  style: const TextStyle(fontSize: 12, color: kTextMuted),
                                ),
                                const SizedBox(width: 12),
                                if (canteen['halal'] == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFF10B981)),
                                    ),
                                    child: const Text('Halal', style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.w600)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Hours and price range
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: kTextMuted),
                      const SizedBox(width: 6),
                      Text(
                        canteen['hours']?.toString() ?? 'Unknown',
                        style: const TextStyle(fontSize: 12, color: kTextMuted),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.restaurant, size: 14, color: kTextMuted),
                      const SizedBox(width: 6),
                      Text(
                        '${(canteen['floors'] as Map<String, dynamic>?)?.values.fold<int>(0, (sum, list) => sum + (list is List ? list.length : 0)) ?? 0} restaurants',
                        style: const TextStyle(fontSize: 12, color: kTextMuted),
                      ),
                    ],
                  ),
                ),
                // Restaurants preview
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Popular Restaurants', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kTextDark)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ((canteen['floors'] as Map<String, dynamic>?)?.values.expand((list) => list is List ? list : []).take(3).map((item) => 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: kSetelLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(item.toString(), style: const TextStyle(fontSize: 11, color: kTextDark)),
                          ),
                        ).toList() ?? []),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCanteenDetails(BuildContext context, Map<String, dynamic> canteen) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: kSetelLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(canteen['emoji']?.toString() ?? '🍜', style: const TextStyle(fontSize: 40)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                canteen['name']?.toString() ?? 'Unknown',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextDark),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${canteen['rating']?.toString() ?? '0.0'} Rating',
                                    style: const TextStyle(fontSize: 13, color: kTextDark),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (canteen['open'] == true) ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (canteen['open'] == true) ? Icons.check_circle : Icons.cancel,
                            color: (canteen['open'] == true) ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (canteen['open'] == true) ? 'Currently Open' : 'Currently Closed',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: (canteen['open'] == true) ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Operating Hours: ${canteen['hours']?.toString() ?? 'Unknown'}',
                                  style: const TextStyle(fontSize: 12, color: kTextMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Info
                    Row(
                      children: [
                        Expanded(
                          child: _infoCard(Icons.directions_walk, canteen['distance']?.toString() ?? 'Unknown', AppLocalizations.of(context).distance),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoCard(Icons.restaurant, '${(canteen['floors'] as Map<String, dynamic>?)?.values.fold<int>(0, (sum, list) => sum + (list is List ? list.length : 0)) ?? 0} restaurants', 'Total'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Restaurants by floor
                    Text('Restaurants by Floor', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark)),
                    const SizedBox(height: 16),
                    ...((canteen['floors'] as Map<String, dynamic>?)?.entries ?? []).map((entry) => 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kPrimary),
                          ),
                          const SizedBox(height: 8),
                          ...(entry.value as List).map((restaurant) => 
                            GestureDetector(
                              onTap: () => _showRestaurantDetails(context, restaurant.toString()),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8, left: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: kSetelGreen,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        restaurant.toString(),
                                        style: const TextStyle(fontSize: 14, color: kTextDark),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, size: 16, color: kTextMuted),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Action buttons
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NavigationScreen(initialLocation: CampusLocations.getLocationById(canteen['id']?.toString() ?? '')),
                            ),
                          );
                        },
                        icon: const Icon(Icons.navigation, size: 18),
                        label: Text(AppLocalizations.of(context).navigate),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kSetelGreen),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestaurantDetails(BuildContext context, String restaurantName) {
    final restaurants = {
      'Kami Cemerlang': {
        'name': 'Kami Cemerlang',
        'hours': '7:00 AM - 9:00 PM',
        'halal': true,
        'rating': 4.3,
        'menu': [
          {'name': 'Nasi Lemak Special', 'price': 'RM 8.50'},
          {'name': 'Chicken Rice', 'price': 'RM 7.00'},
          {'name': 'Mee Goreng Mamak', 'price': 'RM 6.50'},
          {'name': 'Roti Canai', 'price': 'RM 2.00'},
          {'name': 'Teh Tarik', 'price': 'RM 3.00'},
          {'name': 'Nasi Goreng Kampung', 'price': 'RM 8.00'},
        ]
      },
      'Subway': {
        'name': 'Subway',
        'hours': '8:00 AM - 9:00 PM',
        'halal': true,
        'rating': 4.5,
        'menu': [
          {'name': 'Italian B.M.T', 'price': 'RM 18.90'},
          {'name': 'Chicken Teriyaki', 'price': 'RM 16.90'},
          {'name': 'Tuna', 'price': 'RM 17.90'},
          {'name': 'Veggie Delite', 'price': 'RM 12.90'},
          {'name': 'Meatball Marinara', 'price': 'RM 15.90'},
          {'name': 'Cookies', 'price': 'RM 3.50'},
        ]
      },
      'Keluang Station': {
        'name': 'Keluang Station',
        'hours': '7:30 AM - 8:30 PM',
        'halal': true,
        'rating': 4.1,
        'menu': [
          {'name': 'Nasi Goreng Ayam', 'price': 'RM 7.50'},
          {'name': 'Mee Goreng', 'price': 'RM 6.00'},
          {'name': 'Kuey Teow Goreng', 'price': 'RM 7.00'},
          {'name': 'Nasi Lemak', 'price': 'RM 5.50'},
          {'name': 'Sirap Bandung', 'price': 'RM 2.50'},
        ]
      },
      'Under Tree': {
        'name': 'Under Tree',
        'hours': '10:00 AM - 6:00 PM',
        'halal': true,
        'rating': 4.2,
        'menu': [
          {'name': 'Western Chicken Chop', 'price': 'RM 12.00'},
          {'name': 'Fish & Chips', 'price': 'RM 13.00'},
          {'name': 'Spaghetti Bolognese', 'price': 'RM 11.00'},
          {'name': 'Chicken Burger', 'price': 'RM 9.00'},
          {'name': 'Lemon Tea', 'price': 'RM 4.00'},
        ]
      },
      'Uni Hotpot': {
        'name': 'Uni Hotpot',
        'hours': '11:00 AM - 9:00 PM',
        'halal': true,
        'rating': 4.4,
        'menu': [
          {'name': 'Individual Hotpot (Chicken)', 'price': 'RM 15.00'},
          {'name': 'Individual Hotpot (Beef)', 'price': 'RM 18.00'},
          {'name': 'Individual Hotpot (Seafood)', 'price': 'RM 20.00'},
          {'name': 'Set for 2 (Chicken)', 'price': 'RM 28.00'},
          {'name': 'Set for 2 (Mixed)', 'price': 'RM 35.00'},
        ]
      },
      'Boombeach': {
        'name': 'Boombeach',
        'hours': '11:00 AM - 8:00 PM',
        'halal': true,
        'rating': 4.0,
        'menu': [
          {'name': 'Tom Yum Noodle', 'price': 'RM 8.00'},
          {'name': 'Clear Soup Noodle', 'price': 'RM 7.00'},
          {'name': 'Dry Noodle', 'price': 'RM 7.00'},
          {'name': 'Thai Tea', 'price': 'RM 5.00'},
          {'name': 'Mango Sticky Rice', 'price': 'RM 8.00'},
        ]
      },
      'Korean Resto': {
        'name': 'Korean Resto',
        'hours': '11:00 AM - 8:00 PM',
        'halal': true,
        'rating': 4.3,
        'menu': [
          {'name': 'Kimchi Jjigae', 'price': 'RM 15.00'},
          {'name': 'Bibimbap', 'price': 'RM 14.00'},
          {'name': 'Bulgogi Rice', 'price': 'RM 16.00'},
          {'name': 'Korean Fried Chicken', 'price': 'RM 18.00'},
          {'name': 'TteokbokKi', 'price': 'RM 12.00'},
        ]
      },
      'Japan Resto': {
        'name': 'Japan Resto',
        'hours': '11:00 AM - 8:00 PM',
        'halal': true,
        'rating': 4.2,
        'menu': [
          {'name': 'Chicken Katsu Don', 'price': 'RM 13.00'},
          {'name': 'Salmon Sashimi (5 pcs)', 'price': 'RM 18.00'},
          {'name': 'Tempura Udon', 'price': 'RM 12.00'},
          {'name': 'California Roll', 'price': 'RM 15.00'},
          {'name': 'Miso Soup', 'price': 'RM 4.00'},
        ]
      },
      'Kopitiam': {
        'name': 'Kopitiam',
        'hours': '7:00 AM - 5:00 PM',
        'halal': false,
        'rating': 4.1,
        'menu': [
          {'name': 'Nasi Lemak', 'price': 'RM 4.50'},
          {'name': 'Toast Set', 'price': 'RM 6.00'},
          {'name': 'Half Boiled Eggs', 'price': 'RM 3.00'},
          {'name': 'Kopi O', 'price': 'RM 2.50'},
          {'name': 'Teh O', 'price': 'RM 2.50'},
          {'name': 'Char Kuey Teow', 'price': 'RM 7.00'},
        ]
      },
      'Castle In The Sky': {
        'name': 'Castle In The Sky',
        'hours': '10:00 AM - 6:00 PM',
        'halal': false,
        'rating': 4.3,
        'menu': [
          {'name': 'Pork Chop Rice', 'price': 'RM 12.00'},
          {'name': 'Braised Pork Rice', 'price': 'RM 10.00'},
          {'name': 'Roasted Chicken Rice', 'price': 'RM 9.00'},
          {'name': 'Char Siew Rice', 'price': 'RM 10.00'},
          {'name': 'Wantan Noodle', 'price': 'RM 8.00'},
        ]
      },
      'Thai Taro': {
        'name': 'Thai Taro',
        'hours': '10:00 AM - 6:00 PM',
        'halal': true,
        'rating': 4.0,
        'menu': [
          {'name': 'Green Curry', 'price': 'RM 12.00'},
          {'name': 'Tom Yum Goong', 'price': 'RM 15.00'},
          {'name': 'Pad Thai', 'price': 'RM 10.00'},
          {'name': 'Pineapple Fried Rice', 'price': 'RM 11.00'},
          {'name': 'Thai Iced Tea', 'price': 'RM 5.00'},
        ]
      },
      'City Kitchen': {
        'name': 'City Kitchen',
        'hours': '10:00 AM - 8:00 PM',
        'halal': false,
        'rating': 4.2,
        'menu': [
          {'name': 'Chicken Rice', 'price': 'RM 8.00'},
          {'name': 'Roast Duck Rice', 'price': 'RM 12.00'},
          {'name': 'Wonton Noodle', 'price': 'RM 9.00'},
          {'name': 'Dim Sum (3 pcs)', 'price': 'RM 6.00'},
          {'name': 'Herbal Tea', 'price': 'RM 4.00'},
        ]
      },
      'Pork': {
        'name': 'Pork',
        'hours': '10:00 AM - 8:00 PM',
        'halal': false,
        'rating': 4.1,
        'menu': [
          {'name': 'Braised Pork Belly Rice', 'price': 'RM 11.00'},
          {'name': 'Sweet Sour Pork Rice', 'price': 'RM 10.00'},
          {'name': 'Pork Chop Rice', 'price': 'RM 12.00'},
          {'name': 'Minced Pork Rice', 'price': 'RM 9.00'},
        ]
      },
      'Noodle Green': {
        'name': 'Noodle Green',
        'hours': '10:00 AM - 8:00 PM',
        'halal': true,
        'rating': 4.0,
        'menu': [
          {'name': 'Vegetarian Noodle', 'price': 'RM 7.00'},
          {'name': 'Tofu Rice', 'price': 'RM 6.00'},
          {'name': 'Mixed Veg Rice', 'price': 'RM 7.00'},
          {'name': 'Fried Rice', 'price': 'RM 6.50'},
        ]
      },
      'Khababish': {
        'name': 'Khababish',
        'hours': '11:00 AM - 9:00 PM',
        'halal': true,
        'rating': 4.4,
        'menu': [
          {'name': 'Chicken Kebab Set', 'price': 'RM 15.00'},
          {'name': 'Lamb Kebab Set', 'price': 'RM 18.00'},
          {'name': 'Mixed Grill', 'price': 'RM 25.00'},
          {'name': 'Shawarma', 'price': 'RM 10.00'},
          {'name': 'Hummus', 'price': 'RM 6.00'},
        ]
      },
      'Thumbs Up': {
        'name': 'Thumbs Up',
        'hours': '11:00 AM - 9:00 PM',
        'halal': true,
        'rating': 4.2,
        'menu': [
          {'name': 'Fried Chicken (2 pcs)', 'price': 'RM 8.00'},
          {'name': 'Fried Chicken (3 pcs)', 'price': 'RM 11.00'},
          {'name': 'Chicken Wings (4 pcs)', 'price': 'RM 10.00'},
          {'name': 'Coleslaw', 'price': 'RM 4.00'},
          {'name': 'Mashed Potato', 'price': 'RM 4.00'},
        ]
      },
      'Four Fingers': {
        'name': 'Four Fingers',
        'hours': '11:00 AM - 9:00 PM',
        'halal': true,
        'rating': 4.3,
        'menu': [
          {'name': 'Chicken Wings (4 pcs)', 'price': 'RM 12.00'},
          {'name': 'Chicken Wings (6 pcs)', 'price': 'RM 17.00'},
          {'name': 'Chicken Wings (8 pcs)', 'price': 'RM 22.00'},
          {'name': 'Crispy Chicken Burger', 'price': 'RM 10.00'},
          {'name': 'Fries', 'price': 'RM 5.00'},
        ]
      },
      'Cloud Food': {
        'name': 'Cloud Food',
        'hours': '11:00 AM - 9:00 PM',
        'halal': true,
        'rating': 4.1,
        'menu': [
          {'name': 'Beef Burger', 'price': 'RM 12.00'},
          {'name': 'Chicken Burger', 'price': 'RM 10.00'},
          {'name': 'Fish Burger', 'price': 'RM 11.00'},
          {'name': 'Cheese Burger', 'price': 'RM 13.00'},
          {'name': 'Onion Rings', 'price': 'RM 6.00'},
        ]
      },
      'Coffee Bar': {
        'name': 'Coffee Bar',
        'hours': '9:00 AM - 8:00 PM',
        'halal': true,
        'rating': 4.5,
        'menu': [
          {'name': 'Latte', 'price': 'RM 12.00'},
          {'name': 'Cappuccino', 'price': 'RM 12.00'},
          {'name': 'Americano', 'price': 'RM 10.00'},
          {'name': 'Mocha', 'price': 'RM 13.00'},
          {'name': 'Espresso', 'price': 'RM 8.00'},
        ]
      },
      'Bakery': {
        'name': 'Bakery',
        'hours': '9:00 AM - 6:00 PM',
        'halal': true,
        'rating': 4.3,
        'menu': [
          {'name': 'Croissant', 'price': 'RM 5.00'},
          {'name': 'Pain au Chocolat', 'price': 'RM 6.00'},
          {'name': 'Danish', 'price': 'RM 5.50'},
          {'name': 'Muffin', 'price': 'RM 4.50'},
          {'name': 'Bagel', 'price': 'RM 4.00'},
        ]
      },
      'Ice Cream Station': {
        'name': 'Ice Cream Station',
        'hours': '10:00 AM - 8:00 PM',
        'halal': true,
        'rating': 4.4,
        'menu': [
          {'name': 'Single Scoop', 'price': 'RM 5.00'},
          {'name': 'Double Scoop', 'price': 'RM 8.00'},
          {'name': 'Triple Scoop', 'price': 'RM 11.00'},
          {'name': 'Waffle Cone', 'price': 'RM 3.00'},
          {'name': 'Sundae', 'price': 'RM 10.00'},
        ]
      },
    };
    
    final restaurant = restaurants[restaurantName];
    if (restaurant == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: kSetelLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text('🍽️', style: TextStyle(fontSize: 40)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant['name']?.toString() ?? 'Unknown',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextDark),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${restaurant['rating']?.toString() ?? '0.0'} Rating',
                                    style: const TextStyle(fontSize: 13, color: kTextDark),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (restaurant['halal'] == true) ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (restaurant['halal'] == true) ? Icons.check_circle : Icons.info,
                            color: (restaurant['halal'] == true) ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (restaurant['halal'] == true) ? 'Halal Certified' : 'Non-Halal',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: (restaurant['halal'] == true) ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Operating Hours: ${restaurant['hours']?.toString() ?? 'Unknown'}',
                                  style: const TextStyle(fontSize: 12, color: kTextMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Menu
                    Text('Menu', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark)),
                    const SizedBox(height: 16),
                    ...(restaurant['menu'] as List?)?.map((item) => 
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kSetelLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['name']?.toString() ?? 'Unknown',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kTextDark),
                              ),
                            ),
                            Text(
                              item['price']?.toString() ?? 'RM 0.00',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kPrimary),
                            ),
                          ],
                        ),
                      ),
                    ).toList() ?? [],
                    const SizedBox(height: 24),
                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Close'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kSetelGreen),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSetelLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: kSetelGreen, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: kTextMuted),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getRecommendedVenues(List<Map<String, dynamic>> venues) {
    return venues.where((venue) {
      // Filter by availability
      final isAvailable = venue['available'] == true;
      if (!isAvailable) return false;

      // Filter by venue type
      if (_selectedVenueType != null) {
        final venueType = venue['type']?.toString();
        if (venueType != _selectedVenueType) return false;
      }

      // Filter by capacity
      if (_requiredCapacity != null) {
        final capacity = venue['capacity'] as int?;
        if (capacity == null || capacity < _requiredCapacity!) return false;
      }

      // Filter by facilities
      if (_selectedFacilities.isNotEmpty) {
        final venueFacilities = (venue['facilities'] as List?)?.cast<String>() ?? [];
        final hasAllFacilities = _selectedFacilities.every((facility) =>
          venueFacilities.any((vf) => vf.toLowerCase().contains(facility.toLowerCase()))
        );
        if (!hasAllFacilities) return false;
      }

      return true;
    }).toList();
  }

  Widget _buildVenuesTab() {
    final venues = [
      {
        'name': 'Tan Hua Choon Auditorium',
        'emoji': '🎭',
        'capacity': 600,
        'type': 'Auditorium',
        'facilities': ['Projector', 'Sound System', 'Stage', 'Air Conditioning', 'Microphones', 'WiFi'],
        'location': 'Besides Block A1',
        'available': true,
      },
      {
        'name': 'Lecture Room B1#114',
        'emoji': '📚',
        'capacity': 200,
        'type': 'Class',
        'facilities': ['Projector', 'Sound System', 'Air Conditioning', 'Microphones', 'WiFi'],
        'location': 'Block B1 Level 1 #114',
        'available': true,
      },
      {
        'name': 'Lecture Room A1#G07',
        'emoji': '📚',
        'capacity': 120,
        'type': 'Lecture Hall',
        'facilities': ['Projector','Whiteboard', 'WiFi', 'Air Conditioning', 'Microphones'],
        'location': 'Block A1 Ground Floor',
        'available': false,
      },
      {
        'name': 'Lecture Room A2#G07',
        'emoji': '📚',
        'capacity': 120,
        'type': 'Lecture Hall',
        'facilities': ['Projector','Whiteboard', 'WiFi', 'Air Conditioning', 'Microphones'],
        'location': 'Block A2 Ground Floor',
        'available': false,
      },
      {
        'name': 'Lecture Room A4#G07',
        'emoji': '📚',
        'capacity': 120,
        'type': 'Lecture Hall',
        'facilities': ['Projector','Whiteboard', 'WiFi', 'Air Conditioning', 'Microphones'],
        'location': 'Block A4 Ground Floor',
        'available': false,
      },
      {
        'name': 'Lecture Room A5#G07',
        'emoji': '📚',
        'capacity': 120,
        'type': 'Lecture Hall',
        'facilities': ['Projector','Whiteboard', 'WiFi', 'Air Conditioning', 'Microphones'],
        'location': 'Block A5 Ground Floor',
        'available': false,
      },
      {
        'name': 'Lecture Room A1#G01',
        'emoji': '📚',
        'capacity': 120,
        'type': 'Lecture Hall',
        'facilities': ['Projector','Whiteboard', 'WiFi', 'Air Conditioning', 'Microphones'],
        'location': 'Block A1 Ground Floor',
        'available': false,
      },
      {
        'name': 'Lecture Room A2#G01',
        'emoji': '📚',
        'capacity': 120,
        'type': 'Lecture Hall',
        'facilities': ['Projector','Whiteboard', 'WiFi', 'Air Conditioning', 'Microphones'],
        'location': 'Block A2 Ground Floor',
        'available': false,
      },
      {
        'name': 'Lecture Room A4#G01',
        'emoji': '📚',
        'capacity': 120,
        'type': 'Lecture Hall',
        'facilities': ['Projector','Whiteboard', 'WiFi', 'Air Conditioning', 'Microphones'],
        'location': 'Block A4 Ground Floor',
        'available': false,
      },
      {
        'name': 'Lecture Room A5#G01',
        'emoji': '📚',
        'capacity': 120,
        'type': 'Lecture Hall',
        'facilities': ['Projector','Whiteboard', 'WiFi', 'Air Conditioning', 'Microphones'],
        'location': 'Block A5 Ground Floor',
        'available': false,
      },
      {
        'name': 'Multi-Purpose Hall B1#101',
        'emoji': '🎪',
        'capacity': 200,
        'type': 'Event Space',
        'facilities': ['Sound System', 'Lighting', 'Air Conditioning', 'Tables & Chairs', 'Projector','Whiteboard','Microphones'],
        'location': 'Building B, Level 1 #101',
        'available': true,
      },
      {
        'name': 'Track & Field',
        'emoji': '🌳',
        'capacity': 800,
        'type': 'Outdoor',
        'facilities': ['Stage', 'Lighting', 'Covered Area'],
        'location': 'XMUM Track & Field beside Basketball Court',
        'available': true,
      },
      {
        'name': 'Block A Classroom',
        'emoji': '📚',
        'capacity': 70,
        'type': 'Indoor',
        'facilities': ['Projector','Whiteboard', 'WiFi', 'Air Conditioning', 'Microphones'],
        'location': 'XMUM A Block Classroom',
        'available': true,
      },
      {
        'name': 'Block B Classroom',
        'emoji': '📚',
        'capacity': 50,
        'type': 'Indoor',
        'facilities': ['Projector','Whiteboard', 'WiFi', 'Air Conditioning', 'Microphones'],
        'location': 'XMUM B Block Classroom',
        'available': true,
      },
    ];

    // Filter venues based on recommendations
    List<Map<String, dynamic>> filteredVenues = venues;
    if (_filtersApplied) {
      filteredVenues = _getRecommendedVenues(venues);
    }

    return Column(
      children: [
        // Recommendation form
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Find Your Perfect Venue',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VenueFilterScreen(
                            initialVenueType: _selectedVenueType,
                            initialCapacity: _requiredCapacity,
                            initialFacilities: _selectedFacilities,
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _selectedVenueType = result['venueType'];
                          _requiredCapacity = result['capacity'];
                          _selectedFacilities = List<String>.from(result['facilities']);
                          _filtersApplied = _selectedVenueType != null || _requiredCapacity != null || _selectedFacilities.isNotEmpty;
                        });
                      }
                    },
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('Filter'),
                    style: TextButton.styleFrom(foregroundColor: kPrimary),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Venue list
        Expanded(
          child: filteredVenues.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: kTextMuted),
                      const SizedBox(height: 16),
                      Text(
                        'No venues match your criteria',
                        style: TextStyle(fontSize: 16, color: kTextMuted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your filters',
                        style: TextStyle(fontSize: 13, color: kTextMuted),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  itemCount: filteredVenues.length,
                  itemBuilder: (context, index) {
                    final venue = filteredVenues[index];
                    final isAvailable = venue['available'] as bool;
                    final isRecommended = _showRecommendations;
                    
                    return GestureDetector(
                      onTap: () => _showVenueDetails(context, venue),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: isRecommended
                              ? Border.all(color: kPrimary, width: 2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: kCardShadow,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with emoji and availability
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: kSetelLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(venue['emoji']?.toString() ?? '🏢', style: const TextStyle(fontSize: 32)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          venue['name']?.toString() ?? 'Unknown',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextDark),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isAvailable ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isAvailable ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                          ),
                                        ),
                                        child: Text(
                                          isAvailable ? AppLocalizations.of(context).currentlyOpen : AppLocalizations.of(context).currentlyClosed,
                                          style: TextStyle(
                                            color: isAvailable ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.category_outlined, size: 14, color: kTextMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        venue['type']?.toString() ?? 'Unknown',
                                        style: const TextStyle(fontSize: 12, color: kTextMuted),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(Icons.people_outline, size: 14, color: kTextMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${venue['capacity']} pax',
                                        style: const TextStyle(fontSize: 12, color: kTextMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_outlined, size: 14, color: kTextMuted),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          venue['location']?.toString() ?? 'Unknown',
                                          style: const TextStyle(fontSize: 12, color: kTextMuted),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Facilities preview
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context).facilities, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kTextDark)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (venue['facilities'] as List<String>).take(4).map((facility) => 
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: kSetelLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(facility, style: const TextStyle(fontSize: 11, color: kSetelDark)),
                                ),
                              ).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 13, color: isSelected ? kWhite : kTextDark)),
        selected: isSelected,
        onSelected: (selected) {},
        selectedColor: kSetelGreen,
        backgroundColor: kWhite,
        checkmarkColor: kWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
    );
  }

  void _showVenueDetails(BuildContext context, Map<String, dynamic> venue) {
    final isAvailable = venue['available'] == true;
    
    // Get the location for this venue
    CampusLocation? venueLocation;
    final locationName = venue['location']?.toString() ?? '';
    
    // Map venue location strings to CampusLocation objects
    if (locationName.contains('Besides Block A1')) {
      venueLocation = CampusLocations.getLocationById('THC');
    } else if (locationName.contains('Block A1')) {
      venueLocation = CampusLocations.getLocationById('A1');
    } else if (locationName.contains('Block A2')) {
      venueLocation = CampusLocations.getLocationById('A2');
    } else if (locationName.contains('Block A4')) {
      venueLocation = CampusLocations.getLocationById('A4');
    } else if (locationName.contains('Block A5')) {
      venueLocation = CampusLocations.getLocationById('A5');
    } else if (locationName.contains('#101') || locationName.contains('B1-101')) {
      venueLocation = CampusLocations.getLocationById('B1-101');
    } else if (locationName.contains('#114') || locationName.contains('B1-114')) {
      venueLocation = CampusLocations.getLocationById('B1-114');
    } else if (locationName.contains('Track & Field')) {
      venueLocation = CampusLocations.getLocationById('Track & Field');
    } else if (locationName.contains('XMUM A Block')) {
      venueLocation = CampusLocations.getLocationById('A1');
    } else if (locationName.contains('XMUM B')) {
      venueLocation = CampusLocations.getLocationById('B1');
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: kSetelLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(venue['emoji']?.toString() ?? '🏢', style: const TextStyle(fontSize: 40)),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      venue['name']?.toString() ?? 'Unknown',
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kTextDark),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isAvailable ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isAvailable ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isAvailable ? Icons.check_circle : Icons.cancel,
                                            size: 16,
                                            color: isAvailable ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isAvailable ? AppLocalizations.of(context).availableForBooking : AppLocalizations.of(context).currentlyBooked,
                                            style: TextStyle(
                                              color: isAvailable ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Info cards
                          Row(
                            children: [
                              Expanded(
                                child: _venueInfoCard(Icons.people_outline, '${venue['capacity']}', AppLocalizations.of(context).capacity),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _venueInfoCard(Icons.category_outlined, venue['type']?.toString() ?? 'Unknown', AppLocalizations.of(context).type),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _venueInfoCard(Icons.location_on_outlined, venue['location']?.toString() ?? 'Unknown', AppLocalizations.of(context).location),
                        ],
                      ),
                    ),
                    // Facilities
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context).availableFacilities, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark)),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: ((venue['facilities'] as List?)?.cast<String>() ?? []).map((facility) => 
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: kSetelLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: kSetelGreen.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 16, color: kSetelGreen),
                                    const SizedBox(width: 8),
                                    Text(facility, style: const TextStyle(fontSize: 13, color: kTextDark)),
                                  ],
                                ),
                              ),
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Action buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        if (venueLocation != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NavigationScreen(initialLocation: venueLocation),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: Text(AppLocalizations.of(context).viewOnMap),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kSetelGreen),
                        foregroundColor: kSetelGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isAvailable ? () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context).bookingRequestSent), backgroundColor: Colors.green),
                        );
                      } : null,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(AppLocalizations.of(context).bookVenue),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAvailable ? kSetelGreen : Colors.grey,
                        foregroundColor: kWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _venueInfoCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSetelLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kSetelGreen, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTextDark),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: kTextMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    final display = locationDisplayFor(_selectedMapLocation);

    return FutureBuilder<Set<Marker>>(
      future: _buildMarkers(),
      builder: (context, snapshot) {
        final markers = snapshot.data ?? {};

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedMapLocation.position,
                zoom: 16.5,
              ),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              cameraTargetBounds: CameraTargetBounds(
                LatLngBounds(
                  southwest: const LatLng(2.832899 - 0.0045, 101.702819 - 0.0045),
                  northeast: const LatLng(2.832899 + 0.0045, 101.702819 + 0.0045),
                ),
              ),
              minMaxZoomPreference: const MinMaxZoomPreference(16, 19),
              onMapCreated: (controller) {
                _mapController = controller;
                controller.setMapStyle('''
                  [
                    {
                      "featureType": "poi",
                      "elementType": "all",
                      "stylers": [
                        {
                          "visibility": "off"
                        }
                      ]
                    },
                    {
                      "featureType": "transit",
                      "elementType": "all",
                      "stylers": [
                        {
                          "visibility": "off"
                        }
                      ]
                    }
                  ]
                ''');
              },
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: [
                    ParkSearchBar(
                      hint: 'Where do you want to go?',
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const NavigationScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 200,
              child: FloatingActionButton.small(
                heroTag: 'my_location',
                backgroundColor: kWhite,
                foregroundColor: kPrimary,
                onPressed: () {
                  _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: _selectedMapLocation.position, zoom: 17),
                    ),
                  );
                },
                child: const Icon(Icons.my_location_rounded),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 80,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: _cardHeight,
                child: _buildMapBottomCard(display),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Set<Marker>> _buildMarkers() async {
    final markers = <Marker>{};

    // Add current location marker if available
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current GPS position',
          ),
        ),
      );
    }

    for (final loc in _mapLocations) {
      final isSelected = loc.id == _selectedMapLocation.id;
      final icon = await _getMarkerIconForCategory(loc.category, isSelected: isSelected);

      markers.add(
        Marker(
          markerId: MarkerId(loc.id),
          position: loc.position,
          onTap: () {
            setState(() => _selectedMapLocation = loc);
            _updateSaveState();
          },
          icon: icon,
          zIndex: isSelected ? 2 : 1,
        ),
      );

      // Add glowing circle for selected marker
      if (isSelected) {
        markers.add(
          Marker(
            markerId: MarkerId('${loc.id}_glow'),
            position: loc.position,
            icon: await _getGlowMarker(),
            zIndex: 1,
            anchor: const Offset(0.5, 0.5),
          ),
        );
      }
    }

    return markers;
  }

  void _showLocationDetails(BuildContext context, LocationDisplay display) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationDetailScreen(location: _selectedMapLocation),
      ),
    );
  }

  Future<void> _toggleSaveLocation(String locationId) async {
    final uid = _service.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save locations'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final user = await _service.getUserProfile(uid);
      if (user == null) return;

      final savedLocations = List<String>.from(user.savedLocations ?? []);

      if (savedLocations.contains(locationId)) {
        savedLocations.remove(locationId);
        await _service.updateUserProfile(uid, {'savedLocations': savedLocations});
        AudioService().playSoundEffect(SoundEffect.delete);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location removed from saved'), backgroundColor: Colors.green),
        );
        if (locationId == _selectedMapLocation.id) {
          _isCurrentLocationSaved = false;
          if (mounted) setState(() {});
        }
      } else {
        savedLocations.add(locationId);
        await _service.updateUserProfile(uid, {'savedLocations': savedLocations});
        AudioService().playSoundEffect(SoundEffect.save);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location saved'), backgroundColor: Colors.green),
        );
        if (locationId == _selectedMapLocation.id) {
          _isCurrentLocationSaved = true;
          if (mounted) setState(() {});
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<bool> _isLocationSaved(String locationId) async {
    final uid = _service.currentUser?.uid;
    if (uid == null) return false;
    
    final user = await _service.getUserProfile(uid);
    if (user == null) return false;
    
    return (user.savedLocations ?? []).contains(locationId);
  }

  void _showMarkerOptions(BuildContext context, CampusLocation location) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: kDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              location.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              location.category,
              style: const TextStyle(fontSize: 14, color: kTextMuted),
            ),
            const SizedBox(height: 20),
            FutureBuilder<bool>(
              future: _isLocationSaved(location.id),
              builder: (context, snapshot) {
                final isSaved = snapshot.data ?? false;
                return ElevatedButton.icon(
                  onPressed: () {
                    _toggleSaveLocation(location.id);
                    Navigator.pop(context);
                  },
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                  label: Text(isSaved ? 'Remove from Saved' : 'Save Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: kWhite,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _selectedMapLocation = location);
                _updateSaveState();
                Navigator.pop(context);
                _animateToHeight(_minCardHeight);
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('View Details'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Animates _cardHeight smoothly from its current value to [targetHeight].
  /// Cancels any in-flight snap animation first so rapid taps/drags never
  /// fight each other or compound into jittery motion.
  void _animateToHeight(double targetHeight) {
    if (_cardAnimation != null && _cardAnimListener != null) {
      _cardAnimation!.removeListener(_cardAnimListener!);
    }
    final animation = Tween<double>(begin: _cardHeight, end: targetHeight)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(_cardAnimController);
    _cardAnimation = animation;
    _cardAnimListener = () {
      setState(() => _cardHeight = animation.value);
    };
    animation.addListener(_cardAnimListener!);
    _cardAnimController.forward(from: 0);
  }

  void _onCardDragStart(DragStartDetails details) {
    // Cancel any in-flight snap animation so the drag takes over cleanly.
    _cardAnimController.stop();
    _dragStartY = details.globalPosition.dy;
    _dragStartHeight = _cardHeight;
  }

  void _onCardDragUpdate(DragUpdateDetails details) {
    final deltaY = _dragStartY - details.globalPosition.dy;
    setState(() {
      _cardHeight = (_dragStartHeight + deltaY).clamp(_minCardHeight, _maxCardHeight);
    });
  }

  void _onCardDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final threshold = _minCardHeight + (_maxCardHeight - _minCardHeight) * 0.5;

    if (velocity < -500) {
      // Dragging up fast - expand to max
      _animateToHeight(_maxCardHeight);
      AudioService().playSoundEffect(SoundEffect.cardOpen);
    } else if (velocity > 500) {
      // Dragging down fast - collapse to min
      _animateToHeight(_minCardHeight);
      AudioService().playSoundEffect(SoundEffect.cardClose);
    } else if (_cardHeight < threshold) {
      // Below halfway - snap to min
      _animateToHeight(_minCardHeight);
      if (_cardHeight > _minCardHeight + 20) {
        AudioService().playSoundEffect(SoundEffect.cardClose);
      }
    } else {
      // Above halfway - snap to max
      _animateToHeight(_maxCardHeight);
      if (_cardHeight < _maxCardHeight - 50) {
        AudioService().playSoundEffect(SoundEffect.cardOpen);
      }
    }
  }

  Widget _buildMapBottomCard(LocationDisplay display) {
    final isExpanded = _cardHeight > _minCardHeight + 50;
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle area - always visible for consistency
          GestureDetector(
            onVerticalDragStart: _onCardDragStart,
            onVerticalDragUpdate: _onCardDragUpdate,
            onVerticalDragEnd: _onCardDragEnd,
            onTap: () => _animateToHeight(isExpanded ? _minCardHeight : _maxCardHeight),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: kDivider.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content area - same layout for both states, just more content when expanded
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 0, 20, isExpanded ? 24 : 44),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with emoji and info - always shown
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kMapGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: kMapGreen,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(display.emoji, style: const TextStyle(fontSize: 26)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isExpanded)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: kGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${categoryLabel(_selectedMapLocation.category)} ${display.status}',
                                    style: const TextStyle(
                                      color: kGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (isExpanded) const SizedBox(height: 6),
                              Text(
                                _selectedMapLocation.name,
                                style: TextStyle(
                                  fontSize: isExpanded ? 17 : 15,
                                  fontWeight: FontWeight.bold,
                                  color: kTextDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              HoursBadge(hours: display.hours, compact: !isExpanded),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: kPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => _toggleSaveLocation(_selectedMapLocation.id),
                            icon: Icon(_isCurrentLocationSaved ? Icons.bookmark : Icons.bookmark_border),
                            color: kPrimary,
                            iconSize: 20,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Additional content only shown when expanded
                  if (isExpanded) ...[
                    const SizedBox(height: 20),
                    // Description section
                    _buildInfoSection(
                      'Description',
                      _selectedMapLocation.description,
                      Icons.description_outlined,
                    ),
                    const SizedBox(height: 16),
                    // Category section
                    _buildInfoSection(
                      'Category',
                      categoryLabel(_selectedMapLocation.category),
                      Icons.category_outlined,
                    ),
                    const SizedBox(height: 24),
                    // Action button
                    ParkButton(
                      label: 'Get directions',
                      icon: Icons.navigation_rounded,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NavigationScreen(initialLocation: _selectedMapLocation),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: kPrimary),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kTextDark,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kGrey.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: kTextDark,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}