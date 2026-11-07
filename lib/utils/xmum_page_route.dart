import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/xmum_animations.dart';

/// Premium slide-and-fade page transition for XMUM Navigate.
class XmumPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  XmumPageRoute({required this.page})
      : super(
          opaque: true,
          barrierColor: Colors.transparent,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: kAnimMedium,
          reverseTransitionDuration: kAnimFast,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: kAnimCurve,
              reverseCurve: Curves.easeInCubic,
            );
            final scale = Tween<double>(begin: 0.96, end: 1.0).animate(curved);
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: scale,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              ),
            );
          },
        );
}

/// Slide-up modal route for bottom sheets with premium feel.
class XmumModalRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  XmumModalRoute({required this.page})
      : super(
          opaque: false,
          barrierColor: Colors.black54,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: kAnimMedium,
          reverseTransitionDuration: kAnimFast,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: kAnimCurve,
              reverseCurve: Curves.easeInCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(opacity: curved, child: child),
            );
          },
        );
}

void xmumPush(BuildContext context, Widget page) {
  Navigator.push(context, XmumPageRoute(page: page));
}

Future<T?> xmumShowModal<T>(BuildContext context, Widget page) {
  return Navigator.push<T>(context, XmumModalRoute(page: page));
}

/// Animated tab content switcher for main shell navigation.
class XmumTabSwitcher extends StatelessWidget {
  final int index;
  final List<Widget> children;

  const XmumTabSwitcher({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: kAnimMedium,
      switchInCurve: kAnimCurve,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: kAnimCurve));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(index),
        child: children[index],
      ),
    );
  }
}

/// Premium segmented tab bar with animated sliding indicator.
class XmumSegmentedTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> labels;
  final List<IconData> icons;
  final bool isDark;

  const XmumSegmentedTabBar({
    super.key,
    required this.controller,
    required this.labels,
    required this.icons,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    assert(labels.length == icons.length);

    return AnimatedBuilder(
      animation: controller.animation!,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? kDarkSurface : kGreyLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? kDarkDivider : kDivider.withValues(alpha: 0.6),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / labels.length;
              final offset = (controller.animation?.value ?? 0) * tabWidth;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: kAnimFast,
                    curve: kAnimCurve,
                    left: offset,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? kDarkCard : kWhite,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(labels.length, (i) {
                      final selected = controller.index == i;
                      final animValue = controller.animation!.value;
                      final distance = (animValue - i).abs();
                      final emphasis = (1 - distance.clamp(0.0, 1.0));

                      return Expanded(
                        child: XmumScaleTap(
                          scale: 0.97,
                          onTap: () => controller.animateTo(i),
                          child: SizedBox(
                            height: 44,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  icons[i],
                                  size: 18,
                                  color: Color.lerp(
                                    isDark ? kDarkTextMuted : kTextMuted,
                                    kPrimary,
                                    emphasis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  labels[i],
                                  style: xmumFont(
                                    fontSize: 12,
                                    fontWeight: FontWeight.lerp(
                                      FontWeight.w500,
                                      FontWeight.w700,
                                      emphasis,
                                    ) ?? FontWeight.w500,
                                    color: Color.lerp(
                                      isDark ? kDarkTextMuted : kTextMuted,
                                      kPrimary,
                                      emphasis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
