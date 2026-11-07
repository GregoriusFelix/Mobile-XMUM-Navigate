import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class RoutesHistoryScreen extends StatefulWidget {
  const RoutesHistoryScreen({super.key});

  @override
  State<RoutesHistoryScreen> createState() => _RoutesHistoryScreenState();
}

class _RoutesHistoryScreenState extends State<RoutesHistoryScreen> {
  final _service = FirebaseService();
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = _service.currentUser?.uid;
    if (uid != null) {
      final user = await _service.getUserProfile(uid);
      if (mounted) {
        setState(() {
          _user = user;
          _loading = false;
        });
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _clearHistory() async {
    final uid = _service.currentUser?.uid;
    if (uid == null || _user == null) return;

    await _service.updateUserProfile(uid, {'routeHistory': []});
    await _loadUser();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Route history cleared'), backgroundColor: Colors.green),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      appBar: AppBar(
        title: Text('Routes History', style: xmumFont(fontWeight: FontWeight.w700, color: kWhite)),
        backgroundColor: kPrimary,
        foregroundColor: kWhite,
        iconTheme: const IconThemeData(color: kWhite),
        elevation: 0,
        actions: [
          if (_user?.routeHistory.isNotEmpty == true)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: kWhite),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear History'),
                    content: const Text('Are you sure you want to clear all route history?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearHistory();
                        },
                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _user == null || _user!.routeHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: isDark ? kDarkTextMuted : kTextMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No route history yet',
                        style: xmumFont(
                          fontSize: 16,
                          color: isDark ? kDarkTextMuted : kTextMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start navigating to build your history',
                        style: xmumFont(
                          fontSize: 14,
                          color: isDark ? kDarkTextMuted : kTextMuted,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _user!.routeHistory.length,
                  itemBuilder: (context, index) {
                    final route = _user!.routeHistory[index];
                    final timestamp = DateTime.fromMillisecondsSinceEpoch(route['timestamp'] ?? 0);
                    final startLocation = route['startLocation'] ?? 'Unknown';
                    final endLocation = route['endLocation'] ?? 'Unknown';
                    final distance = route['distance'];
                    final duration = route['duration'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? kDarkCard : kWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(timestamp),
                                style: xmumFont(
                                  fontSize: 12,
                                  color: isDark ? kDarkTextMuted : kTextMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (distance != null)
                                Text(
                                  '${distance.toStringAsFixed(1)} km',
                                  style: xmumFont(
                                    fontSize: 12,
                                    color: kPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: kPrimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  startLocation,
                                  style: xmumFont(
                                    fontSize: 14,
                                    color: isDark ? kDarkText : kTextDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: kAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  endLocation,
                                  style: xmumFont(
                                    fontSize: 14,
                                    color: isDark ? kDarkText : kTextDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (duration != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: isDark ? kDarkTextMuted : kTextMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  duration,
                                  style: xmumFont(
                                    fontSize: 12,
                                    color: isDark ? kDarkTextMuted : kTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
