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

  /// İnce çizgili pasif PNG'leri koyu altın silüete çevirir (krem zeminde net).
  static const Color _passiveTint = Color(0xFF3E2723); // Dark chocolate brown

  /// Çubuk yüksekliği Japan ile aynı; büyüme yalnızca ikon ölçeğinde.
  static const double _barHeight = 56;
  static const double _slotSize = 50;
  static const double _baseIconSize = 34;

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
      activeBaseSize: 34,
    ),
    (
      active: 'assets/Icons/misir/egypt_market_aktif.png',
      inactive: 'assets/Icons/misir/egypt_market_pasif.png',
      activeScale: 2.12,
      activeBaseSize: 34,
    ),
    (
      active: 'assets/Icons/misir/egypt_istatistik_aktif.png',
      inactive: 'assets/Icons/misir/egypt_istatistik_pasif.png',
      activeScale: 1.98,
      activeBaseSize: 34,
    ),
    (
      active: 'assets/Icons/misir/egypt_ayarlar_aktif.png',
      inactive: 'assets/Icons/misir/egypt_ayarlar_pasif.png',
      activeScale: 2.08,
      activeBaseSize: 34,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/Cards/egypt_icons_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Material(
        color: Colors.transparent,
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0xFFFFC107).withValues(alpha: 0.2),
        highlightColor: const Color(0xFFFFECB3).withValues(alpha: 0.65),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0), // Move icons up
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

    Widget finalImage;

    if (!isSelected) {
      finalImage = ColorFiltered(
        colorFilter: const ColorFilter.mode(
          MisirBottomNavBar._passiveTint,
          BlendMode.srcIn,
        ),
        child: image,
      );
    } else {
      // Active icon is yellow, so it needs a strong dark shadow to pop from the yellow/tan bricks
      finalImage = Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(1.5, 2.0),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0x99000000), // Stronger dark shadow
                BlendMode.srcIn,
              ),
              child: image,
            ),
          ),
          image,
        ],
      );
    }

    return Center(
      child: Transform.scale(
        scale: visualScale,
        child: finalImage,
      ),
    );
  }
}
