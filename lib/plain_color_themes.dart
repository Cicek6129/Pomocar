import 'package:flutter/material.dart';

/// Düz (resimsiz) renk temaları — Mağaza ve Ayarlar aynı listeyi kullanır.
class PlainColorThemeDef {
  final String id;
  final String shopName;
  final int price;
  final Color primary;
  final Color scaffoldLight;
  final Color cardLight;
  final Color scaffoldDark;
  final Color cardDark;

  const PlainColorThemeDef({
    required this.id,
    required this.shopName,
    this.price = 50,
    required this.primary,
    required this.scaffoldLight,
    required this.cardLight,
    required this.scaffoldDark,
    required this.cardDark,
  });

  ThemeData buildTheme({required bool isDark}) {
    return ThemeData(
      scaffoldBackgroundColor: isDark ? scaffoldDark : scaffoldLight,
      primaryColor: primary,
      cardColor: isDark ? cardDark : cardLight,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        bodyMedium: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
    );
  }

  Color get previewBackground => scaffoldLight;
  Color get previewCard => cardLight;
  Color get previewText => Colors.black87;
}

const List<PlainColorThemeDef> plainColorThemes = [
  PlainColorThemeDef(
    id: 'Yeşil',
    shopName: 'Yeşil Tema',
    primary: Color(0xFF4CAF50),
    scaffoldLight: Color(0xFFC8E6C9),
    cardLight: Color(0xFFE8F5E9),
    scaffoldDark: Color(0xFF388E3C),
    cardDark: Color(0xFF1B5E20),
  ),
  PlainColorThemeDef(
    id: 'Turuncu',
    shopName: 'Turuncu Tema',
    primary: Color(0xFFFF9800),
    scaffoldLight: Color(0xFFFFE0B2),
    cardLight: Color(0xFFFFF3E0),
    scaffoldDark: Color(0xFFF57C00),
    cardDark: Color(0xFFE65100),
  ),
  PlainColorThemeDef(
    id: 'Mavi',
    shopName: 'Mavi Tema',
    primary: Color(0xFF2196F3),
    scaffoldLight: Color(0xFFBBDEFB),
    cardLight: Color(0xFFE3F2FD),
    scaffoldDark: Color(0xFF1565C0),
    cardDark: Color(0xFF0D47A1),
  ),
  PlainColorThemeDef(
    id: 'Mor',
    shopName: 'Mor Tema',
    primary: Color(0xFF9C27B0),
    scaffoldLight: Color(0xFFE1BEE7),
    cardLight: Color(0xFFF3E5F5),
    scaffoldDark: Color(0xFF6A1B9A),
    cardDark: Color(0xFF4A148C),
  ),
  PlainColorThemeDef(
    id: 'Kırmızı',
    shopName: 'Kırmızı Tema',
    primary: Color(0xFFF44336),
    scaffoldLight: Color(0xFFFFCDD2),
    cardLight: Color(0xFFFFEBEE),
    scaffoldDark: Color(0xFFC62828),
    cardDark: Color(0xFFB71C1C),
  ),
  PlainColorThemeDef(
    id: 'Pembe',
    shopName: 'Pembe Tema',
    primary: Color(0xFFE91E63),
    scaffoldLight: Color(0xFFF8BBD9),
    cardLight: Color(0xFFFCE4EC),
    scaffoldDark: Color(0xFFAD1457),
    cardDark: Color(0xFF880E4F),
  ),
  PlainColorThemeDef(
    id: 'Lacivert',
    shopName: 'Lacivert Tema',
    primary: Color(0xFF3F51B5),
    scaffoldLight: Color(0xFFC5CAE9),
    cardLight: Color(0xFFE8EAF6),
    scaffoldDark: Color(0xFF283593),
    cardDark: Color(0xFF1A237E),
  ),
];

PlainColorThemeDef? plainColorThemeById(String id) {
  for (final theme in plainColorThemes) {
    if (theme.id == id) return theme;
  }
  return null;
}
