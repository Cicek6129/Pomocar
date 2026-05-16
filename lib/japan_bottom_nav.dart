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

  /// Japon teması scaffold rengine uyumlu yumuşak pembe.
  static const Color _barBackground = Color(0xFFFCE4EC);

  /// Pasif ikonlar — tüm sekmelerde aynı.
  static const double _passiveIconSize = 44;

  /// Aktif PNG'lerde fazla boşluk olduğu için sekme bazlı büyütme (Market hariç).
  static const double _slotSize = 58;

  static const List<
      ({String active, String inactive, double activeRenderSize})> _items = [
    (
      active: 'assets/Icons/japan/home_aktif_japan.png',
      inactive: 'assets/Icons/japan/home_pasif_japan.png',
      activeRenderSize: 56,
    ),
    (
      active: 'assets/Icons/japan/market_aktif_japan.png',
      inactive: 'assets/Icons/japan/market_pasif_japan.png',
      activeRenderSize: 44,
    ),
    (
      active: 'assets/Icons/japan/stats_aktif_japan.png',
      inactive: 'assets/Icons/japan/stats_pasif_japan.png',
      activeRenderSize: 54,
    ),
    (
      active: 'assets/Icons/japan/settings_aktif_japan.png',
      inactive: 'assets/Icons/japan/settings_pasif_japan.png',
      activeRenderSize: 54,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _barBackground,
      child: Container(
        decoration: BoxDecoration(
          color: _barBackground,
          border: Border(
            top: BorderSide(
              color: const Color(0xFFE91E63).withValues(alpha: 0.15),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
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
    );
  }
}

class _JapanNavItem extends StatelessWidget {
  final ({String active, String inactive, double activeRenderSize}) item;
  final bool isSelected;
  final VoidCallback onTap;

  const _JapanNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize =
        isSelected ? item.activeRenderSize : JapanBottomNavBar._passiveIconSize;

    return Material(
      color: JapanBottomNavBar._barBackground,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0xFFE91E63).withValues(alpha: 0.14),
        highlightColor: const Color(0xFFF8BBD0).withValues(alpha: 0.5),
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
                key: ValueKey('${isSelected}_$iconSize'),
                assetPath: isSelected ? item.active : item.inactive,
                size: iconSize,
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
  final double size;

  const _JapanNavIcon({
    super.key,
    required this.assetPath,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      ),
    );
  }
}
