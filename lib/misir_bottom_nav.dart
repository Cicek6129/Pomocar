import 'package:flutter/material.dart';

/// Mısır teması — özel PNG ikonlu alt navigasyon.
class MisirBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MisirBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color _barBackground = Color(0xFFFFF8E1);

  /// İnce çizgili pasif PNG'leri koyu altın silüete çevirir (krem zeminde net).
  static const Color _passiveTint = Color(0xFF7A5C1E);

  /// Çubuk yüksekliği Japan ile aynı; büyüme yalnızca ikon ölçeğinde.
  static const double _barHeight = 62;
  static const double _slotSize = 58;
  static const double _baseIconSize = 42;

  /// Aktif PNG'lerde fazla şeffaf kenar varsa [activeScale] > [passiveScale] olmalı.
  static const double _passiveScale = 1.92;

  static const List<
      ({
        String active,
        String inactive,
        double activeScale,
        double activeBaseSize,
      })> _items = [
    (
      active: 'assets/Icons/misir/egypt_odak_aktif.png',
      inactive: 'assets/Icons/misir/egypt_odak_pasif.png',
      activeScale: 2.08,
      activeBaseSize: 42,
    ),
    (
      active: 'assets/Icons/misir/egypt_market_aktif.png',
      inactive: 'assets/Icons/misir/egypt_market_pasif.png',
      activeScale: 2.12,
      activeBaseSize: 42,
    ),
    (
      active: 'assets/Icons/misir/egypt_istatistik_aktif.png',
      inactive: 'assets/Icons/misir/egypt_istatistik_pasif.png',
      activeScale: 1.98,
      activeBaseSize: 42,
    ),
    (
      active: 'assets/Icons/misir/egypt_ayarlar_aktif.png',
      inactive: 'assets/Icons/misir/egypt_ayarlar_pasif.png',
      activeScale: 2.08,
      activeBaseSize: 42,
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
              color: const Color(0xFF8D6E63).withValues(alpha: 0.35),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: _barHeight,
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    child: _MisirNavItem(
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

class _MisirNavItem extends StatelessWidget {
  final ({
    String active,
    String inactive,
    double activeScale,
    double activeBaseSize,
  }) item;
  final bool isSelected;
  final VoidCallback onTap;

  const _MisirNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visualScale =
        isSelected ? item.activeScale : MisirBottomNavBar._passiveScale;

    return Material(
      color: MisirBottomNavBar._barBackground,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0xFFFFC107).withValues(alpha: 0.2),
        highlightColor: const Color(0xFFFFECB3).withValues(alpha: 0.65),
        child: Center(
          child: SizedBox(
            width: MisirBottomNavBar._slotSize,
            height: MisirBottomNavBar._slotSize,
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _MisirNavIcon(
                  key: ValueKey(isSelected),
                  assetPath: isSelected ? item.active : item.inactive,
                  visualScale: visualScale,
                  renderSize: isSelected
                      ? item.activeBaseSize
                      : MisirBottomNavBar._baseIconSize,
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

class _MisirNavIcon extends StatelessWidget {
  final String assetPath;
  final double visualScale;
  final double renderSize;
  final bool isSelected;

  const _MisirNavIcon({
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
          MisirBottomNavBar._passiveTint,
          BlendMode.srcIn,
        ),
        child: image,
      );
    }

    return Center(
      child: Transform.scale(
        scale: visualScale,
        child: image,
      ),
    );
  }
}
