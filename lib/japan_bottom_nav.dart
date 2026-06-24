import 'package:flutter/material.dart';

/// Sakura / Japon teması — özel PNG ikonlu alt navigasyon.
class JapanBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const JapanBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color _barBackground = Color(0xFFFCE4EC);
  static const Color _passiveTint = Color(0xFFC2185B); // Koyu pembe silüet

  static const double _barHeight = 56;
  static const double _slotSize = 48;
  static const double _baseIconSize = 34;
  static const double _iconVerticalOffset = -2;

  static const List<
      ({
        String active,
        String inactive,
        double activeScale,
        double passiveScale,
        double activeBaseSize,
      })> _items = [
    (
      active: 'assets/Icons/japan/home_aktif_japan.png',
      inactive: 'assets/Icons/japan/home_pasif_japan.png',
      activeScale: 2.08,
      passiveScale: 1.92,
      activeBaseSize: 34,
    ),
    (
      active: 'assets/Icons/japan/market_aktif_japan.png',
      inactive: 'assets/Icons/japan/market_pasif_japan.png',
      activeScale: 2.12,
      passiveScale: 1.92,
      activeBaseSize: 34,
    ),
    (
      active: 'assets/Icons/japan/stats_aktif_japan.png',
      inactive: 'assets/Icons/japan/stats_pasif_japan.png',
      activeScale: 2.08,
      passiveScale: 1.92,
      activeBaseSize: 34,
    ),
    (
      active: 'assets/Icons/japan/settings_aktif_japan.png',
      inactive: 'assets/Icons/japan/settings_pasif_japan.png',
      activeScale: 2.08,
      passiveScale: 1.92,
      activeBaseSize: 34,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/Cards/Japon_Icons_Background.png'),
          fit: BoxFit.cover,
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE91E63).withValues(alpha: 0.22),
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: _barHeight,
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: _JapanNavItem(
                        item: _items[i],
                        isSelected: currentIndex == i,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JapanNavItem extends StatelessWidget {
  final ({
    String active,
    String inactive,
    double activeScale,
    double passiveScale,
    double activeBaseSize,
  }) item;
  final bool isSelected;
  final VoidCallback onTap;

  const _JapanNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visualScale = isSelected ? item.activeScale : item.passiveScale;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0xFFE91E63).withValues(alpha: 0.18),
        highlightColor: const Color(0xFFF8BBD0).withValues(alpha: 0.75),
        child: SizedBox(
          height: JapanBottomNavBar._barHeight - 5,
          child: Center(
            child: SizedBox(
              width: JapanBottomNavBar._slotSize,
              height: JapanBottomNavBar._slotSize,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _JapanNavIcon(
                  key: ValueKey(isSelected),
                  assetPath: isSelected ? item.active : item.inactive,
                  visualScale: visualScale,
                  renderSize: isSelected
                      ? item.activeBaseSize
                      : JapanBottomNavBar._baseIconSize,
                  isSelected: isSelected,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JapanNavIcon extends StatelessWidget {
  final String assetPath;
  final double visualScale;
  final double renderSize;
  final bool isSelected;

  const _JapanNavIcon({
    super.key,
    required this.assetPath,
    required this.visualScale,
    required this.renderSize,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      assetPath,
      width: renderSize,
      height: renderSize,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
    );

    if (!isSelected) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.mode(
          JapanBottomNavBar._passiveTint,
          BlendMode.srcIn,
        ),
        child: image,
      );
    }

    return Center(
      child: Transform.translate(
        offset: const Offset(0, JapanBottomNavBar._iconVerticalOffset),
        child: Transform.scale(
          scale: visualScale,
          child: image,
        ),
      ),
    );
  }
}
