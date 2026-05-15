import 'package:flutter/material.dart';

/// Fütüristik uzay mekiği kontrol paneli — yalnızca Derin Uzay temasında kullanılır.
class SpaceBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SpaceBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Orta boy panel (görünür kontrol alanı)
  static const double _coreHeight = 76;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.viewPadding.bottom;
    final width = media.size.width;
    final totalHeight = _coreHeight + bottomInset;
    final fullSize = Size(width, totalHeight);

    return SizedBox(
      height: totalHeight,
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          CustomPaint(
            size: fullSize,
            painter: _SpacePanelPainter(coreHeight: _coreHeight),
          ),
          _PolygonNavButton(
            size: fullSize,
            clipper: _LeftPanelClipper(coreHeight: _coreHeight),
            onTap: () => onTap(0),
          ),
          _PolygonNavButton(
            size: fullSize,
            clipper: _CenterLeftPanelClipper(coreHeight: _coreHeight),
            onTap: () => onTap(1),
          ),
          _PolygonNavButton(
            size: fullSize,
            clipper: _CenterRightPanelClipper(coreHeight: _coreHeight),
            onTap: () => onTap(2),
          ),
          _PolygonNavButton(
            size: fullSize,
            clipper: _RightPanelClipper(coreHeight: _coreHeight),
            onTap: () => onTap(3),
          ),
          _NavIconLayer(
            fullSize: fullSize,
            coreHeight: _coreHeight,
            bottomInset: bottomInset,
            currentIndex: currentIndex,
          ),
        ],
      ),
    );
  }
}

/// Ortak geometri — painter, clipper ve simge konumları aynı yolları kullanır.
class _SpacePanelGeometry {
  static double _top(double h, double coreH) => h - coreH;

  static Path leftPanel(double w, double h, double coreH) {
    final t = _top(h, coreH);
    return Path()
      ..moveTo(0, h)
      ..lineTo(0, t + coreH * 0.56)
      ..lineTo(w * 0.20, t + coreH * 0.36)
      ..lineTo(w * 0.27, h)
      ..close();
  }

  static Path centerPanel(double w, double h, double coreH) {
    final t = _top(h, coreH);
    return Path()
      ..moveTo(w * 0.29, h)
      ..lineTo(w * 0.31, t + coreH * 0.22)
      ..lineTo(w * 0.69, t + coreH * 0.22)
      ..lineTo(w * 0.71, h)
      ..close();
  }

  static Path centerLeftButton(double w, double h, double coreH) {
    final t = _top(h, coreH);
    return Path()
      ..moveTo(w * 0.29, h)
      ..lineTo(w * 0.31, t + coreH * 0.22)
      ..lineTo(w * 0.50, t + coreH * 0.26)
      ..lineTo(w * 0.50, h)
      ..close();
  }

  static Path centerRightButton(double w, double h, double coreH) {
    final t = _top(h, coreH);
    return Path()
      ..moveTo(w * 0.50, h)
      ..lineTo(w * 0.50, t + coreH * 0.26)
      ..lineTo(w * 0.69, t + coreH * 0.22)
      ..lineTo(w * 0.71, h)
      ..close();
  }

  static Path rightPanel(double w, double h, double coreH) {
    final t = _top(h, coreH);
    return Path()
      ..moveTo(w * 0.72, h)
      ..lineTo(w * 0.80, t + coreH * 0.36)
      ..lineTo(w, t + coreH * 0.56)
      ..lineTo(w, h)
      ..close();
  }

  static Offset iconAnchor(Path path, double bottomInset) {
    final bounds = path.getBounds();
    final safeBottom = bounds.bottom - bottomInset * 0.35;
    return Offset(
      bounds.center.dx,
      bounds.top + (safeBottom - bounds.top) * 0.52,
    );
  }
}

class _LeftPanelClipper extends CustomClipper<Path> {
  final double coreHeight;
  const _LeftPanelClipper({required this.coreHeight});

  @override
  Path getClip(Size size) =>
      _SpacePanelGeometry.leftPanel(size.width, size.height, coreHeight);

  @override
  bool shouldReclip(covariant _LeftPanelClipper oldClipper) =>
      oldClipper.coreHeight != coreHeight;
}

class _CenterLeftPanelClipper extends CustomClipper<Path> {
  final double coreHeight;
  const _CenterLeftPanelClipper({required this.coreHeight});

  @override
  Path getClip(Size size) =>
      _SpacePanelGeometry.centerLeftButton(size.width, size.height, coreHeight);

  @override
  bool shouldReclip(covariant _CenterLeftPanelClipper oldClipper) =>
      oldClipper.coreHeight != coreHeight;
}

class _CenterRightPanelClipper extends CustomClipper<Path> {
  final double coreHeight;
  const _CenterRightPanelClipper({required this.coreHeight});

  @override
  Path getClip(Size size) =>
      _SpacePanelGeometry.centerRightButton(size.width, size.height, coreHeight);

  @override
  bool shouldReclip(covariant _CenterRightPanelClipper oldClipper) =>
      oldClipper.coreHeight != coreHeight;
}

class _RightPanelClipper extends CustomClipper<Path> {
  final double coreHeight;
  const _RightPanelClipper({required this.coreHeight});

  @override
  Path getClip(Size size) =>
      _SpacePanelGeometry.rightPanel(size.width, size.height, coreHeight);

  @override
  bool shouldReclip(covariant _RightPanelClipper oldClipper) =>
      oldClipper.coreHeight != coreHeight;
}

class _PolygonNavButton extends StatelessWidget {
  final Size size;
  final CustomClipper<Path> clipper;
  final VoidCallback onTap;

  const _PolygonNavButton({
    required this.size,
    required this.clipper,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipPath(
        clipper: clipper,
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashColor: const Color(0xFF00E5FF).withValues(alpha: 0.32),
            highlightColor: const Color(0xFF00E5FF).withValues(alpha: 0.16),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _NavIconLayer extends StatelessWidget {
  final Size fullSize;
  final double coreHeight;
  final double bottomInset;
  final int currentIndex;

  const _NavIconLayer({
    required this.fullSize,
    required this.coreHeight,
    required this.bottomInset,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final w = fullSize.width;
    final h = fullSize.height;

    final anchors = [
      _SpacePanelGeometry.iconAnchor(
        _SpacePanelGeometry.leftPanel(w, h, coreHeight),
        bottomInset,
      ),
      _SpacePanelGeometry.iconAnchor(
        _SpacePanelGeometry.centerLeftButton(w, h, coreHeight),
        bottomInset,
      ),
      _SpacePanelGeometry.iconAnchor(
        _SpacePanelGeometry.centerRightButton(w, h, coreHeight),
        bottomInset,
      ),
      _SpacePanelGeometry.iconAnchor(
        _SpacePanelGeometry.rightPanel(w, h, coreHeight),
        bottomInset,
      ),
    ];

    const icons = [
      (Icons.timer_outlined, Icons.timer),
      (Icons.store_outlined, Icons.store),
      (Icons.calendar_month_outlined, Icons.calendar_month),
      (Icons.settings_outlined, Icons.settings),
    ];

    return IgnorePointer(
      child: Stack(
        children: [
          for (var i = 0; i < 4; i++)
            Positioned(
              left: anchors[i].dx - 17,
              top: anchors[i].dy - 17,
              child: _NavIcon(
                index: i,
                currentIndex: currentIndex,
                outlined: icons[i].$1,
                filled: icons[i].$2,
              ),
            ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData outlined;
  final IconData filled;

  const _NavIcon({
    required this.index,
    required this.currentIndex,
    required this.outlined,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.7),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Icon(
        isActive ? filled : outlined,
        size: 26,
        color: isActive ? const Color(0xFFE0F7FF) : const Color(0xFFB0BEC5),
      ),
    );
  }
}

class _SpacePanelPainter extends CustomPainter {
  final double coreHeight;

  const _SpacePanelPainter({required this.coreHeight});

  static const Color _fillTop = Color(0xFF1A2A3D);
  static const Color _fillBottom = Color(0xFF0D1520);
  static const Color _frameOuter = Color(0xFF8A9BAD);
  static const Color _frameInner = Color(0xFF4A5A6D);
  static const Color _glowColor = Color(0xFF00E5FF);
  static const Color _glowSoft = Color(0xFF4FC3F7);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final panels = [
      _SpacePanelGeometry.leftPanel(w, h, coreHeight),
      _SpacePanelGeometry.centerPanel(w, h, coreHeight),
      _SpacePanelGeometry.rightPanel(w, h, coreHeight),
    ];

    for (final path in panels) {
      _drawPanel(canvas, path);
    }

    _drawStatusBar(canvas, w, h, coreHeight);
  }

  void _drawPanel(Canvas canvas, Path path) {
    final bounds = path.getBounds();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _fillTop.withValues(alpha: 0.94),
          _fillBottom.withValues(alpha: 0.98),
        ],
      ).createShader(bounds);
    canvas.drawPath(path, fillPaint);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var i = 1; i <= 2; i++) {
      final y = bounds.top + bounds.height * (i / 3.2);
      canvas.drawLine(
        Offset(bounds.left + 10, y),
        Offset(bounds.right - 10, y),
        linePaint,
      );
    }

    final frameOuter = Paint()
      ..color = _frameOuter.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, frameOuter);

    final frameInner = Paint()
      ..color = _frameInner.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, frameInner);

    for (final (color, width, blur) in [
      (_glowColor.withValues(alpha: 0.1), 4.0, 10.0),
      (_glowSoft.withValues(alpha: 0.45), 1.5, 0.0),
      (_glowColor.withValues(alpha: 0.85), 0.9, 0.0),
    ]) {
      final stroke = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = blur > 0 ? MaskFilter.blur(BlurStyle.outer, blur) : null;
      canvas.drawPath(path, stroke);
    }
  }

  void _drawStatusBar(Canvas canvas, double w, double h, double coreH) {
    const segmentCount = 10;
    const segmentW = 4.5;
    const segmentH = 2.5;
    const gap = 2.5;
    final totalW = segmentCount * segmentW + (segmentCount - 1) * gap;
    final startX = (w - totalW) / 2;
    final y = h - coreH + coreH * 0.24;

    for (var i = 0; i < segmentCount; i++) {
      final active = i < 6;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(startX + i * (segmentW + gap), y, segmentW, segmentH),
        const Radius.circular(1),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = active
              ? _glowColor.withValues(alpha: 0.85)
              : _glowColor.withValues(alpha: 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpacePanelPainter oldDelegate) =>
      oldDelegate.coreHeight != coreHeight;
}
