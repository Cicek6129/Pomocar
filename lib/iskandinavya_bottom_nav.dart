import 'package:flutter/material.dart';

/// İskandinavya teması — özel PNG ikonlu alt navigasyon.
class IskandinavyaBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const IskandinavyaBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color _barBackground = Color(0xFFE0F7FA);
  static const Color _passiveTint = Color(0xFF006874);

  static const double _barHeight = 56;
  static const double _slotSize = 48;
  static const double _baseIconSize = 34;
  static const double _defaultPassiveScale = 1.92;

  /// İkonları üst kenardan uzaklaştırıp dikey ortalar.
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
      active: 'assets/Icons/iskandinavya/home_aktif_isk.png',
      inactive: 'assets/Icons/iskandinavya/home_pasif_isk.png',
      activeScale: 2.08,
      passiveScale: 1.92,
      activeBaseSize: 34,
    ),
    (
      active: 'assets/Icons/iskandinavya/market_pasif_isk.png',
      inactive: 'assets/Icons/iskandinavya/market_aktif_isk.png',
      activeScale: 2.12,
      passiveScale: 1.92,
      activeBaseSize: 34,
    ),
    (
      active: 'assets/Icons/iskandinavya/stats_aktif_isk.png',
      inactive: 'assets/Icons/iskandinavya/stats_pasif_isk.png',
      activeScale: 1.72,
      passiveScale: 1.72,
      activeBaseSize: 32,
    ),
    (
      active: 'assets/Icons/iskandinavya/settings_aktif_isk.png',
      inactive: 'assets/Icons/iskandinavya/settings_pasif_isk.png',
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
              offset: const Offset(0, 20), // Shift down further
              child: Transform.scale(
                scale: 1.3, // Enlarge background more than Machu Picchu
                child: Image.asset(
                  'assets/Cards/isk_icons_background.png',
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
                      child: _IskNavItem(
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

class _IskNavItem extends StatelessWidget {
  final ({
    String active,
    String inactive,
    double activeScale,
    double passiveScale,
    double activeBaseSize,
  }) item;
  final bool isSelected;
  final VoidCallback onTap;

  const _IskNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visualScale =
        isSelected ? item.activeScale : item.passiveScale;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0xFF00ACC1).withValues(alpha: 0.18),
        highlightColor: const Color(0xFFB2EBF2).withValues(alpha: 0.7),
        child: SizedBox(
          height: IskandinavyaBottomNavBar._barHeight - 5,
          child: Center(
            child: SizedBox(
              width: IskandinavyaBottomNavBar._slotSize,
              height: IskandinavyaBottomNavBar._slotSize,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _IskNavIcon(
                  key: ValueKey(isSelected),
                  assetPath: isSelected ? item.active : item.inactive,
                  visualScale: visualScale,
                  renderSize: isSelected
                      ? item.activeBaseSize
                      : IskandinavyaBottomNavBar._baseIconSize,
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

class _IskNavIcon extends StatelessWidget {
  final String assetPath;
  final double visualScale;
  final double renderSize;
  final bool isSelected;

  const _IskNavIcon({
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
          IskandinavyaBottomNavBar._passiveTint,
          BlendMode.srcIn,
        ),
        child: image,
      );
    }

    return Center(
      child: Transform.translate(
        offset: const Offset(0, IskandinavyaBottomNavBar._iconVerticalOffset),
        child: Transform.scale(
          scale: visualScale,
          child: image,
        ),
      ),
    );
  }
}
