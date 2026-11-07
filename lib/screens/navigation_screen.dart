import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/services.dart';
import '../theme.dart';
import '../models/campus_location.dart';
import '../l10n/app_localizations.dart';
import '../utils/xmum_page_route.dart';
import '../widgets/xmum_animations.dart';
import '../services/firebase_service.dart';

class NavigationScreen extends StatefulWidget {
  final CampusLocation? initialLocation;

  const NavigationScreen({super.key, this.initialLocation});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  CampusLocation? _startLocation;
  CampusLocation? _endLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  bool _isNavigating = false;
  String _distance = '';
  String _duration = '';
  bool _routeCalculated = false;
  final _service = FirebaseService();

  late final AnimationController _panelCtrl;
  late final Animation<double> _panelSlide;
  late final AnimationController _swapCtrl;

  final String _googleApiKey = 'AIzaSyDZjiuSGzujEaKR2oq9TPreovpV-8atSFY';

  @override
  void initState() {
    super.initState();
    _panelCtrl = AnimationController(
      vsync: this,
      duration: kAnimMedium,
    );
    _panelSlide = CurvedAnimation(parent: _panelCtrl, curve: kAnimCurve);
    _swapCtrl = AnimationController(
      vsync: this,
      duration: kAnimMedium,
    );
    _panelCtrl.forward();

    if (widget.initialLocation != null) {
      _endLocation = widget.initialLocation;
      _getCurrentLocation(); // Get current GPS location as start
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _panelCtrl.dispose();
    _swapCtrl.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _startLocation = CampusLocation(
        id: 'current_location',
        name: 'Your Location',
        description: 'Current GPS position',
        position: LatLng(position.latitude, position.longitude),
        category: 'Current',
      );
    });

    await _updateMarkers();

    // Automatically calculate route if both start and end locations are set
    if (_endLocation != null) {
      _getPolyline();
    }
  }

  Future<void> _getPolyline() async {
    if (_startLocation == null || _endLocation == null) return;

    setState(() {
      _isNavigating = true;
      _polylineCoordinates = [];
      _routeCalculated = false;
    });

    try {
      final polylinePoints = PolylinePoints();
      final result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(
            _startLocation!.position.latitude,
            _startLocation!.position.longitude,
          ),
          destination: PointLatLng(
            _endLocation!.position.latitude,
            _endLocation!.position.longitude,
          ),
          mode: TravelMode.walking,
        ),
        googleApiKey: _googleApiKey,
      );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              color: kPrimary,
              width: 5,
              jointType: JointType.round,
              endCap: Cap.roundCap,
              startCap: Cap.roundCap,
              points: _polylineCoordinates,
            ),
          );
        });

        _calculateDistanceAndDuration();

        if (_mapController != null && _polylineCoordinates.length >= 2) {
          final bounds = _boundsFromLatLngList(_polylineCoordinates);
          await _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 80),
          );
        }
      } else {
        // Fallback: Calculate direct distance if API returns no points
        debugPrint('No polyline points returned, using direct distance');
        _polylineCoordinates.add(_startLocation!.position);
        _polylineCoordinates.add(_endLocation!.position);
        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              color: kPrimary,
              width: 5,
              jointType: JointType.round,
              endCap: Cap.roundCap,
              startCap: Cap.roundCap,
              points: _polylineCoordinates,
            ),
          );
        });
        _calculateDistanceAndDuration();
      }
    } catch (e) {
      debugPrint('Error getting polyline: $e');
      // Fallback: Calculate direct distance on error
      _polylineCoordinates.add(_startLocation!.position);
      _polylineCoordinates.add(_endLocation!.position);
      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: kPrimary,
            width: 5,
            jointType: JointType.round,
            endCap: Cap.roundCap,
            startCap: Cap.roundCap,
            points: _polylineCoordinates,
          ),
        );
      });
      _calculateDistanceAndDuration();
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
          _routeCalculated = _distance.isNotEmpty;
        });
      }
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double minLat = list.first.latitude;
    double maxLat = list.first.latitude;
    double minLng = list.first.longitude;
    double maxLng = list.first.longitude;

    for (final point in list) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _calculateDistanceAndDuration() {
    if (_polylineCoordinates.isEmpty) return;

    double totalDistance = 0;
    for (int i = 0; i < _polylineCoordinates.length - 1; i++) {
      totalDistance += _calculateDistance(
        _polylineCoordinates[i],
        _polylineCoordinates[i + 1],
      );
    }

    // Walking speed: approximately 5 km/h = 83.33 meters per minute
    final walkingTimeMinutes = (totalDistance / 1000) / 5 * 60;

    setState(() {
      _distance = totalDistance < 1000
          ? '${totalDistance.toStringAsFixed(0)}m'
          : '${(totalDistance / 1000).toStringAsFixed(1)}km';
      _duration = walkingTimeMinutes < 1
          ? '< 1 min'
          : '${walkingTimeMinutes.toStringAsFixed(0)} min';
    });

    // Save route to history
    _saveRouteToHistory(totalDistance, _duration);
  }

  Future<void> _saveRouteToHistory(double distance, String duration) async {
    final uid = _service.currentUser?.uid;
    if (uid == null || _startLocation == null || _endLocation == null) return;

    try {
      final user = await _service.getUserProfile(uid);
      if (user == null) return;

      final newRoute = {
        'startLocation': _startLocation!.name,
        'endLocation': _endLocation!.name,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'distance': distance / 1000, // Convert to km
        'duration': duration,
      };

      final updatedHistory = [newRoute, ...user.routeHistory];
      // Keep only last 50 routes
      if (updatedHistory.length > 50) {
        updatedHistory.removeRange(50, updatedHistory.length);
      }

      await _service.updateUserProfile(uid, {'routeHistory': updatedHistory});
    } catch (e) {
      debugPrint('Error saving route to history: $e');
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000;
    final lat1 = start.latitude * math.pi / 180;
    final lat2 = end.latitude * math.pi / 180;
    final deltaLat = (end.latitude - start.latitude) * math.pi / 180;
    final deltaLon = (end.longitude - start.longitude) * math.pi / 180;

    final a = math.pow(math.sin(deltaLat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(deltaLon / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
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

  Future<BitmapDescriptor> _getMarkerIconForCategory(String category) async {
    switch (category) {
      case 'Current':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      case 'Office':
        return await _getResizedMarker('assets/images/marker_office.png', size: 100);
      case 'Dorm':
        return await _getResizedMarker('assets/images/marker_dorm.png', size: 100);
      case 'Food':
        return await _getResizedMarker('assets/images/marker_food.png', size: 100);
      case 'Class':
        return await _getResizedMarker('assets/images/marker_class.png', size: 100);
      case 'Facilities':
        return await _getResizedMarker('assets/images/marker_facilities.png', size: 100);
      case 'Entrance':
        return await _getResizedMarker('assets/images/marker_entrance.png', size: 100);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
  }

  Future<void> _updateMarkers() async {
    setState(() {
      _markers.clear();
    });

    if (_startLocation != null) {
      final icon = await _getMarkerIconForCategory(_startLocation!.category);
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId('start_${_startLocation!.id}'),
            position: _startLocation!.position,
            infoWindow: InfoWindow(
              title: 'Start: ${_startLocation!.name}',
              snippet: _startLocation!.description,
            ),
            icon: icon,
          ),
        );
      });
    }

    if (_endLocation != null) {
      final icon = await _getMarkerIconForCategory(_endLocation!.category);
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId('end_${_endLocation!.id}'),
            position: _endLocation!.position,
            infoWindow: InfoWindow(
              title: 'Destination: ${_endLocation!.name}',
              snippet: _endLocation!.description,
            ),
            icon: icon,
          ),
        );
      });
    }
  }

  Future<void> _swapLocations() async {
    if (_startLocation == null && _endLocation == null) return;

    await _swapCtrl.forward(from: 0);
    setState(() {
      final temp = _startLocation;
      _startLocation = _endLocation;
      _endLocation = temp;
      _polylines.clear();
      _polylineCoordinates.clear();
      _distance = '';
      _duration = '';
      _routeCalculated = false;
    });
    await _updateMarkers();
    await _swapCtrl.reverse();
  }

  void _showLocationSelector(bool isStart) async {
    final result = await xmumShowModal<dynamic>(
      context,
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black54),
            ),
            _LocationSelectorSheet(
              locations: CampusLocations.allLocations
                  .where((l) => ['Food', 'Facilities', 'Entrance', 'Dorm', 'Class', 'Office'].contains(l.category))
                  .toList(),
              showCurrentLocation: isStart,
            ),
          ],
        ),
      ),
    );

    if (result == 'current_location') {
      await _getCurrentLocation();
    } else if (result is CampusLocation) {
      setState(() {
        if (isStart) {
          _startLocation = result;
        } else {
          _endLocation = result;
        }
        _polylines.clear();
        _polylineCoordinates.clear();
        _distance = '';
        _duration = '';
        _routeCalculated = false;
      });
      await _updateMarkers();

      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: result.position, zoom: 17),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.navigateCampus,
          style: xmumFont(fontWeight: FontWeight.w700, color: kWhite),
        ),
        foregroundColor: kWhite,
        iconTheme: const IconThemeData(color: kWhite),
        elevation: 0,
        backgroundColor: kPrimary,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: CampusLocations.xmumCenter,
              zoom: 16,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
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
          if (_isNavigating)
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
              left: 0,
              right: 0,
              child: const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(kAccent),
                minHeight: 3,
              ),
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 12,
            left: 16,
            right: 16,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.15),
                end: Offset.zero,
              ).animate(_panelSlide),
              child: FadeTransition(
                opacity: _panelSlide,
                child: _buildRoutePanel(context, l10n, isDark),
              ),
            ),
          ),
          if (_routeCalculated)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: _buildRouteSummary(l10n, isDark),
            ),
        ],
      ),
    );
  }

  Widget _buildRoutePanel(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? kDarkCard.withValues(alpha: 0.96) : kWhite.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(kRadiusLg),
        border: Border.all(
          color: isDark ? kDarkDivider : kPrimary.withValues(alpha: 0.08),
        ),
        boxShadow: const [kMediumShadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _RouteTimeline(isDark: isDark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _LocationField(
                      label: l10n.from,
                      location: _startLocation,
                      accentColor: kPrimary,
                      isDark: isDark,
                      onTap: () => _showLocationSelector(true),
                    ),
                    const SizedBox(height: 10),
                    _LocationField(
                      label: l10n.to,
                      location: _endLocation,
                      accentColor: kSecondary,
                      isDark: isDark,
                      onTap: () => _showLocationSelector(false),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              RotationTransition(
                turns: Tween<double>(begin: 0, end: 0.5).animate(
                  CurvedAnimation(parent: _swapCtrl, curve: kAnimCurve),
                ),
                child: XmumScaleTap(
                  scale: 0.9,
                  onTap: _swapLocations,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kPrimary.withValues(alpha: 0.12),
                          kAccent.withValues(alpha: 0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: kPrimary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: const Icon(
                      Icons.swap_vert_rounded,
                      color: kPrimary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          XmumScaleTap(
            onTap: _startLocation != null &&
                    _endLocation != null &&
                    !_isNavigating
                ? _getPolyline
                : null,
            child: AnimatedContainer(
              duration: kAnimFast,
              curve: kAnimCurve,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: _startLocation != null &&
                        _endLocation != null &&
                        !_isNavigating
                    ? xmumPremiumGradient
                    : null,
                color: _startLocation == null ||
                        _endLocation == null ||
                        _isNavigating
                    ? (isDark ? kDarkSurface : kGreyLight)
                    : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _startLocation != null &&
                        _endLocation != null &&
                        !_isNavigating
                    ? [
                        BoxShadow(
                          color: kPrimary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isNavigating)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                      ),
                    )
                  else ...[
                    Icon(
                      Icons.directions_walk_rounded,
                      size: 20,
                      color: _startLocation != null && _endLocation != null
                          ? kWhite
                          : (isDark ? kDarkTextMuted : kTextMuted),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.getDirections,
                      style: xmumFont(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: _startLocation != null && _endLocation != null
                            ? kWhite
                            : (isDark ? kDarkTextMuted : kTextMuted),
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

  Widget _buildRouteSummary(AppLocalizations l10n, bool isDark) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: kAnimMedium,
      curve: kAnimSpring,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + value * 0.1,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: xmumPremiumGradient,
          borderRadius: BorderRadius.circular(kRadiusLg),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _RouteStat(
                icon: Icons.straighten_rounded,
                label: l10n.distance,
                value: _distance,
              ),
            ),
            Container(
              width: 1,
              height: 44,
              color: kWhite.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _RouteStat(
                icon: Icons.schedule_rounded,
                label: l10n.duration,
                value: _duration,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kWhite.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.directions_walk_rounded,
                color: kWhite,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteTimeline extends StatelessWidget {
  final bool isDark;

  const _RouteTimeline({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: kPrimary,
            shape: BoxShape.circle,
            border: Border.all(color: kWhite, width: 2),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        Container(
          width: 2,
          height: 36,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimary, kSecondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: kSecondary,
            shape: BoxShape.circle,
            border: Border.all(color: kWhite, width: 2),
            boxShadow: [
              BoxShadow(
                color: kSecondary.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationField extends StatelessWidget {
  final String label;
  final CampusLocation? location;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  const _LocationField({
    required this.label,
    required this.location,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return XmumScaleTap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: kAnimFast,
        curve: kAnimCurve,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? kDarkSurface : kGreyLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: location != null
                ? accentColor.withValues(alpha: 0.25)
                : (isDark ? kDarkDivider : kDivider),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: xmumFont(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: accentColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              location?.name ?? 'Select location',
              style: xmumFont(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: location != null
                    ? (isDark ? kDarkText : kTextDark)
                    : (isDark ? kDarkTextMuted : kTextMuted),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RouteStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: kWhite.withValues(alpha: 0.8), size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: xmumFont(
            fontSize: 10,
            color: kWhite.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: xmumFont(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: kWhite,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _LocationSelectorSheet extends StatefulWidget {
  final List<CampusLocation> locations;
  final bool showCurrentLocation;

  const _LocationSelectorSheet({
    required this.locations,
    this.showCurrentLocation = false,
  });

  @override
  State<_LocationSelectorSheet> createState() => _LocationSelectorSheetState();
}

class _LocationSelectorSheetState extends State<_LocationSelectorSheet> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final filteredLocations = _filterLocations();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? kDarkCard : kWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [kStrongShadow],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? kDarkDivider : kDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: xmumGoldAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: kWhite,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        l10n.selectLocation,
                        style: xmumFont(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? kDarkText : kTextDark,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? kDarkTextMuted : kTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? kDarkSurface : kGreyLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? kDarkDivider : kDivider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: isDark ? kDarkTextMuted : kTextMuted,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          style: xmumFont(
                            color: isDark ? kDarkText : kTextDark,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.searchBuildings,
                            hintStyle: xmumFont(
                              color: isDark ? kDarkTextMuted : kTextMuted,
                              fontSize: 15,
                            ),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _CategoryChip(
                      label: l10n.all,
                      isSelected: _selectedCategory == null,
                      isDark: isDark,
                      onTap: () => setState(() => _selectedCategory = null),
                    ),
                    ...['Food', 'Facilities', 'Entrance', 'Dorm', 'Class', 'Office']
                        .map(
                      (category) => _CategoryChip(
                        label: category,
                        isSelected: _selectedCategory == category,
                        isDark: isDark,
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: filteredLocations.length + (widget.showCurrentLocation ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show current location option first if enabled
                    if (widget.showCurrentLocation && index == 0) {
                      return XmumStaggeredItem(
                        index: 0,
                        child: _CurrentLocationTile(
                          isDark: isDark,
                          onTap: () => Navigator.pop(context, 'current_location'),
                        ),
                      );
                    }

                    final adjustedIndex = widget.showCurrentLocation ? index - 1 : index;
                    final location = filteredLocations[adjustedIndex];
                    return XmumStaggeredItem(
                      index: index,
                      child: _LocationTile(
                        location: location,
                        isDark: isDark,
                        onTap: () => Navigator.pop(context, location),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<CampusLocation> _filterLocations() {
    var filtered = widget.locations;

    if (_searchQuery.isNotEmpty) {
      filtered = CampusLocations.searchLocations(_searchQuery);
    }

    if (_selectedCategory != null) {
      filtered =
          filtered.where((loc) => loc.category == _selectedCategory).toList();
    }

    return filtered;
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: XmumScaleTap(
        onTap: onTap,
        child: AnimatedContainer(
          duration: kAnimFast,
          curve: kAnimCurve,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected ? xmumPremiumGradient : null,
            color: isSelected
                ? null
                : (isDark ? kDarkSurface : kGreyLight),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark ? kDarkDivider : kDivider),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: kPrimary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: xmumFont(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? kWhite
                  : (isDark ? kDarkTextMuted : kTextMuted),
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentLocationTile extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _CurrentLocationTile({
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return XmumScaleTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? kDarkSurface : kGreyLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: kPrimary.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kPrimary.withValues(alpha: 0.2),
                    kSecondary.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: kPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Current Location',
                    style: xmumFont(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? kDarkText : kTextDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Use GPS to get your current position',
                    style: xmumFont(
                      fontSize: 13,
                      color: isDark ? kDarkTextMuted : kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? kDarkTextMuted : kTextMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final CampusLocation location;
  final bool isDark;
  final VoidCallback onTap;

  const _LocationTile({
    required this.location,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return XmumScaleTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? kDarkSurface : kGreyLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? kDarkDivider : kDivider.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kPrimary.withValues(alpha: 0.15),
                    kAccent.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getCategoryIcon(location.category),
                color: kPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: xmumFont(
                      fontWeight: FontWeight.w700,
                      color: isDark ? kDarkText : kTextDark,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    location.description,
                    style: xmumFont(
                      fontSize: 12,
                      color: isDark ? kDarkTextMuted : kTextMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                location.category,
                style: xmumFont(
                  fontSize: 10,
                  color: kPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Academic':
        return Icons.school_rounded;
      case 'Facility':
        return Icons.business_rounded;
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Parking':
        return Icons.local_parking_rounded;
      case 'Entrance':
        return Icons.door_sliding_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }
}