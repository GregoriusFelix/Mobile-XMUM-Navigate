import 'package:flutter/material.dart';
import '../theme.dart';
import 'widgets/xmum_animations.dart';

class XmumLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showSubtitle;
  final Color? textColor;

  const XmumLogo({
    super.key,
    this.size = 32,
    this.showText = true,
    this.showSubtitle = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _XmumEmblem(size: size),
        if (showText) ...[
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'XMUM Navigate',
                style: xmumFont(
                  fontSize: size * 0.48,
                  fontWeight: FontWeight.w800,
                  color: textColor ?? kTextDark,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _XmumEmblem extends StatelessWidget {
  final double size;

  const _XmumEmblem({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/xmum_navigate_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          decoration: BoxDecoration(
            gradient: xmumPremiumGradient,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.school_rounded,
                color: kWhite.withValues(alpha: 0.9),
                size: size * 0.5,
              ),
              Positioned(
                bottom: size * 0.12,
                child: Container(
                  width: size * 0.35,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: xmumGoldAccent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool isDark;

  const ParkCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: 12),
        decoration: xmumPremiumCard(isDark: isDark),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(18),
          child: child,
        ),
      ),
    );
  }
}

class ParkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSecondary;

  const ParkButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSecondary ? kSecondary : kPrimary;
    return XmumScaleTap(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadiusLg),
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            minimumSize: const Size(double.infinity, 54),
          ),
        ),
      ),
    );
  }
}

class PageDots extends StatelessWidget {
  final int count;
  final int active;

  const PageDots({super.key, required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: isActive ? xmumGoldAccent : null,
            color: isActive ? null : kDivider,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class ParkSearchBar extends StatelessWidget {
  final String hint;
  final VoidCallback? onMenuTap;
  final VoidCallback? onTap;
  final bool isDark;

  const ParkSearchBar({
    super.key,
    this.hint = 'Where do you want to go?',
    this.onMenuTap,
    this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: xmumPremiumCard(isDark: isDark),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                onMenuTap != null ? Icons.menu_rounded : Icons.search_rounded,
                color: kPrimary,
                size: 20,
              ),
            ),
            Expanded(
              child: Text(
                hint,
                style: xmumFont(
                  color: isDark ? kDarkTextMuted : kTextMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: xmumGoldAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune_rounded, color: kWhite, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class TravelTimeBar extends StatelessWidget {
  final String label;

  const TravelTimeBar({super.key, this.label = '20 minutes from your location'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: xmumPremiumGradient,
        borderRadius: BorderRadius.circular(kRadiusMd),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: xmumGlassDecoration(),
            child: const Icon(Icons.directions_walk_rounded, color: kWhite, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: xmumFont(
                color: kWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: kWhite.withValues(alpha: 0.8)),
        ],
      ),
    );
  }
}

class HoursBadge extends StatelessWidget {
  final String hours;
  final bool compact;

  const HoursBadge({super.key, required this.hours, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(
        color: kAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, color: kAccent, size: compact ? 12 : 14),
          SizedBox(width: compact ? 2 : 4),
          Text(
            hours,
            style: xmumFont(fontSize: compact ? 10 : 12, color: kTextMuted, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class XmumBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;

  const XmumBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? kPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: xmumFont(fontSize: 11, fontWeight: FontWeight.w700, color: c),
          ),
        ],
      ),
    );
  }
}