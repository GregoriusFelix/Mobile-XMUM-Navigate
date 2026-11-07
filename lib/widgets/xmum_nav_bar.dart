import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/xmum_animations.dart';

class XmumNavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final VoidCallback onTap;

  const XmumNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.onTap,
  });
}

/// Premium floating bottom navigation bar with sliding indicator and icon animations.
class XmumNavBar extends StatelessWidget {
  final List<XmumNavItem> items;
  final int selectedIndex;
  final bool isDark;
  final double fabGapWidth;

  const XmumNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.isDark,
    this.fabGapWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? kDarkCard : kWhite;
    final borderColor = isDark ? kDarkDivider : kDivider.withValues(alpha: 0.6);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: isDark ? 0.25 : 0.12),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: 72,
          child: Row(
            children: _buildRowChildren(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRowChildren() {
    final children = <Widget>[];
    var itemIndex = 0;

    for (var i = 0; i < items.length; i++) {
      if (fabGapWidth > 0 && i == items.length ~/ 2) {
        children.add(SizedBox(width: fabGapWidth));
      }

      final item = items[i];
      final selected = selectedIndex == itemIndex;

      children.add(
        Expanded(
          child: _NavBarItem(
            item: item,
            selected: selected,
            isDark: isDark,
          ),
        ),
      );
      itemIndex++;
    }

    return children;
  }
}

class _NavBarItem extends StatefulWidget {
  final XmumNavItem item;
  final bool selected;
  final bool isDark;

  const _NavBarItem({
    required this.item,
    required this.selected,
    required this.isDark,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _pillWidth;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: kAnimMedium,
    );
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _ctrl, curve: kAnimSpring),
    );
    _pillWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: kAnimCurve),
    );
    if (widget.selected) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _ctrl.forward(from: 0);
    } else if (!widget.selected && oldWidget.selected) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final muted = widget.isDark ? kDarkTextMuted : kTextMuted;

    return XmumScaleTap(
      scale: 0.92,
      onTap: widget.item.onTap,
      child: SizedBox(
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pillWidth,
              builder: (_, __) {
                return Opacity(
                  opacity: _pillWidth.value,
                  child: Container(
                    width: 56,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kPrimary.withValues(alpha: 0.14),
                          kPrimary.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: kPrimary.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                );
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: widget.selected ? _scale : const AlwaysStoppedAnimation(1.0),
                  child: AnimatedSwitcher(
                    duration: kAnimFast,
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: child,
                    ),
                    child: Icon(
                      widget.selected
                          ? (widget.item.selectedIcon ?? widget.item.icon)
                          : widget.item.icon,
                      key: ValueKey(widget.selected),
                      size: 24,
                      color: widget.selected ? kPrimary : muted,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: kAnimFast,
                  curve: kAnimCurve,
                  style: xmumFont(
                    fontSize: 10,
                    fontWeight:
                        widget.selected ? FontWeight.w700 : FontWeight.w500,
                    color: widget.selected ? kPrimary : muted,
                    letterSpacing: widget.selected ? 0.2 : 0,
                  ),
                  child: Text(widget.item.label),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated extended FAB for quick navigation access.
class XmumNavigateFab extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final bool visible;

  const XmumNavigateFab({
    super.key,
    required this.onPressed,
    required this.label,
    this.visible = true,
  });

  @override
  State<XmumNavigateFab> createState() => _XmumNavigateFabState();
}

class _XmumNavigateFabState extends State<XmumNavigateFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: widget.visible ? 1.0 : 0.0,
      duration: kAnimMedium,
      curve: kAnimSpring,
      child: AnimatedOpacity(
        opacity: widget.visible ? 1.0 : 0.0,
        duration: kAnimFast,
        child: XmumScaleTap(
          scale: 0.95,
          onTap: widget.onPressed,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (_, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kSecondary.withValues(
                        alpha: 0.25 + _pulse.value * 0.15,
                      ),
                      blurRadius: 16 + _pulse.value * 8,
                      offset: const Offset(0, 6),
                    ),
                    kGoldGlow,
                  ],
                ),
                child: child,
              );
            },
            child: FloatingActionButton.extended(
              onPressed: widget.onPressed,
              backgroundColor: kSecondary,
              foregroundColor: kWhite,
              elevation: 0,
              highlightElevation: 0,
              icon: const Icon(Icons.navigation_rounded, size: 22),
              label: Text(
                widget.label,
                style: xmumFont(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
