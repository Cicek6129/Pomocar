import 'package:flutter/material.dart';

/// Machu Picchu teması — özel PNG ikonlu alt navigasyon.
class MachuPicchuBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MachuPicchuBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color _barBackground = Color(0xFFE8F5E9);
  static const Color _passiveTint = Color(0xFF071F08); // Darker green/black for visibility

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
      active: 'assets/Icons/machu_picchu/home_aktif_mp.png',
      inactive: 'assets/Icons/machu_picchu/home_pasif_mp.png',
      activeScale: 2.08,
      passiveScale: 1.92,
      activeBaseSize: 34,
    ),
    (
      active: 'assets/Icons/machu_picchu/market_aktif_mp.png',
      inactive: 'assets/Icons/machu_picchu/market_pasif_mp.png',
      activeScale: 2.12,
      passiveScale: 1.92,
      activeBaseSize: 34,
    ),
    (
      active: 'assets/Icons/machu_picchu/stats_aktif_mp.png',
      inactive: 'assets/Icons/machu_picchu/stats_pasif_mp.png',
      activeScale: 2.08,
      passiveScale: 1.92,
      activeBaseSize: 34,
    ),
    (
      active: 'assets/Icons/machu_picchu/settings_aktif_mp.png',
      inactive: 'assets/Icons/machu_picchu/settings_pasif_mp.png',
      activeScale: 2.08,
      passiveScale: 1.92,
      activeBaseSize: 34,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scaled background image
        Positioned.fill(
          child: ClipRect(
            child: Transform.translate(
              offset: const Offset(0, -5), // Shift up slightly from previous value
              child: Transform.scale(
                scale: 1.15, // Enlarge background for Machu Picchu
                child: Image.asset(
                  'assets/Cards/machu_pichu_icons_background.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        // Nav items
        Material(
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
                      child: _MachuNavItem(
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
      ],
    );
  }
}

class _MachuNavItem extends StatelessWidget {
  final ({
    String active,
    String inactive,
    double activeScale,
    double passiveScale,
    double activeBaseSize,
  }) item;
  final bool isSelected;
  final VoidCallback onTap;

  const _MachuNavItem({
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
        splashColor: const Color(0xFF2E7D32).withValues(alpha: 0.18),
        highlightColor: const Color(0xFFC8E6C9).withValues(alpha: 0.75),
        child: SizedBox(
          height: MachuPicchuBottomNavBar._barHeight - 5,
          child: Center(
            child: SizedBox(
              width: MachuPicchuBottomNavBar._slotSize,
              height: MachuPicchuBottomNavBar._slotSize,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _MachuNavIcon(
                  key: ValueKey(isSelected),
                  assetPath: isSelected ? item.active : item.inactive,
                  visualScale: visualScale,
                  renderSize: isSelected
                      ? item.activeBaseSize
                      : MachuPicchuBottomNavBar._baseIconSize,
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

class _MachuNavIcon extends StatelessWidget {
  final String assetPath;
  final double visualScale;
  final double renderSize;
  final bool isSelected;

  const _MachuNavIcon({
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
          MachuPicchuBottomNavBar._passiveTint,
          BlendMode.srcIn,
        ),
        child: image,
      );
    }

    return Center(
      child: Transform.translate(
        offset: const Offset(0, MachuPicchuBottomNavBar._iconVerticalOffset),
        child: Transform.scale(
          scale: visualScale,
          child: image,
        ),
      ),
    );
  }
}
