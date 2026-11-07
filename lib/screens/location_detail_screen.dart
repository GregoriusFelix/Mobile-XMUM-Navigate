import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../models/campus_location.dart';
import '../utils/location_display.dart';
import '../services/firebase_service.dart';
import 'navigation_screen.dart';
import 'location_form_screen.dart';

class LocationDetailScreen extends StatefulWidget {
  final CampusLocation location;

  const LocationDetailScreen({super.key, required this.location});

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  final _service = FirebaseService();
  bool _isSaved = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final uid = _service.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final saved = await _service.isLocationSaved(uid, widget.location.id);
    if (mounted) {
      setState(() {
        _isSaved = saved;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSave() async {
    final uid = _service.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isLoading = true;
    });

    if (_isSaved) {
      await _service.unsaveLocation(uid, widget.location.id);
    } else {
      await _service.saveLocation(uid, widget.location.id);
    }

    await _checkIfSaved();
  }

  @override
  Widget build(BuildContext context) {
    final display = locationDisplayFor(widget.location);

    return Scaffold(
      backgroundColor: kGrey,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 52, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: setelCardDecoration(),
                          child: const Icon(Icons.arrow_back_ios_new, size: 18, color: kTextDark),
                        ),
                      ),
                      const Spacer(),
                      if (!_isLoading)
                        GestureDetector(
                          onTap: _toggleSave,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: setelCardDecoration(),
                            child: Icon(
                              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              size: 22,
                              color: _isSaved ? kPrimary : kTextMuted,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LocationFormScreen(location: widget.location),
                            ),
                          ).then((result) {
                            if (result == true) {
                              Navigator.pop(context);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: setelCardDecoration(),
                          child: const Icon(Icons.edit, size: 22, color: kTextDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: kMapGreen,
                              borderRadius: BorderRadius.circular(kRadiusMd),
                            ),
                            child: Center(
                              child: Text(display.emoji, style: const TextStyle(fontSize: 36)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${categoryLabel(widget.location.category)} ${display.status}',
                                  style: const TextStyle(
                                    color: kGreen,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.location.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: kTextDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                HoursBadge(hours: display.hours),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Location description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kTextDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        display.longDescription,
                        style: const TextStyle(fontSize: 14, color: kTextMuted, height: 1.6),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: kYellow, size: 22),
                                  const SizedBox(width: 4),
                                  Text(
                                    display.rating.toStringAsFixed(1).replaceAll('.', ','),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: kTextDark,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '(${_formatCount(display.reviewCount)})',
                                style: const TextStyle(fontSize: 12, color: kTextMuted),
                              ),
                            ],
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: display.facilities.map(_facilityRow).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Popular spots',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kTextDark,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 72,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _spotThumb(kMapGreen, display.emoji),
                            _spotThumb(const Color(0xFFBBDEFB), '🌊'),
                            _spotThumb(const Color(0xFFFFF9C4), '🪑'),
                            _spotThumb(const Color(0xFFE1BEE7), '🌸'),
                            Container(
                              width: 72,
                              height: 72,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: kDivider,
                                borderRadius: BorderRadius.circular(kRadiusSm),
                              ),
                              child: const Center(
                                child: Text('20+', style: TextStyle(fontWeight: FontWeight.bold, color: kTextMuted)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: ParkButton(
              label: 'Get directions',
              icon: Icons.navigation_rounded,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NavigationScreen(initialLocation: widget.location),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _facilityRow(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: kGreen, size: 18),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontSize: 13, color: kTextDark)),
        ],
      ),
    );
  }

  Widget _spotThumb(Color bg, String emoji) {
    return Container(
      width: 72,
      height: 72,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(kRadiusSm),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1).replaceAll('.', ',')}k';
    return n.toString();
  }
}
