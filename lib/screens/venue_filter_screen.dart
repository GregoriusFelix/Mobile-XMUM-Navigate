import 'package:flutter/material.dart';
import '../theme.dart';

class VenueFilterScreen extends StatefulWidget {
  final String? initialVenueType;
  final int? initialCapacity;
  final List<String> initialFacilities;

  const VenueFilterScreen({
    super.key,
    this.initialVenueType,
    this.initialCapacity,
    required this.initialFacilities,
  });

  @override
  State<VenueFilterScreen> createState() => _VenueFilterScreenState();
}

class _VenueFilterScreenState extends State<VenueFilterScreen> {
  String? _selectedVenueType;
  int? _requiredCapacity;
  List<String> _selectedFacilities = [];

  final List<String> _venueTypes = ['Auditorium', 'Lecture Hall', 'Class', 'Event Space', 'Outdoor', 'Indoor'];
  final List<String> _facilities = ['WiFi', 'Projector', 'Air Conditioning', 'Sound System', 'Seating', 'Stage', 'Parking', 'Accessible'];

  @override
  void initState() {
    super.initState();
    _selectedVenueType = widget.initialVenueType;
    _requiredCapacity = widget.initialCapacity;
    _selectedFacilities = List.from(widget.initialFacilities);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      appBar: AppBar(
        title: Text('Filter Venues', style: xmumFont(fontWeight: FontWeight.w700, color: kWhite)),
        backgroundColor: kPrimary,
        foregroundColor: kWhite,
        iconTheme: const IconThemeData(color: kWhite),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue Type
            Text('Venue Type', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextDark)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _venueTypes.map((type) {
                final isSelected = _selectedVenueType == type;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedVenueType = isSelected ? null : type;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimary : (isDark ? kDarkCard : kWhite),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? kPrimary : kDivider),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? kWhite : (isDark ? kDarkText : kTextDark),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Capacity
            Text('Required Capacity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextDark)),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter number of people',
                suffixText: 'people',
                filled: true,
                fillColor: isDark ? kDarkCard : kWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kDivider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kDivider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kPrimary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                final capacity = int.tryParse(value);
                setState(() => _requiredCapacity = capacity);
              },
              controller: TextEditingController(text: _requiredCapacity?.toString() ?? ''),
            ),
            const SizedBox(height: 24),

            // Facilities
            Text('Facilities', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextDark)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _facilities.map((facility) {
                final isSelected = _selectedFacilities.contains(facility);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedFacilities.remove(facility);
                      } else {
                        _selectedFacilities.add(facility);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimary.withValues(alpha: 0.1) : (isDark ? kDarkCard : kWhite),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? kPrimary : kDivider),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          size: 16,
                          color: isSelected ? kPrimary : kTextMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          facility,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? kPrimary : (isDark ? kDarkText : kTextDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedVenueType = null;
                        _requiredCapacity = null;
                        _selectedFacilities = [];
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimary,
                      side: BorderSide(color: kPrimary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'venueType': _selectedVenueType,
                        'capacity': _requiredCapacity,
                        'facilities': _selectedFacilities,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: kWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
