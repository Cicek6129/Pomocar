import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:weather_animation/weather_animation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:app_settings/app_settings.dart';
import 'package:url_launcher/url_launcher.dart';

import 'notification_service.dart';
import 'shop_view.dart';
import 'space_bottom_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeSettings,
      builder: (context, child) {
        return MaterialApp(
          title: 'Modern Pomodoro',
          theme: themeSettings.currentTheme,
          home: const PomodoroHome(),
        );
      },
    );
  }
}

class TreeModel {
  double x;
  double scale;
  double speed;
  int assetIndex; // Determine which tree image to show

  TreeModel({required this.x, required this.scale, required this.speed, required this.assetIndex});
}

class FocusSession {
  final DateTime startTime;
  final DateTime endTime;
  final String title;

  FocusSession({required this.startTime, required this.endTime, required this.title});

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'title': title,
    };
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      title: json['title'],
    );
  }
}

const Map<String, String> backgroundMusicOptions = {
  'Sessiz (Kapat)': 'Sessiz',
  'Yoğun Yağmur': 'assets/sounds/back/creatorarts-relaxing-heavy-rain-sounds-on-roof-perfect-for-sleep-focus-323383.mp3',
  'Hafif Yağmur': 'assets/sounds/back/Rain_Sound_Effect_-_Relaxation_-_Free_Download_-_No_Copyright_320k.mp3',
  'Sakin Yağmur': 'assets/sounds/back/liecio-calming-rain-257596.mp3',
  'Kuş Sesleri': 'assets/sounds/back/nils_vega-birds-singing-in-early-summer-359446.mp3',
  'Nehir Sesi': 'assets/sounds/back/dragon-studio-soothing-river-flow-372456.mp3',
  'Bahar Havası': 'assets/sounds/back/shrek_30-spring-339281.mp3',
  'Meditasyon': 'assets/sounds/back/dragon-studio-meditation-music-sound-bite-339735.mp3',
  'Çalışma (B Minor)': 'assets/sounds/back/freesound_community-study-in-b-minor-75946.mp3',
  'Chill Çalışma': 'assets/sounds/back/chill_background-study-110111.mp3',
  'Lofi Çalışma': 'assets/sounds/back/grand_project-background-lofi-hip-hop-late-night-study-502734.mp3',
  'Akustik Bahar': 'assets/sounds/back/ikoliks_aj-acoustic-spring-mothers-day-music-320427.mp3',
  'Afro Pop': 'assets/sounds/back/kontraa-water-afro-pop-music-445661.mp3',
};

String getMusicNameFromPath(String path) {
  return backgroundMusicOptions.entries
      .firstWhere((entry) => entry.value == path, orElse: () => const MapEntry('Sessiz (Kapat)', 'Sessiz'))
      .key;
}

const Map<String, String> alarmMusicOptions = {
  'Sessiz (Kapat)': 'Sessiz',
  'Sevimli Çan': 'assets/sounds/alarms/dragon-studio-cute-chime-439613.mp3',
  'Klasik Alarm': 'assets/sounds/alarms/162851__tempouser__alarm.wav',
  'Festival Çanı': 'assets/sounds/alarms/dragon-studio-festive-chime-439612.mp3',
  'Modern Zil': 'assets/sounds/alarms/163562__erh__ring-tone-cbn2-b1-93.wav',
  'Telefon Alarmı': 'assets/sounds/alarms/501880__greenworm__cellphone-alarm-clock.mp3',
  'Göksel Çan': 'assets/sounds/alarms/gigidelaromusic-celestial-chime-soft-short-450958.mp3',
};

String getAlarmNameFromPath(String path) {
  return alarmMusicOptions.entries
      .firstWhere((entry) => entry.value == path, orElse: () => const MapEntry('Sessiz (Kapat)', 'Sessiz'))
      .key;
}

// Timer Settings Controller for state management
class TimerSettingsController extends ChangeNotifier {
  bool autoStartBreak = false;
  bool autoStartPomodoro = false;
  int focusDuration = 25;
  int shortBreakDuration = 5;
  int longBreakDuration = 15;
  int totalIntervals = 4;

  TimerSettingsController() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    focusDuration = prefs.getInt('focusDuration') ?? 25;
    shortBreakDuration = prefs.getInt('shortBreakDuration') ?? 5;
    longBreakDuration = prefs.getInt('longBreakDuration') ?? 15;
    totalIntervals = prefs.getInt('totalIntervals') ?? 4;
    autoStartBreak = prefs.getBool('autoStartBreak') ?? false;
    autoStartPomodoro = prefs.getBool('autoStartPomodoro') ?? false;
    notifyListeners();
  }

  void updateAutoStartBreak(bool value) async {
    autoStartBreak = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoStartBreak', value);
    notifyListeners();
  }

  void updateAutoStartPomodoro(bool value) async {
    autoStartPomodoro = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoStartPomodoro', value);
    notifyListeners();
  }

  void updateFocusDuration(int value) async {
    focusDuration = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('focusDuration', value);
    notifyListeners();
  }

  void updateShortBreakDuration(int value) async {
    shortBreakDuration = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('shortBreakDuration', value);
    notifyListeners();
  }

  void updateLongBreakDuration(int value) async {
    longBreakDuration = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('longBreakDuration', value);
    notifyListeners();
  }

  void updateTotalIntervals(int value) async {
    totalIntervals = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalIntervals', value);
    notifyListeners();
  }
}

// Global instance for the settings controller
final timerSettings = TimerSettingsController();

// Theme Settings Controller for global theme management
class ThemeSettingsController extends ChangeNotifier {
  bool isDarkMode = false;
  String activeColorTheme = 'Varsayılan';

  // Base Light/Dark (Varsayılan)
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFE0E0E0),
    primaryColor: const Color(0xFF4CAF50),
    cardColor: const Color(0xFFE0E0E0),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black54),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50), brightness: Brightness.light),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black87,
    primaryColor: const Color(0xFF4CAF50),
    cardColor: Colors.black38,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50), brightness: Brightness.dark),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  // İskandinavya
  static final ThemeData iskandinavyaTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFE0F7FA),
    primaryColor: const Color(0xFF00ACC1),
    cardColor: const Color(0xFFB2EBF2),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00ACC1), brightness: Brightness.light),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  // Derin Uzay
  static final ThemeData derinUzayTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF0A1628),
    primaryColor: const Color(0xFF00E5FF),
    cardColor: const Color(0xFF1A2744),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00E5FF), brightness: Brightness.dark),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  // Yeşil (Green)
  static final ThemeData greenDarkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF388E3C),
    primaryColor: const Color(0xFF4CAF50),
    cardColor: const Color(0xFF1B5E20),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50), brightness: Brightness.dark),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  static final ThemeData greenLightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFC8E6C9),
    primaryColor: const Color(0xFF4CAF50),
    cardColor: const Color(0xFFE8F5E9),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50), brightness: Brightness.light),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  // Turuncu (Orange)
  static final ThemeData orangeDarkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF57C00),
    primaryColor: const Color(0xFFFF9800),
    cardColor: const Color(0xFFE65100),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF9800), brightness: Brightness.dark),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  static final ThemeData orangeLightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFFFE0B2),
    primaryColor: const Color(0xFFFF9800),
    cardColor: const Color(0xFFFFF3E0),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF9800), brightness: Brightness.light),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  // Japon and Mısır
  static final ThemeData japonTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFFCE4EC),
    primaryColor: const Color(0xFFE91E63),
    cardColor: const Color(0xFFF8BBD0),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE91E63), brightness: Brightness.light),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  static final ThemeData misirTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFFFF8E1),
    primaryColor: const Color(0xFFFFC107),
    cardColor: const Color(0xFFFFECB3),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFC107), brightness: Brightness.light),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  ThemeSettingsController() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Migration from old logic where 'Açık'/'Koyu' were names.
    String savedTheme = prefs.getString('theme_color_key') ?? prefs.getString('theme_key') ?? 'Varsayılan';
    if (savedTheme == 'Açık') {
      isDarkMode = false;
      activeColorTheme = 'Varsayılan';
    } else if (savedTheme == 'Koyu') {
      isDarkMode = true;
      activeColorTheme = 'Varsayılan';
    } else {
      activeColorTheme = switch (savedTheme) {
        'Mor' => 'İskandinavya',
        'Mavi' => 'Derin Uzay',
        _ => savedTheme,
      };
      isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    }
    
    notifyListeners();
  }

  void updateDarkMode(bool isDark) async {
    isDarkMode = isDark;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
    notifyListeners();
  }

  void updateTheme(String themeName) async {
    activeColorTheme = themeName;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_color_key', themeName);
    notifyListeners();
  }

  ThemeData get currentTheme {
    // Static themes ignore dark mode
    if (activeColorTheme == 'Japon') return japonTheme;
    if (activeColorTheme == 'Mısır') return misirTheme;
    if (activeColorTheme == 'İskandinavya') return iskandinavyaTheme;
    if (activeColorTheme == 'Derin Uzay') return derinUzayTheme;

    switch (activeColorTheme) {
      case 'Yeşil': return isDarkMode ? greenDarkTheme : greenLightTheme;
      case 'Turuncu': return isDarkMode ? orangeDarkTheme : orangeLightTheme;
      case 'Varsayılan':
      default:
        return isDarkMode ? darkTheme : lightTheme;
    }
  }
}

// Global instance for theme settings
final themeSettings = ThemeSettingsController();

// Garage / Market Controller for state management
class GarageController extends ChangeNotifier {
  int totalFocusMinutes = 0; // Kullanıcının parası
  List<String> unlockedCars = ['car_1']; // Alınan arabalar
  String equippedCar = 'car_1'; // Şu an seçili olan araba

  // Market için basit araba listesi (Model/Map)
  final List<Map<String, dynamic>> carList = [
    {
      'id': 'car_1',
      'name': 'Başlangıç Arabası',
      'price': 0,
      'image': 'assets/cars/car_1.png'
    },
    {
      'id': 'car_2',
      'name': 'Hızlı Araba',
      'price': 1,
      'image': 'assets/cars/car_2.png'
    },
    {
      'id': 'car_3',
      'name': 'Spor Araba',
      'price': 2,
      'image': 'assets/cars/car_3.png'
    },
  ];

  GarageController() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    totalFocusMinutes = prefs.getInt('totalFocusMinutes') ?? 0;
    unlockedCars = prefs.getStringList('unlockedCars') ?? ['car_1'];
    equippedCar = prefs.getString('equippedCar') ?? 'car_1';
    notifyListeners();
  }

  Future<void> saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalFocusMinutes', totalFocusMinutes);
    await prefs.setStringList('unlockedCars', unlockedCars);
    await prefs.setString('equippedCar', equippedCar);
  }
}

// Global instance for garage system
final garageController = GarageController();

class PomodoroHome extends StatefulWidget {
  const PomodoroHome({super.key});

  @override
  State<PomodoroHome> createState() => _PomodoroHomeState();
}

class _PomodoroHomeState extends State<PomodoroHome>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _workTimeInMinutes = 25;
  int completedSessions = 0; // tracking how many pomodoros completed
  
  late int _totalSeconds;
  late int _secondsRemaining;
  late ValueNotifier<int> _secondsRemainingNotifier;
  Timer? _timer;
  bool _isRunning = false;
  bool _isBreakMode = false; // To track if current timer is for a break

  // Navigation State
  int _bottomNavIndex = 0;
  Key _settingsKey = UniqueKey();

  // Statistics State
  int _todayFocusCount = 0;
  int _todayFocusMinutes = 0;
  int _monthlyFocusCount = 0;
  int _monthlyFocusMinutes = 0;
  int _monthlyFocusDays = 0;

  // Gamification Economy
  int _totalKm = 0;

  // Timeline State
  final List<FocusSession> _sessionHistory = [];
  final TextEditingController _focusTaskController = TextEditingController();
  DateTime? _currentSessionStartTime;

  // Calendar State
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // Animation States
  late AnimationController _animationController;
  final List<TreeModel> _trees = [];
  final Random _random = Random();
  String _currentWeather = 'clear'; // 'clear', 'rain', 'snow'
  
  // Audio Player
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _alarmPlayer = AudioPlayer();
  final AudioPlayer _previewPlayer = AudioPlayer();
  bool _isPlayingMusic = false;
  String _currentPlayingAsset = '';

  // Dynamic Car Path
  String _equippedCarPath = 'assets/car/car1.png';
  double _equippedCarScale = 1.0;

  // Dynamic Tree Paths
  List<String> _activeTrees = ['tree1', 'tree2', 'tree3'];
  
  // Dynamic Calilar Paths
  List<String> _activeCalilar = ['bush0', 'rock0'];
  final List<TreeModel> _bushes = [];  // Row 1
  final List<TreeModel> _bushes2 = []; // Row 2
  final List<TreeModel> _bushes3 = []; // Row 3 (lowest)

  // Add the list of tree assets to use
  final List<String> _treeAssets = [
    'assets/tree/Ağaç1.PNG',
    'assets/tree/Ağaç2.PNG',
    'assets/tree/Ağaç3.PNG',
    'assets/tree/Ağaç4.PNG',
    'assets/tree/png-transparent-pine-tree-fir-black-trees-s-christmas-decoration-website-spruce.png', // Keeping the original single tree as an extra option
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Request notification permission
    NotificationService().requestPermission();

    // Use dynamic settings from the start
    _workTimeInMinutes = timerSettings.focusDuration;
    _totalSeconds = _workTimeInMinutes * 60;
    _secondsRemaining = _totalSeconds;
    _secondsRemainingNotifier = ValueNotifier<int>(_secondsRemaining);

    // Listen to changes in timer settings to dynamically update the view if stopped
    timerSettings.addListener(_onGlobalSettingsChanged);

    // Load statistics from SharedPreferences
    _loadStatistics();

    // Initialize constant trees to avoid jitter
    for (int i = 0; i < 8; i++) {
        _trees.add(TreeModel(
            x: i * 150.0 + _random.nextDouble() * 50,
            scale: 0.8 + _random.nextDouble() * 0.5, // Random size between 0.8x and 1.3x
            speed: 2.0 + _random.nextDouble() * 0.5, // Slight speed variance for depth
            assetIndex: _random.nextInt(2), // Randomly pick from available tree assets
        ));
    }

    // Row 1 - mixed (~60% bush 40% rock), 7 items
    for (int i = 0; i < 7; i++) {
        bool isBush = _random.nextDouble() < 0.5;
        _bushes.add(TreeModel(
            x: i * 140.0 + 20.0,
            scale: isBush ? 1.0 + _random.nextDouble() * 0.3 : 0.75 + _random.nextDouble() * 0.2,
            speed: 2.5 + _random.nextDouble() * 0.5,
            assetIndex: isBush ? 0 : 1, // 0=bush, 1=rock
        ));
    }

    // Row 2 - mixed (~60% bush 40% rock), 6 items staggered
    for (int i = 0; i < 6; i++) {
        bool isBush = _random.nextDouble() < 0.5;
        _bushes2.add(TreeModel(
            x: i * 140.0 + 80.0,
            scale: isBush ? 1.0 + _random.nextDouble() * 0.3 : 0.75 + _random.nextDouble() * 0.2,
            speed: 2.5 + _random.nextDouble() * 0.5,
            assetIndex: isBush ? 0 : 1,
        ));
    }

    // Row 3 - lowest row, mixed, 5 items
    for (int i = 0; i < 5; i++) {
        bool isBush = _random.nextDouble() < 0.5;
        _bushes3.add(TreeModel(
            x: i * 140.0 + 50.0,
            scale: isBush ? 0.9 + _random.nextDouble() * 0.3 : 0.65 + _random.nextDouble() * 0.2,
            speed: 2.5 + _random.nextDouble() * 0.5,
            assetIndex: isBush ? 0 : 1,
        ));
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Tick every second roughly for smooth animation loop
    )..repeat();
    _animationController.stop();
  }

  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load session history
    final String? sessionsJson = prefs.getString('session_history');
    if (sessionsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(sessionsJson);
        setState(() {
          _sessionHistory.clear();
          for (var item in decoded) {
            _sessionHistory.add(FocusSession.fromJson(item));
          }
          _recalculateStats();
        });
      } catch (e) {
        debugPrint('Error loading sessions: $e');
      }
    }
    
    // Load gamification money (Km)
    _totalKm = (prefs.getInt('total_km') ?? 0) + 1000; // Test için eklendi
    await prefs.setInt('total_km', _totalKm);
    
    String equippedCarId = prefs.getString('equipped_garaj') ?? 'car1';
    List<String> eqTrees = prefs.getStringList('equipped_trees') ?? ['tree1', 'tree2', 'tree3'];
    List<String> eqCalilar = prefs.getStringList('equipped_calilar') ?? ['bush0', 'rock0'];

    setState(() {
      final equippedCar = allShopItems.firstWhere(
        (item) => item.id == equippedCarId, 
        orElse: () => allShopItems[0]
      );
      _equippedCarPath = equippedCar.imagePath ?? 'assets/car/car1.png';
      _equippedCarScale = equippedCar.imageScale;
      
      _activeTrees = eqTrees;
      _activeCalilar = eqCalilar;
    });
  }

  Future<void> _saveStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> sessionsList = _sessionHistory.map((s) => s.toJson()).toList();
    await prefs.setString('session_history', jsonEncode(sessionsList));
    await prefs.setInt('total_km', _totalKm);
  }

  void _recalculateStats() {
    // When history is loaded or date changes, recalculate the metrics for the selected day and current month
    _todayFocusCount = 0;
    _todayFocusMinutes = 0;
    _monthlyFocusCount = 0;
    _monthlyFocusMinutes = 0;
    
    Set<String> uniqueDaysInMonth = {};

    for (var session in _sessionHistory) {
      // Today Stats
      if (isSameDay(session.startTime, _selectedDay)) {
        _todayFocusCount++;
        _todayFocusMinutes += session.endTime.difference(session.startTime).inMinutes;
      }
      
      // Monthly Stats
      if (session.startTime.year == _focusedDay.year && session.startTime.month == _focusedDay.month) {
        _monthlyFocusCount++;
        _monthlyFocusMinutes += session.endTime.difference(session.startTime).inMinutes;
        uniqueDaysInMonth.add('${session.startTime.year}-${session.startTime.month}-${session.startTime.day}');
      }
    }
    
    _monthlyFocusDays = uniqueDaysInMonth.length;
  }


  void _onGlobalSettingsChanged() {
    // If the timer is NOT running, automatically adjust the current displayed time
    // depending on whether we are in focus or break mode
    if (!_isRunning) {
       setState(() {
          if (!_isBreakMode) {
             _workTimeInMinutes = timerSettings.focusDuration;
          } else {
             bool isLongBreak = (completedSessions > 0 && completedSessions % timerSettings.totalIntervals == 0);
             _workTimeInMinutes = isLongBreak ? timerSettings.longBreakDuration : timerSettings.shortBreakDuration;
          }
          _totalSeconds = _workTimeInMinutes * 60;
          _secondsRemaining = _totalSeconds;
          _secondsRemainingNotifier.value = _secondsRemaining;
       });
    }
  }

  @override
  void dispose() {
    timerSettings.removeListener(_onGlobalSettingsChanged);
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable(); // Ensure wakelock is released
    _timer?.cancel();
    _animationController.dispose();
    _audioPlayer.dispose();
    _alarmPlayer.dispose();
    _previewPlayer.dispose();
    _secondsRemainingNotifier.dispose();
    _focusTaskController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      final prefs = await SharedPreferences.getInstance();
      bool isDeepFocus = prefs.getBool('deepFocusEnabled') ?? false;

      if (_isRunning && isDeepFocus) {
        // App went to background during deep focus!
        _stopTimer();
        _showCarCrashDialog();
      }
    }
  }

  void _showCarCrashDialog() {
    // Show this dialog when user comes back (or immediately if inactive allows)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              title: const Column(
                children: [
                   Icon(Icons.directions_car, color: Colors.red, size: 60),
                   SizedBox(height: 10),
                   Text(
                    'Odaklanma Bozuldu!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: const Text(
                'Uygulamadan çıktığın için araba kaza yaptı!\nPomodoro sayacın durduruldu.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF37474F)),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetTimer();
                  },
                  child: const Text('Anladım', style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _startTimer() async {
    if (_secondsRemaining <= 0) return;

    if (_timer != null) {
      _timer!.cancel();
    }
    
    final prefs = await SharedPreferences.getInstance();
    bool isWakelockEnabled = prefs.getBool('wakeLockEnabled') ?? false;
    if (isWakelockEnabled) {
      WakelockPlus.enable();
    }

    setState(() {
      _isRunning = true;
      if (!_isBreakMode) {
         _currentSessionStartTime = DateTime.now();
      }
      _animationController.repeat();
    });
    
    try {
        final prefs = await SharedPreferences.getInstance();
        bool isSilentMode = prefs.getBool('silentMode') ?? false;
        String bgMusicPath = prefs.getString('bgMusicPath') ?? 'Sessiz';
        String breakMusicPath = prefs.getString('breakMusicPath') ?? 'Sessiz';
        
        if (!isSilentMode) {
            String targetPath = _isBreakMode ? breakMusicPath : bgMusicPath;
            if (targetPath != 'Sessiz') {
                await _audioPlayer.setReleaseMode(ReleaseMode.loop);
                String assetPath = targetPath.replaceAll('assets/', '');
                await _audioPlayer.play(kIsWeb ? UrlSource(targetPath) : AssetSource(assetPath));
                setState(() { _isPlayingMusic = true; });
            } else {
                await _audioPlayer.pause();
                setState(() { _isPlayingMusic = false; });
            }
        } else {
            await _audioPlayer.pause();
            setState(() { _isPlayingMusic = false; });
        }
    } catch (e) {
        debugPrint("Could not play loop sound: $e");
    }
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        _secondsRemainingNotifier.value = _secondsRemaining;
      } else {
        setState(() {
          // Timer finished naturally
          _stopTimer();
          if (!_isBreakMode) {
             // Pomodoro Work Session Finished
             completedSessions++; // Track completed Pomodoros for the 4-break logic
             _recordSession();
             NotificationService().showNotification(
                id: 1,
                title: 'Hedefe Ulaşıldı! 🏁',
                body: 'Harika iş çıkardın, araba park edildi. Şimdi mola vakti!',
             );
             
             if (timerSettings.autoStartBreak) {
                // Auto-start break logic
                bool isLongBreak = (completedSessions > 0 && completedSessions % timerSettings.totalIntervals == 0);
                int breakDuration = isLongBreak ? timerSettings.longBreakDuration : timerSettings.shortBreakDuration;
                
                _isBreakMode = true;
                _workTimeInMinutes = breakDuration;
                _totalSeconds = breakDuration * 60;
                _secondsRemaining = _totalSeconds;
                _secondsRemainingNotifier.value = _secondsRemaining;
                // Start break automatically
                _startTimer();
             } else {
                _showCompletionDialog();
             }
          } else {
             // Break Session Finished
             NotificationService().showNotification(
                id: 2,
                title: 'Yolculuk Başlıyor! 🚗',
                body: 'Mola bitti, kontağı çalıştırma ve yeniden odaklanma zamanı.',
             );
             _isBreakMode = false;
             
             if (timerSettings.autoStartPomodoro) {
                 // Auto-start pomodoro logic
                 _workTimeInMinutes = timerSettings.focusDuration;
                 _totalSeconds = _workTimeInMinutes * 60;
                 _secondsRemaining = _totalSeconds;
                 _secondsRemainingNotifier.value = _secondsRemaining;
                 // Start pomodoro automatically
                 _startTimer();
             } else {
                 _showBreakContinuationDialog();
             }
          }
        });
      }
    });
  }

  void _stopTimer() {
    WakelockPlus.disable(); // Release wakelock when timer stops
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _isRunning = false;
      _animationController.stop();
    });
    try {
      _audioPlayer.pause();
    } catch (e) {
      debugPrint("Could not pause audio: $e");
    }
  }

  void _recordSession() {
    DateTime endTime = DateTime.now();
    String title = _focusTaskController.text.trim();
    if (title.isEmpty) {
      title = "Odaklanma Oturumu";
    }

    setState(() {
      if (_currentSessionStartTime != null) {
        // Only award Km if enough time actually passed, or simply rely on the natural finish. 
        // We give them 1 Km per 1 minute of focus.
        // As a fallback/reward, give at least 1 Km if they somehow finished early but trigger this, 
        // or cap it to _workTimeInMinutes. Since this is only called on success, we add the full workTimeInMinutes.
        int awardedKm = _workTimeInMinutes; 
        _totalKm += awardedKm;
        
        _sessionHistory.add(FocusSession(
          startTime: _currentSessionStartTime!,
          endTime: endTime,
          title: title,
        ));
      }
      _recalculateStats();
    });
    
    _saveStatistics();
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      if (!_isBreakMode) {
        _workTimeInMinutes = timerSettings.focusDuration;
      } else {
        bool isLongBreak = (completedSessions > 0 && completedSessions % timerSettings.totalIntervals == 0);
        _workTimeInMinutes = isLongBreak ? timerSettings.longBreakDuration : timerSettings.shortBreakDuration;
      }
      _totalSeconds = _workTimeInMinutes * 60;
      _secondsRemaining = _totalSeconds;
      _secondsRemainingNotifier.value = _secondsRemaining;
    });
  }

  void _showCupertinoTimePicker() {
    int tempTotalMinutes = _workTimeInMinutes;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext builder) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          backgroundColor: const Color(0xFFF3F4F6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Close Button
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Süreyi Belirle',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close, color: Colors.grey, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Picker Area
                SizedBox(
                  height: 200,
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: Duration(minutes: _workTimeInMinutes),
                    onTimerDurationChanged: (Duration changedtimer) {
                      tempTotalMinutes = changedtimer.inMinutes;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                
                // Full-width Soft Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (tempTotalMinutes > 0) {
                        setState(() {
                          _workTimeInMinutes = tempTotalMinutes;
                          _totalSeconds = _workTimeInMinutes * 60;
                          _secondsRemaining = _totalSeconds;
                          _secondsRemainingNotifier.value = _secondsRemaining;
                        });
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text('AYARLA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showMusicSelectionDialog() async {
    final prefs = await SharedPreferences.getInstance();
    String currentBgMusic = prefs.getString('bgMusicPath') ?? 'Sessiz';
    
    final Map<String, String> options = backgroundMusicOptions;

    String tempSelectedPath = currentBgMusic;
    List<String> unlockedSounds = prefs.getStringList('purchased_items') ?? [];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
              backgroundColor: const Color(0xFFF3F4F6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Arka Plan Müziği',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: options.entries.map((entry) {
                            bool isFree = entry.value == 'Sessiz' || entry.value == 'assets/sounds/back/creatorarts-relaxing-heavy-rain-sounds-on-roof-perfect-for-sleep-focus-323383.mp3';
                            bool isLocked = !isFree && !unlockedSounds.contains(entry.value);

                            return Column(
                               children: [
                                 ListTile(
                                   leading: entry.value != 'Sessiz' ? IconButton(
                                     icon: Icon(isLocked ? Icons.lock : Icons.play_circle_fill, color: isLocked ? Colors.grey : Theme.of(context).primaryColor, size: 32),
                                     onPressed: () async {
                                       if (isLocked) return;
                                       try {
                                         await _previewPlayer.stop();
                                         String assetPath = entry.value.replaceAll('assets/', '');
                                         await _previewPlayer.play(kIsWeb ? UrlSource(entry.value) : AssetSource(assetPath));
                                       } catch (e) {
                                         debugPrint("Could not play bg preview: $e");
                                       }
                                     },
                                   ) : const SizedBox(width: 48, child: Icon(Icons.volume_off, color: Colors.grey)),
                                   title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.w500, color: isLocked ? Colors.grey : Colors.black87)),
                                   trailing: tempSelectedPath == entry.value 
                                       ? Icon(Icons.radio_button_checked, color: Theme.of(context).primaryColor) 
                                       : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                   onTap: () {
                                     if (isLocked) {
                                       Navigator.of(context).pop();
                                       setState(() { _bottomNavIndex = 1; });
                                     } else {
                                       setDialogState(() {
                                         tempSelectedPath = entry.value;
                                       });
                                     }
                                   },
                                   onLongPress: () {
                                     if (isLocked) {
                                       Navigator.of(context).pop();
                                       setState(() { _bottomNavIndex = 1; });
                                     } else {
                                       setDialogState(() {
                                         tempSelectedPath = entry.value;
                                       });
                                     }
                                   },
                                 ),
                                 const Divider(),
                               ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          await _previewPlayer.stop();
                          await prefs.setString('bgMusicPath', tempSelectedPath);
                          
                          if (mounted) {
                            setState(() {
                              _isPlayingMusic = tempSelectedPath != 'Sessiz';
                            });
                          }
                          
                          // If timer is running and we are in focus mode, apply immediately
                          if (_isRunning && !_isBreakMode) {
                              try {
                                  bool isSilentMode = prefs.getBool('silentMode') ?? false;
                                  if (!isSilentMode && tempSelectedPath != 'Sessiz') {
                                      String assetPath = tempSelectedPath.replaceAll('assets/', '');
                                      
                                      if (_currentPlayingAsset != assetPath) {
                                          await _audioPlayer.stop();
                                          await _audioPlayer.setReleaseMode(ReleaseMode.loop);
                                          _currentPlayingAsset = assetPath;
                                          await _audioPlayer.play(kIsWeb ? UrlSource(tempSelectedPath) : AssetSource(assetPath));
                                      } else {
                                          await _audioPlayer.resume();
                                      }
                                  } else {
                                      await _audioPlayer.pause();
                                  }
                              } catch (e) {
                                  debugPrint("Failed to play preview/bg music: $e");
                              }
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Kaydet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    ).then((_) {
      _previewPlayer.stop();
    });
  }

  void _showWeatherSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          backgroundColor: const Color(0xFFF3F4F6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hava Durumu Seçimi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.water_drop, color: Colors.blue),
                  title: const Text('Yağmur'),
                  trailing: _currentWeather == 'rain' ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        _currentWeather = 'rain';
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.ac_unit, color: Colors.lightBlueAccent),
                  title: const Text('Kar'),
                  trailing: _currentWeather == 'snow' ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        _currentWeather = 'snow';
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.wb_sunny, color: Colors.orange),
                  title: const Text('Açık Hava'),
                  trailing: _currentWeather == 'clear' ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        _currentWeather = 'clear';
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _playAlarmSound() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isSilentMode = prefs.getBool('silentMode') ?? false;
      if (isSilentMode) return;
      
      String alarmSound = prefs.getString('alarmSound') ?? 'assets/sounds/alarms/dragon-studio-cute-chime-439613.mp3';
      if (alarmSound == 'Sessiz') return;
      
      String assetPath = alarmSound.replaceAll('assets/', '');
      Source source = kIsWeb ? UrlSource(alarmSound) : AssetSource(assetPath);
      
      await _alarmPlayer.play(source);
    } catch (e) {
      debugPrint("Could not play alarm: $e");
    }
  }

  void _showCompletionDialog() {
    _playAlarmSound();

    bool isLongBreak = (completedSessions > 0 && completedSessions % timerSettings.totalIntervals == 0);
    int breakDuration = isLongBreak ? timerSettings.longBreakDuration : timerSettings.shortBreakDuration;
    
    String dialogTitle = isLongBreak ? 'Tebrikler! ${timerSettings.totalIntervals} Pomodoro tamamladın.' : 'Tebrikler!';
    String dialogText = isLongBreak 
        ? 'Şimdi $breakDuration dakikalık uzun bir mola yapma zamanı!'
        : 'Bir Pomodoro seansını daha başarıyla tamamladın.\nŞimdi $breakDuration dakikalık bir mola yapmak ister misin?';

    showDialog(
      context: context,
      barrierDismissible: false, // Force user to choose
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Column(
            children: [
              Icon(Icons.sports_score, color: Theme.of(context).primaryColor, size: 60),
              const SizedBox(height: 10),
              Text(
                dialogTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            dialogText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Color(0xFF37474F)),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Reset to standard original time if they don't want a break
                _isBreakMode = false;
                _resetTimer();
              },
              child: const Text('Hayır, Teşekkürler', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Start break dynamically Based on Modulo Control
                setState(() {
                  _isBreakMode = true;
                  _workTimeInMinutes = breakDuration;
                  _totalSeconds = breakDuration * 60;
                  _secondsRemaining = _totalSeconds;
                });
              },
              // Update button text to match duration dynamically
              child: Text(isLongBreak ? 'Başla ($breakDuration dk)' : 'Evet, Mola Ver', style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ],
        );
      },
    );
  }

  void _showBreakContinuationDialog() {
    _playAlarmSound();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Column(
            children: [
              Icon(Icons.timer, color: Theme.of(context).primaryColor, size: 60),
              const SizedBox(height: 10),
              Text(
                'Mola Bitti!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            'Molan sona erdi.\nYeni bir ${timerSettings.focusDuration} dakikalık odaklanma oturumuna başlamak ister misin?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Color(0xFF37474F)),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _resetTimer();
              },
              child: const Text('Sonra', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                    _workTimeInMinutes = timerSettings.focusDuration;
                    _totalSeconds = _workTimeInMinutes * 60;
                    _secondsRemaining = _totalSeconds;
                });
                _startTimer();
              },
              child: const Text('Başla', style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ],
        );
      },
    );
  }
  
  void _onBottomNavTapped(int index) {
    if (index == 3) {
      // Force settings sub-pages to reset when tapping settings index
      _settingsKey = UniqueKey();
    }
    setState(() {
      _bottomNavIndex = index;
    });
  }

  // Note: The screenshot shows Tamam on the left, İptal on the right. 
  // We will correct the logic: Tamam executes reset, İptal cancels.
  // Re-define clearly to fix above logic
  void _showResetConfirmationDialog() {
      showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF3F4F6), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          title: Text(
            'Zamanlayıcıyı Yeniden Başlat',
            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Zamanlayıcıyı yeniden başlatmak istediğinizden emin misiniz?',
            style: TextStyle(color: Color(0xFF37474F), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                  Navigator.of(context).pop();
                  _resetTimer();
              },
              child: const Text('Tamam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
            ),
          ],
        );
      },
    );
  }

  void _showEndSessionConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF3F4F6), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          title: Text(
            'Oturumu Sonlandır',
            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Zamanlayıcıyı kapatmak istediğinizden emin misiniz? Devam eden bu oturum kaydedilmeyecektir.',
            style: TextStyle(color: Color(0xFF37474F), fontSize: 14, height: 1.4),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935), // Pastel red to signify stopping
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                  Navigator.of(context).pop();
                  _resetTimer();
              },
              child: const Text('Tamam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
            ),
          ],
        );
      },
    );
  }


  Widget _buildStatsView() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Calendar View
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay; 
                          _recalculateStats(); // Recalculate stats when a new day/month is selected
                        });
                      },
                      onHeaderTapped: (focusedDay) {
                        _selectMonthYear(context);
                      },
                      calendarFormat: CalendarFormat.month,
                      eventLoader: (day) {
                        return _sessionHistory.where((session) => isSameDay(session.startTime, day)).toList();
                      },
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isEmpty) return const SizedBox();
                          
                          Color markerColor;
                          if (events.length == 1) {
                            markerColor = Colors.green.shade300;
                          } else if (events.length == 2) {
                            markerColor = Colors.green.shade500;
                          } else if (events.length == 3) {
                            markerColor = Colors.green.shade700;
                          } else {
                            markerColor = Colors.green.shade900;
                          }

                          return Positioned(
                            bottom: 6,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: markerColor,
                              ),
                            ),
                          );
                        },
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF37474F)),
                        leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF37474F)),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF37474F)),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: Color(0xFF37474F)),
                        weekendStyle: TextStyle(color: Color(0xFF37474F)),
                      ),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        todayDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).primaryColor, width: 2), // Theme color border for today
                        ),
                        todayTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                        selectedDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor, // Solid theme color for selected day
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: const TextStyle(color: Color(0xFF37474F)),
                        weekendTextStyle: const TextStyle(color: Color(0xFF37474F)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              // Selected Day's abstract (Date header)
              Text(
                _selectedDay != null ? DateFormat('MM / dd').format(_selectedDay!) : '',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF37474F)),
              ),
              const SizedBox(height: 10),
              // Today's Stats
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildStatRow('Odaklanma Sayısı', '$_todayFocusCount kez'),
                    const SizedBox(height: 16),
                    _buildStatRow('Odaklanma Süresi', '$_todayFocusMinutes dk'),
                  ],
                ),
              ),
              _buildDailyTimeline(),
              const SizedBox(height: 25),
              // Monthly Overview Header
              const Text(
                'Aylık Özet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF37474F)),
              ),
              const SizedBox(height: 10),
              // Monthly Stats
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildStatRow('Aylık Odaklanma Sayısı', '$_monthlyFocusCount kez'),
                    const SizedBox(height: 16),
                    _buildStatRow('Aylık Odaklanma Süresi', '$_monthlyFocusMinutes dk'),
                    const SizedBox(height: 16),
                    _buildStatRow('Aylık Odaklanma Günü', '$_monthlyFocusDays / 30 kez'),
                    const SizedBox(height: 16),
                    _buildStatRow('Tamamlanan Oturumlar', '$_monthlyFocusCount oturum'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF37474F), fontSize: 16, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 16)),
      ],
    );
  }

  Widget _buildDailyTimeline() {
    // Filter history for selected day
    List<FocusSession> dailySessions = _sessionHistory.where((s) {
      if (_selectedDay == null) return false;
      return isSameDay(s.startTime, _selectedDay);
    }).toList();

    if (dailySessions.isEmpty) {
      return const SizedBox.shrink(); // Show nothing if no sessions
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 25),
        const Text(
          'Seyir Defteri',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF37474F)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailySessions.length,
            separatorBuilder: (context, index) => const Divider(height: 20, color: Colors.black12),
            itemBuilder: (context, index) {
              final session = dailySessions[index];
              final startStr = DateFormat('HH:mm').format(session.startTime);
              final endStr = DateFormat('HH:mm').format(session.endTime);
              return Row(
                children: [
                  Text(
                    '$startStr - $endStr',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      session.title,
                      style: const TextStyle(color: Color(0xFF37474F), fontSize: 14, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'AY VE YIL SEÇİN',
      cancelText: 'İPTAL',
      confirmText: 'TAMAM',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: const Color(0xFF37474F), // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _focusedDay) {
      setState(() {
        _focusedDay = picked;
        _selectedDay = picked;
      });
    }
  }

  Widget _buildSettingsView() {
    return SettingsView(
      key: _settingsKey,
      onNavigateToMarket: () {
        setState(() {
          _bottomNavIndex = 1; // Market index
        });
      },
    );
  }


  Widget _buildTimerView() {
    final String? themeBackgroundPath = switch (themeSettings.activeColorTheme) {
      'Japon' => 'assets/backgrounds/japan_bg.png',
      'Mısır' => 'assets/backgrounds/egypt_bg.png',
      'İskandinavya' => 'assets/backgrounds/scandinavia_bg.png',
      'Derin Uzay' => 'assets/backgrounds/space_bg.png',
      _ => null,
    };
    final bool hasThemeBackground = themeBackgroundPath != null;
    
    Widget timerContent = GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 70), // Increased top spacing to push content down
              // --- Focus Task Input ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: TextField(
                  controller: _focusTaskController,
                  textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Şu an neye odaklanıyorsun?',
                  hintStyle: TextStyle(color: Theme.of(context).primaryColor.withValues(alpha: 0.5), fontSize: 20, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            // --- Modern Circular Animation View ---
            Center(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none, 
                children: [
                   // Base to expand Stack bounds for hit-testing
                   const SizedBox(width: 380, height: 380),
                   // The Circular Progress Bar Border
                   SizedBox(
                     width: 336, // Slightly larger than the main circle (320 + border thickness * 2)
                     height: 336,
                     // We flip it horizontally so that it fills/depletes from Right to Left (Counter-clockwise)
                     child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(pi), 
                        child: ValueListenableBuilder<int>(
                           valueListenable: _secondsRemainingNotifier,
                           builder: (context, secondsRemaining, child) {
                              return CircularProgressIndicator(
                                 value: secondsRemaining / (_totalSeconds > 0 ? _totalSeconds : 1), 
                                 strokeWidth: 8,
                                 color: Theme.of(context).primaryColor,
                                 backgroundColor: Colors.grey[300],
                              );
                           },
                        ),
                     ),
                   ),
                   // Main Circular View
                   Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      // Removed inner white border because the progress indicator acts as the border now,
                      // but we can keep a thin white border if needed, or remove it entirely.
                      // Let's keep a very thin white separator for neatness.
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                child: ClipOval(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                        // Move trees logic
                      if (_isRunning) {
                        for (var tree in _trees) {
                          // Reduced speed by half
                          tree.x -= tree.speed * 0.4; 
                          // Reset tree when it goes off screen
                          if (tree.x < -50) {
                            tree.x = 400 + _random.nextDouble() * 100;
                            tree.scale = 0.8 + _random.nextDouble() * 0.5;
                            tree.speed = 2.0 + _random.nextDouble() * 0.5;
                            tree.assetIndex = _random.nextInt(_treeAssets.length); // Pick a new random tree when wrapping
                          }
                        }
                        
                        for (var bush in _bushes) {
                          bush.x -= bush.speed * 0.4;
                          if (bush.x < -80) {
                            bush.x = 400 + 20.0;
                            bool isBush = _random.nextDouble() < 0.5;
                            bush.scale = isBush ? 1.0 + _random.nextDouble() * 0.3 : 0.75 + _random.nextDouble() * 0.2;
                            bush.speed = 2.5 + _random.nextDouble() * 0.5;
                            bush.assetIndex = isBush ? 0 : 1;
                          }
                        }
                        for (var bush in _bushes2) {
                          bush.x -= bush.speed * 0.4;
                          if (bush.x < -80) {
                            bush.x = 400 + 20.0;
                            bool isBush = _random.nextDouble() < 0.5;
                            bush.scale = isBush ? 1.0 + _random.nextDouble() * 0.3 : 0.75 + _random.nextDouble() * 0.2;
                            bush.speed = 2.5 + _random.nextDouble() * 0.5;
                            bush.assetIndex = isBush ? 0 : 1;
                          }
                        }
                        for (var bush in _bushes3) {
                          bush.x -= bush.speed * 0.4;
                          if (bush.x < -80) {
                            bush.x = 400 + 20.0;
                            bool isBush = _random.nextDouble() < 0.5;
                            bush.scale = isBush ? 0.9 + _random.nextDouble() * 0.3 : 0.65 + _random.nextDouble() * 0.2;
                            bush.speed = 2.5 + _random.nextDouble() * 0.5;
                            bush.assetIndex = isBush ? 0 : 1;
                          }
                        }
                      }

                      return Stack(
                        children: [
                          // 1. Sky Gradient Background (Re-added here as base layer)
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF87CEEB), Color(0xFFE0F7FA)],
                              ),
                            ),
                          ),
                          // 2. Distant Mountains
                          Positioned(
                             left: -50,
                             bottom: 80,
                             child: CustomPaint(
                               size: const Size(500, 200),
                               painter: DistantMountainPainter(),
                             ),
                          ),
                          // 3. Moving Trees (Behind the Slope)
                          ..._trees.map((tree) => Positioned(
                                left: tree.x,
                                bottom: (tree.x * 0.375) + 75,
                                    child: Transform.rotate(
                                        angle: -0.358,
                                        child: Transform.scale(
                                            scale: 1.2 + ((tree.scale - 0.8) * 2.0), 
                                            alignment: Alignment.bottomCenter,
                                            child: SizedBox(
                                                width: 60, 
                                                height: 60,
                                                child: Image.asset(
                                                    _activeTrees.isEmpty ? 'assets/tree/tree1.PNG' : (allShopItems.firstWhere((item) => item.id == _activeTrees[tree.assetIndex % _activeTrees.length], orElse: () => allShopItems.firstWhere((i) => i.id == 'tree1')).imagePath ?? 'assets/tree/tree1.PNG'),
                                                    fit: BoxFit.contain,
                                                    color: Colors.black.withValues(alpha: 0.6 + ((tree.scale - 0.8) * 0.8)), 
                                                    colorBlendMode: BlendMode.srcATop,
                                                ),
                                            ),
                                        ),
                                    ),
                              )),
                          // 4. The Main Mountain Slope (Overlaps trees)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: ModernMountainPainter(),
                            ),
                          ),
                          // Row 1: mixed bushes and rocks
                          ..._bushes.map((bush) {
                            final isBush = bush.assetIndex == 0;
                            final items = isBush
                                ? _activeCalilar.where((id) => id.startsWith('bush')).toList()
                                : _activeCalilar.where((id) => id.startsWith('rock')).toList();
                            final fallback = isBush ? 'assets/bush/bush.png' : 'assets/bush/rock.png';
                            final assetId = items.isNotEmpty ? items[0] : (isBush ? 'bush0' : 'rock0');
                            final assetPath = allShopItems.firstWhere((item) => item.id == assetId, orElse: () => allShopItems.first).imagePath ?? fallback;
                            return Positioned(
                                left: bush.x,
                                bottom: (bush.x * 0.375) + 20,
                                child: Transform.rotate(
                                    angle: -0.358,
                                    child: Transform.scale(
                                        scale: bush.scale,
                                        alignment: Alignment.bottomCenter,
                                        child: SizedBox(
                                            width: isBush ? 58 : (35 + bush.scale * 26).clamp(35.0, 55.0),
                                            height: isBush ? 58 : (35 + bush.scale * 26).clamp(35.0, 55.0),
                                            child: Image.asset(assetPath, fit: BoxFit.contain,
                                                color: Colors.black.withValues(alpha: isBush ? 0.65 : 0.55),
                                                colorBlendMode: BlendMode.srcATop),
                                        ),
                                    ),
                                ),
                            );
                          }),
                          // Row 2: mixed bushes and rocks
                          ..._bushes2.map((bush) {
                            final isBush = bush.assetIndex == 0;
                            final items = isBush
                                ? _activeCalilar.where((id) => id.startsWith('bush')).toList()
                                : _activeCalilar.where((id) => id.startsWith('rock')).toList();
                            final fallback = isBush ? 'assets/bush/bush.png' : 'assets/bush/rock.png';
                            final assetId = items.isNotEmpty ? items[0] : (isBush ? 'bush0' : 'rock0');
                            final assetPath = allShopItems.firstWhere((item) => item.id == assetId, orElse: () => allShopItems.first).imagePath ?? fallback;
                            return Positioned(
                                left: bush.x,
                                bottom: (bush.x * 0.375) - 15,
                                child: Transform.rotate(
                                    angle: -0.358,
                                    child: Transform.scale(
                                        scale: bush.scale,
                                        alignment: Alignment.bottomCenter,
                                        child: SizedBox(
                                            width: isBush ? 58 : (35 + bush.scale * 26).clamp(35.0, 55.0),
                                            height: isBush ? 58 : (35 + bush.scale * 26).clamp(35.0, 55.0),
                                            child: Image.asset(assetPath, fit: BoxFit.contain,
                                                color: Colors.black.withValues(alpha: isBush ? 0.65 : 0.55),
                                                colorBlendMode: BlendMode.srcATop),
                                        ),
                                    ),
                                ),
                            );
                          }),
                          // Row 3: lowest row, mixed bushes and rocks
                          ..._bushes3.map((bush) {
                            final isBush = bush.assetIndex == 0;
                            final items = isBush
                                ? _activeCalilar.where((id) => id.startsWith('bush')).toList()
                                : _activeCalilar.where((id) => id.startsWith('rock')).toList();
                            final fallback = isBush ? 'assets/bush/bush.png' : 'assets/bush/rock.png';
                            final assetId = items.isNotEmpty ? items[0] : (isBush ? 'bush0' : 'rock0');
                            final assetPath = allShopItems.firstWhere((item) => item.id == assetId, orElse: () => allShopItems.first).imagePath ?? fallback;
                            return Positioned(
                                left: bush.x,
                                bottom: (bush.x * 0.375) - 45, // Lowest row
                                child: Transform.rotate(
                                    angle: -0.358,
                                    child: Transform.scale(
                                        scale: bush.scale,
                                        alignment: Alignment.bottomCenter,
                                        child: SizedBox(
                                            width: isBush ? 52 : (28 + bush.scale * 26).clamp(28.0, 48.0),
                                            height: isBush ? 52 : (28 + bush.scale * 26).clamp(28.0, 48.0),
                                            child: Image.asset(assetPath, fit: BoxFit.contain,
                                                color: Colors.black.withValues(alpha: isBush ? 0.60 : 0.50),
                                                colorBlendMode: BlendMode.srcATop),
                                        ),
                                    ),
                                ),
                            );
                          }),
                          // 5. Weather Animation (Now BETWEEN Mountains/Trees and the Car)
                          Positioned.fill(
                            // We use an IgnorePointer here so the invisible weather canvas doesn't block touch events 
                            // (though there are none in the circle, it's good practice for overlay layers)
                            child: IgnorePointer(
                              child: ClipPath(
                                clipper: MountainClipClipper(),
                                child: WrapperScene(
                                  // Remove backgrounds from WrapperScene so it's transparent, we use the Container base
                                  colors: const [Colors.transparent, Colors.transparent], 
                                  children: [
                                    if (_currentWeather == 'snow') ...[
                                      const SnowWidget(
                                         snowConfig: SnowConfig(
                                             count: 40, 
                                             size: 20,
                                             color: Colors.white,
                                             areaXStart: -300, 
                                             areaXEnd: 300,    
                                             areaYStart: -250, 
                                             areaYEnd: 450,
                                             waveRangeMin: 20,
                                             waveRangeMax: 50,
                                         ),
                                      ),
                                      const SnowWidget(
                                         snowConfig: SnowConfig(
                                             count: 40, 
                                             size: 20,
                                             color: Colors.white,
                                             areaXStart: 200, 
                                             areaXEnd: 800,    
                                             areaYStart: -250, 
                                             areaYEnd: 450,
                                             waveRangeMin: 20,
                                             waveRangeMax: 50,
                                         ),
                                      ),
                                    ],
                                    if (_currentWeather == 'rain') ...[
                                      const RainWidget(
                                         rainConfig: RainConfig(
                                             count: 40, // Base layer for left/center
                                             lengthDrop: 14.0,
                                             widthDrop: 3.0,
                                             color: Colors.white54,
                                             areaXStart: -200, 
                                             areaXEnd: 200,   
                                             areaYStart: -250, 
                                             areaYEnd: 350,
                                             slideX: 80.0, 
                                             slideY: 100.0, 
                                             fallRangeMinDurMill: 1000, 
                                             fallRangeMaxDurMill: 2500,
                                             slideDurMill: 2500,
                                         ),
                                      ),
                                      const RainWidget(
                                         rainConfig: RainConfig(
                                             count: 40, // Explicit layer targeting the right-side gap
                                             lengthDrop: 14.0,
                                             widthDrop: 3.0,
                                             color: Colors.white54,
                                             areaXStart: 100, // Starts mid-screen and pushes outward
                                             areaXEnd: 500,   // Ends far off-screen right
                                             areaYStart: -250, 
                                             areaYEnd: 350,
                                             slideX: 80.0, 
                                             slideY: 100.0, 
                                             fallRangeMinDurMill: 1000, 
                                             fallRangeMaxDurMill: 2500,
                                             slideDurMill: 2500,
                                         ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // 6. The Car (Asset Image - Top Layer)
                          Positioned(
                            left: 100,
                            // Reduced bounce amplitude: changed multiplier from 1.5 to 0.4
                            bottom: 110 + (sin(_animationController.value * pi * 8) * 0.4), 
                            child: Transform.rotate(
                              // Perfectly matching the mountain slope: atan(0.375) ~ 0.358 radians
                              angle: -0.358, 
                              child: Transform.translate(
                                  // Arabanın tekerleklerinin dağa tam basması için ofset (10 birim aşağı)
                                  offset: const Offset(0, 10), 
                                  child: SizedBox(
                                      width: 100, // Boyut artırıldı
                                      height: 100, // Boyut artırıldı
                                      child: Transform.scale(
                                          scale: _equippedCarScale,
                                          child: Image.asset(
                                              _equippedCarPath, 
                                              fit: BoxFit.contain,
                                      // Fallback builder in case asset is missing
                                      errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                              Icons.directions_car_filled_rounded,
                                              size: 55,
                                              color: Color(0xFFD32F2F),
                                          );
                                      },
                                          ),
                                      ),
                                  ),
                              ),
                          ),
                        ),
                      ],
                    );
                    },
                  ),
                ),
              ),


              // Weather Icon (Bottom Left Arc) - Soft background for visibility
              Positioned(
                bottom: 2,
                left: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _currentWeather == 'snow' ? Icons.ac_unit : _currentWeather == 'rain' ? Icons.water_drop : Icons.wb_sunny_outlined,
                    ),
                    iconSize: 40,
                    color: Theme.of(context).primaryColor,
                    onPressed: _showWeatherSelectionDialog,
                    padding: const EdgeInsets.all(8.0),
                    constraints: const BoxConstraints(),
                    splashRadius: 30,
                  ),
                ),
              ),
              
              // Music Icon (Bottom Right Arc) - Soft background for visibility
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isPlayingMusic ? Icons.music_note_rounded : Icons.music_off_outlined,
                    ),
                    iconSize: 40,
                    color: Theme.of(context).primaryColor,
                    onPressed: _showMusicSelectionDialog,
                    padding: const EdgeInsets.all(8.0),
                    constraints: const BoxConstraints(),
                    splashRadius: 30,
                  ),
                ),
              ),

              ],
            ),
          ),
          
            const SizedBox(height: 10), // Adjusted spacing

            // --- Timer Display ---
            GestureDetector(
              onTap: _isRunning ? null : _showCupertinoTimePicker,
              child: ValueListenableBuilder<int>(
                valueListenable: _secondsRemainingNotifier,
                builder: (context, secondsRemaining, child) {
                  return Text(
                    _formatTime(secondsRemaining),
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w300, 
                      color: Color(0xFF37474F),     
                      letterSpacing: -2,
                    ),
                  );
                },
              ),
            ),
            
            // Removed Linear Progress Bar (Now it's on the circle above)
            
            const SizedBox(height: 20), // Replaced Flexible Spacer

            // --- Controls ---
            const SizedBox(height: 30), 
            
            // --- Center Action Area (Dynamic States - Unified Pill) ---
            Container(
              decoration: BoxDecoration(
                color: hasThemeBackground ? Colors.white.withValues(alpha: 0.6) : Theme.of(context).primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(50), // Stadium shape
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Builder(
                builder: (context) {
                  const double unifiedIconSize = 44.0; // Fixed equal size for all icons
                  const EdgeInsets unifiedPadding = EdgeInsets.all(12.0); // Fixed touch area
                  
                  if (!_isRunning && _secondsRemaining == _totalSeconds) {
                    // 1. Initial State (Hasn't Started)
                    return IconButton(
                      style: IconButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: unifiedPadding,
                        backgroundColor: Colors.transparent, // Transparent inner
                        elevation: 0,
                      ),
                      onPressed: _startTimer,
                      icon: const Icon(Icons.play_arrow_rounded),
                      iconSize: unifiedIconSize,
                    );
                  } else if (_isRunning) {
                    // 2. Running State
                    return IconButton(
                      style: IconButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: unifiedPadding,
                        backgroundColor: Colors.transparent, // Transparent inner
                        elevation: 0,
                      ),
                      onPressed: _stopTimer,
                      icon: const Icon(Icons.pause_rounded),
                      iconSize: unifiedIconSize,
                    );
                  } else {
                    // 3. Paused State (Row of 3 minimal icons)
                    return Row(
                      mainAxisSize: MainAxisSize.min, // Keep container tight around icons
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Left: Sıfırla (Reset)
                        IconButton(
                          style: IconButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: unifiedPadding,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                          onPressed: _showResetConfirmationDialog,
                          icon: const Icon(Icons.replay_rounded),
                          iconSize: unifiedIconSize,
                        ),
                        const SizedBox(width: 8), // Equal healthy spacing
                        // Center: Devam Et (Play)
                        IconButton(
                          style: IconButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: unifiedPadding,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                          onPressed: _startTimer,
                          icon: const Icon(Icons.play_arrow_rounded),
                          iconSize: unifiedIconSize,
                        ),
                        const SizedBox(width: 8), // Equal healthy spacing
                        // Right: Bitir/Kapat (End Section)
                        IconButton(
                          style: IconButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: unifiedPadding,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                          onPressed: _showEndSessionConfirmationDialog,
                          icon: const Icon(Icons.stop_rounded),
                          iconSize: unifiedIconSize,
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            
            const SizedBox(height: 30), // Bottom padding
          ],
        ),
        ),
      ),
    );

    if (themeBackgroundPath != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              themeBackgroundPath,
              fit: BoxFit.cover,
            ),
          ),
          timerContent,
        ],
      );
    }

    return timerContent;
  }

  Widget _buildShopView() {
    return ShopView(
      currentKm: _totalKm,
      onPurchase: (cost) {
        setState(() {
          _totalKm -= cost;
        });
        _saveStatistics();
      },
      onEquipAction: () async {
        final prefs = await SharedPreferences.getInstance();
        String equippedCarId = prefs.getString('equipped_garaj') ?? 'car1';
        List<String> eqTrees = prefs.getStringList('equipped_trees') ?? ['tree1', 'tree2', 'tree3'];
        setState(() {
          final equippedCar = allShopItems.firstWhere(
            (item) => item.id == equippedCarId, 
            orElse: () => allShopItems[0]
          );
          _equippedCarPath = equippedCar.imagePath ?? 'assets/car/car1.png';
          _equippedCarScale = equippedCar.imageScale;
          _activeTrees = eqTrees;
        });
      },
      onThemeEquipAction: (String themeName) {
        themeSettings.updateTheme(themeName);
      },
    );
  }

  Widget _buildStandardBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.1) ?? Colors.black12, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTapped,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5) ?? Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        iconSize: 28,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer),
            label: 'Zamanlayıcı',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'İstatistikler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDerinUzayTheme = themeSettings.activeColorTheme == 'Derin Uzay';

    return Scaffold(
      extendBody: isDerinUzayTheme,
      backgroundColor: isDerinUzayTheme
          ? const Color(0xFF0A1628)
          : Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          _buildTimerView(),
          _buildShopView(),
          _buildStatsView(),
          _buildSettingsView(),
        ],
      ),
      bottomNavigationBar: isDerinUzayTheme
          ? MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: SpaceBottomNavBar(
                currentIndex: _bottomNavIndex,
                onTap: _onBottomNavTapped,
              ),
            )
          : _buildStandardBottomNav(),
    );
  }
}

class SettingsView extends StatefulWidget {
  final VoidCallback? onNavigateToMarket;
  const SettingsView({super.key, this.onNavigateToMarket});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _showCustomizeTimer = false;
  bool _showAbout = false;
  bool _showSound = false;
  bool _showLanguage = false;
  bool _showTheme = false;

  Widget _buildSettingsItem({
    required Widget icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color backgroundColor = const Color(0xFFEEEEEE),
    Color textColor = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showCustomizeTimer) {
      return CustomizeTimerView(
        onBack: () => setState(() => _showCustomizeTimer = false),
      );
    }
    
    if (_showAbout) {
      return AboutView(
        onBack: () => setState(() => _showAbout = false),
      );
    }

    if (_showSound) {
      return SoundView(
        onBack: () => setState(() => _showSound = false),
        onNavigateToMarket: widget.onNavigateToMarket,
      );
    }

    if (_showLanguage) {
      return LanguageView(
        onBack: () => setState(() => _showLanguage = false),
      );
    }

    if (_showTheme) {
      return ThemeView(
        onBack: () => setState(() => _showTheme = false),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 20),
              child: Text(
                'Ayarlar',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            _buildSettingsItem(
              icon: const Text('🎯', style: TextStyle(fontSize: 24)),
              title: 'Zamanlayıcıyı Özelleştir',
              trailing: const Icon(Icons.chevron_right, color: Colors.black54),
              onTap: () => setState(() => _showCustomizeTimer = true),
            ),
            _buildSettingsItem(
              icon: const Text('🎨', style: TextStyle(fontSize: 24)),
              title: 'Uygulama Teması',
              trailing: const Icon(Icons.chevron_right, color: Colors.black54),
              onTap: () => setState(() => _showTheme = true),
            ),
            _buildSettingsItem(
              icon: const Text('🌍', style: TextStyle(fontSize: 24)),
              title: 'Dil',
              trailing: const Icon(Icons.chevron_right, color: Colors.black54),
              onTap: () => setState(() => _showLanguage = true),
            ),
            _buildSettingsItem(
              icon: const Text('🔔', style: TextStyle(fontSize: 24)),
              title: 'Ses',
              trailing: const Icon(Icons.chevron_right, color: Colors.black54),
              onTap: () => setState(() => _showSound = true),
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              icon: const Text('ℹ️', style: TextStyle(fontSize: 24)),
              title: 'Hakkında',
              trailing: const Icon(Icons.chevron_right, color: Colors.black54),
              onTap: () => setState(() => _showAbout = true),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class SoundView extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onNavigateToMarket;

  const SoundView({super.key, required this.onBack, this.onNavigateToMarket});

  @override
  State<SoundView> createState() => _SoundViewState();
}

class _SoundViewState extends State<SoundView> {
  bool _silentMode = false;
  String _alarmSound = 'Announce';
  String _bgMusicPath = 'Sessiz';
  String _breakMusicPath = 'Sessiz';
  List<String> _unlockedSounds = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _previewPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _previewPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _alarmSound = prefs.getString('alarmSound') ?? 'assets/sounds/alarms/dragon-studio-cute-chime-439613.mp3';
        _silentMode = prefs.getBool('silentMode') ?? false;
        _bgMusicPath = prefs.getString('bgMusicPath') ?? 'Sessiz';
        _breakMusicPath = prefs.getString('breakMusicPath') ?? 'Sessiz';
        _unlockedSounds = prefs.getStringList('purchased_items') ?? [];
      });
    }
  }

  void _showAlarmSelectionDialog() {
    final Map<String, String> sounds = alarmMusicOptions;

    String tempSelectedPath = _alarmSound;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              backgroundColor: const Color(0xFFF3F4F6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Text(
                       'Alarm Sesi Seç',
                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                     ),
                     const SizedBox(height: 16),
                     Flexible(
                       child: SingleChildScrollView(
                         child: Column(
                           children: sounds.entries.map((entry) {
                             bool isFree = entry.value == 'Sessiz' || entry.value == 'assets/sounds/alarms/dragon-studio-cute-chime-439613.mp3';
                             bool isLocked = !isFree && !_unlockedSounds.contains(entry.value);

                             return Column(
                               children: [
                                 ListTile(
                                   leading: entry.value != 'Sessiz' ? IconButton(
                                     icon: Icon(isLocked ? Icons.lock : Icons.play_circle_fill, color: isLocked ? Colors.grey : Theme.of(context).primaryColor, size: 32),
                                     onPressed: () async {
                                       if (isLocked) return;
                                       try {
                                         await _previewPlayer.stop();
                                         String assetPath = entry.value.replaceAll('assets/', '');
                                         await _previewPlayer.play(kIsWeb ? UrlSource(entry.value) : AssetSource(assetPath));
                                       } catch (e) {
                                         debugPrint("Could not play alarm preview: $e");
                                       }
                                     },
                                   ) : const SizedBox(width: 48, child: Icon(Icons.volume_off, color: Colors.grey)),
                                   title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.w500, color: isLocked ? Colors.grey : Colors.black87)),
                                   trailing: tempSelectedPath == entry.value 
                                       ? Icon(Icons.radio_button_checked, color: Theme.of(context).primaryColor) 
                                       : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                   onTap: () {
                                     if (isLocked) {
                                       _showLockedItemDialog(entry.key);
                                     } else {
                                       setDialogState(() {
                                         tempSelectedPath = entry.value;
                                       });
                                     }
                                   },
                                   onLongPress: () {
                                     if (isLocked) {
                                       _showLockedItemDialog(entry.key);
                                     } else {
                                       setDialogState(() {
                                         tempSelectedPath = entry.value;
                                       });
                                     }
                                   },
                                 ),
                                 const Divider(),
                               ],
                             );
                           }).toList(),
                         ),
                       ),
                     ),
                     const SizedBox(height: 16),
                     SizedBox(
                       width: double.infinity,
                       height: 50,
                       child: ElevatedButton(
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Theme.of(context).primaryColor,
                           foregroundColor: Colors.white,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(15),
                           ),
                           elevation: 0,
                         ),
                         onPressed: () async {
                           await _previewPlayer.stop();
                           final prefs = await SharedPreferences.getInstance();
                           await prefs.setString('alarmSound', tempSelectedPath);
                           if (mounted) {
                             setState(() {
                               _alarmSound = tempSelectedPath;
                             });
                             Navigator.pop(context);
                           }
                         },
                         child: const Text('Kaydet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       ),
                     ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      _previewPlayer.stop();
    });
  }

  void _showBgMusicSelectionDialog() {
    final Map<String, String> options = backgroundMusicOptions;

    String tempSelectedPath = _bgMusicPath;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
              backgroundColor: const Color(0xFFF3F4F6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Arka Plan Müziği',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: options.entries.map((entry) {
                            bool isFree = entry.value == 'Sessiz' || entry.value == 'assets/sounds/back/creatorarts-relaxing-heavy-rain-sounds-on-roof-perfect-for-sleep-focus-323383.mp3';
                            bool isLocked = !isFree && !_unlockedSounds.contains(entry.value);

                            return Column(
                               children: [
                                 ListTile(
                                   leading: entry.value != 'Sessiz' ? IconButton(
                                     icon: Icon(isLocked ? Icons.lock : Icons.play_circle_fill, color: isLocked ? Colors.grey : Theme.of(context).primaryColor, size: 32),
                                     onPressed: () async {
                                       if (isLocked) return;
                                       try {
                                         await _previewPlayer.stop();
                                         String assetPath = entry.value.replaceAll('assets/', '');
                                         await _previewPlayer.play(kIsWeb ? UrlSource(entry.value) : AssetSource(assetPath));
                                       } catch (e) {
                                         debugPrint("Could not play bg preview: $e");
                                       }
                                     },
                                   ) : const SizedBox(width: 48, child: Icon(Icons.volume_off, color: Colors.grey)),
                                   title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.w500, color: isLocked ? Colors.grey : Colors.black87)),
                                   trailing: tempSelectedPath == entry.value 
                                       ? Icon(Icons.radio_button_checked, color: Theme.of(context).primaryColor) 
                                       : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                   onTap: () {
                                     if (isLocked) {
                                       _showLockedItemDialog(entry.key);
                                     } else {
                                       setDialogState(() {
                                         tempSelectedPath = entry.value;
                                       });
                                     }
                                   },
                                   onLongPress: () {
                                     if (isLocked) {
                                       _showLockedItemDialog(entry.key);
                                     } else {
                                       setDialogState(() {
                                         tempSelectedPath = entry.value;
                                       });
                                     }
                                   },
                                 ),
                                 const Divider(),
                               ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          await _previewPlayer.stop();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('bgMusicPath', tempSelectedPath);
                          if (mounted) {
                            setState(() {
                              _bgMusicPath = tempSelectedPath;
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Kaydet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      _previewPlayer.stop();
    });
  }

  void _showBreakMusicSelectionDialog() {
    final Map<String, String> options = backgroundMusicOptions;

    String tempSelectedPath = _breakMusicPath;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
              backgroundColor: const Color(0xFFF3F4F6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mola Sesi',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: options.entries.map((entry) {
                            bool isFree = entry.value == 'Sessiz' || entry.value == 'assets/sounds/back/creatorarts-relaxing-heavy-rain-sounds-on-roof-perfect-for-sleep-focus-323383.mp3';
                            bool isLocked = !isFree && !_unlockedSounds.contains(entry.value);

                            return Column(
                               children: [
                                 ListTile(
                                   leading: entry.value != 'Sessiz' ? IconButton(
                                     icon: Icon(isLocked ? Icons.lock : Icons.play_circle_fill, color: isLocked ? Colors.grey : Theme.of(context).primaryColor, size: 32),
                                     onPressed: () async {
                                       if (isLocked) return;
                                       try {
                                         await _previewPlayer.stop();
                                         String assetPath = entry.value.replaceAll('assets/', '');
                                         await _previewPlayer.play(kIsWeb ? UrlSource(entry.value) : AssetSource(assetPath));
                                       } catch (e) {
                                         debugPrint("Could not play break preview: $e");
                                       }
                                     },
                                   ) : const SizedBox(width: 48, child: Icon(Icons.volume_off, color: Colors.grey)),
                                   title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.w500, color: isLocked ? Colors.grey : Colors.black87)),
                                   trailing: tempSelectedPath == entry.value 
                                       ? Icon(Icons.radio_button_checked, color: Theme.of(context).primaryColor) 
                                       : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                   onTap: () {
                                     if (isLocked) {
                                       _showLockedItemDialog(entry.key);
                                     } else {
                                       setDialogState(() {
                                         tempSelectedPath = entry.value;
                                       });
                                     }
                                   },
                                   onLongPress: () {
                                     if (isLocked) {
                                       _showLockedItemDialog(entry.key);
                                     } else {
                                       setDialogState(() {
                                         tempSelectedPath = entry.value;
                                       });
                                     }
                                   },
                                 ),
                                 const Divider(),
                               ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          await _previewPlayer.stop();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('breakMusicPath', tempSelectedPath);
                          if (mounted) {
                            setState(() {
                              _breakMusicPath = tempSelectedPath;
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Kaydet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      _previewPlayer.stop();
    });
  }

  void _showLockedItemDialog(String itemName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Kilitli Ses',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Lütfen bu sesi (\'$itemName\') kullanabilmek için Mağaza (Market) bölümünden satın alın.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey.shade800),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close settings/sound views back to main screen
                widget.onNavigateToMarket?.call();
              },
              child: const Text('Mağazaya Git', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

  Widget _buildGroupedSettingsItem({
    required Widget icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color textColor = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              trailing ?? const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
       child: Column(
         children: [
           Padding(
            padding: const EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                  onPressed: widget.onBack,
                ),
                const Expanded(
                  child: Text(
                    'Ses',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance for centering
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                   _buildGroupedSettingsItem(
                    icon: const Icon(Icons.volume_off_outlined, color: Colors.black87),
                    title: 'Sessiz Mod',
                    trailing: Switch(
                      value: _silentMode,
                      onChanged: (val) async {
                        setState(() => _silentMode = val);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('silentMode', val);
                      },
                      activeTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                      activeThumbColor: Theme.of(context).primaryColor,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                    onTap: () async {
                      bool newVal = !_silentMode;
                      setState(() => _silentMode = newVal);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('silentMode', newVal);
                    },
                  ),
                  _buildGroupedSettingsItem(
                    icon: const Icon(Icons.music_note_rounded, color: Colors.black87),
                    title: 'Arka Plan Müziği',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getMusicNameFromPath(_bgMusicPath),
                          style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                      ],
                    ),
                    onTap: () => _showBgMusicSelectionDialog(),
                  ),
                  _buildGroupedSettingsItem(
                    icon: const Icon(Icons.coffee_outlined, color: Colors.black87),
                    title: 'Mola Sesi',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getMusicNameFromPath(_breakMusicPath),
                          style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                      ],
                    ),
                    onTap: () => _showBreakMusicSelectionDialog(),
                  ),
                  _buildGroupedSettingsItem(
                    icon: const Icon(Icons.workspace_premium, color: Colors.black87), // Matching SoundView style
                    title: 'Alarm Sesi',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getAlarmNameFromPath(_alarmSound),
                          style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                      ],
                    ),
                    onTap: () {
                      _showAlarmSelectionDialog();
                    },
                  ),
                  _buildGroupedSettingsItem(
                    icon: const Icon(Icons.notifications_none, color: Colors.black87),
                    title: 'Bildirim Ayarları',
                    onTap: () async {
                      try {
                        await AppSettings.openAppSettings(type: AppSettingsType.notification);
                      } catch (e) {
                        debugPrint("Could not open notification settings: $e");
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
         ],
       ),
    );
  }
}

class AboutView extends StatelessWidget {
  final VoidCallback onBack;

  const AboutView({super.key, required this.onBack});

  Widget _buildGroupedSettingsItem({
    required Widget icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color textColor = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
       child: Column(
         children: [
           Padding(
            padding: const EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                  onPressed: onBack,
                ),
                const Expanded(
                  child: Text(
                    'Hakkında',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance for centering
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildGroupedSettingsItem(
                    icon: const Icon(Icons.star_border, color: Colors.black87),
                    title: 'Bir Yorum Yaz',
                    onTap: () {
                      debugPrint("Bir Yorum Yaz tıklandı");
                    },
                  ),
                  _buildGroupedSettingsItem(
                    icon: const Icon(Icons.email_outlined, color: Colors.black87),
                    title: 'İletişim Bilgileri',
                    subtitle: 'emrecicek630@gmail.com',
                    onTap: () async {
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: 'emrecicek630@gmail.com',
                      );
                      try {
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        } else {
                          // Ignore warning, context is mounted inside a stateless widget method scope
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mail uygulaması bulunamadı. Adres: emrecicek630@gmail.com'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        debugPrint("Could not launch mail client: $e");
                        if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mail uygulaması bulunamadı. Adres: emrecicek630@gmail.com'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                         }
                      }
                    },
                  ),
                  _buildGroupedSettingsItem(
                    icon: const Icon(Icons.translate, color: Colors.black87),
                    title: 'Çeviri Hatası Bildir',
                    onTap: () {},
                  ),
                  _buildGroupedSettingsItem(
                    icon: const Icon(Icons.privacy_tip_outlined, color: Colors.black87),
                    title: 'Gizlilik Politikası',
                    onTap: () {},
                  ),
                  _buildGroupedSettingsItem(
                    icon: const Icon(Icons.gavel, color: Colors.black87),
                    title: 'Şartlar ve Koşullar',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
         ],
       ),
    );
  }
}

class LanguageView extends StatefulWidget {
  final VoidCallback onBack;

  const LanguageView({super.key, required this.onBack});

  @override
  State<LanguageView> createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView> {
  String _selectedLanguage = 'Turkish'; // Template default

  Widget _buildLanguageItem({
    required Widget icon,
    required String title,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 1.5) : null,
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.radio_button_checked, color: Theme.of(context).primaryColor)
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
       child: Column(
         children: [
           Padding(
            padding: const EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                  onPressed: widget.onBack,
                ),
                const Expanded(
                  child: Text(
                    'Dil',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance for centering
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildLanguageItem(
                    icon: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                    title: 'English US',
                    isSelected: _selectedLanguage == 'English US',
                    onTap: () => setState(() => _selectedLanguage = 'English US'),
                  ),
                  _buildLanguageItem(
                    icon: const Text('🇩🇪', style: TextStyle(fontSize: 24)),
                    title: 'German',
                    isSelected: _selectedLanguage == 'German',
                    onTap: () => setState(() => _selectedLanguage = 'German'),
                  ),
                  _buildLanguageItem(
                    icon: const Text('🇹🇷', style: TextStyle(fontSize: 24)),
                    title: 'Turkish',
                    isSelected: _selectedLanguage == 'Turkish',
                    onTap: () => setState(() => _selectedLanguage = 'Turkish'),
                  ),
                  // Diğer diller buraya eklenecek
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: widget.onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text('KAYDET', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
          ),
         ],
       ),
    );
  }
}

class ThemeView extends StatefulWidget {
  final VoidCallback onBack;

  const ThemeView({super.key, required this.onBack});

  @override
  State<ThemeView> createState() => _ThemeViewState();
}

class _ThemeViewState extends State<ThemeView> {
  List<String> _unlockedThemes = ['Varsayılan'];

  @override
  void initState() {
    super.initState();
    _loadUnlockedThemes();
  }

  Future<void> _loadUnlockedThemes() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _unlockedThemes = [
          'Varsayılan',
          ...(prefs.getStringList('purchased_items') ?? [])
        ];
      });
    }
  }

  Widget _buildThemeCard({
    required String title,
    required Color bgColor,
    required Color appColor,
    required Color textColor,
    required Color cardColor,
  }) {
    bool isSelected = themeSettings.activeColorTheme == title;
    bool isLocked = !_unlockedThemes.contains(title);
    if (title == 'Varsayılan') isLocked = false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          if (isLocked) {
             showDialog(
               context: context,
               builder: (BuildContext context) {
                 return AlertDialog(
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                   title: Text(
                     'Kilitli Tema',
                     style: TextStyle(
                       fontWeight: FontWeight.bold,
                       color: Theme.of(context).primaryColor,
                     ),
                     textAlign: TextAlign.center,
                   ),
                   content: const Text(
                     'Lütfen bu temayı kullanabilmek için Mağaza (Market) bölümünden satın alın.',
                     textAlign: TextAlign.center,
                     style: TextStyle(fontSize: 16),
                   ),
                   actionsAlignment: MainAxisAlignment.center,
                   actions: [
                     ElevatedButton(
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Theme.of(context).primaryColor,
                         foregroundColor: Colors.white,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                       ),
                       onPressed: () => Navigator.of(context).pop(),
                       child: const Text('Tamam', style: TextStyle(fontWeight: FontWeight.bold)),
                     ),
                   ],
                 );
               }
             );
          } else {
             themeSettings.updateTheme(title);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 1.5) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Theme.of(context).primaryColor : const Color(0xFF424242),
                        ),
                      ),
                      if (isLocked) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.lock, size: 20, color: Colors.grey),
                      ],
                    ],
                  ),
                  if (isSelected)
                    Container(
                      width: 48,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: CircleAvatar(backgroundColor: Colors.white, radius: 12),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 48,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                           padding: EdgeInsets.all(2.0),
                           child: CircleAvatar(backgroundColor: Colors.white, radius: 12),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildColorCircle(bgColor, 'Arka Plan'),
                  _buildColorCircle(appColor, 'Uygulama'),
                  _buildColorCircle(textColor, 'Yazı'),
                  _buildColorCircle(cardColor, 'Kart'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.black12, width: 1),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
       child: Column(
         children: [
           Padding(
            padding: const EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                  onPressed: widget.onBack,
                ),
                const Expanded(
                  child: Text(
                    'Uygulama Teması',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance for centering
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         const Row(
                            children: [
                               Icon(Icons.dark_mode_outlined, color: Colors.black87),
                               SizedBox(width: 12),
                               Text('Koyu Mod', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                         ),
                         Switch(
                            value: themeSettings.isDarkMode,
                            onChanged: (val) {
                               themeSettings.updateDarkMode(val);
                            },
                            activeTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                            activeThumbColor: Theme.of(context).primaryColor,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey[400]!,
                         ),
                       ],
                    ),
                  ),

                  // Varsayılan Theme
                  _buildThemeCard(
                    title: 'Varsayılan',
                    bgColor: themeSettings.isDarkMode ? Colors.black87 : const Color(0xFFE0E0E0),
                    appColor: const Color(0xFF4CAF50),
                    textColor: themeSettings.isDarkMode ? Colors.white70 : Colors.black54,
                    cardColor: themeSettings.isDarkMode ? Colors.black38 : const Color(0xFFE0E0E0),
                  ),

                  // Japon Theme
                  _buildThemeCard(
                    title: 'Japon',
                    bgColor: const Color(0xFFFCE4EC),
                    appColor: const Color(0xFFE91E63),
                    textColor: Colors.black87,
                    cardColor: const Color(0xFFF8BBD0),
                  ),

                  // Mısır Theme
                  _buildThemeCard(
                    title: 'Mısır',
                    bgColor: const Color(0xFFFFF8E1),
                    appColor: const Color(0xFFFFC107),
                    textColor: Colors.black87,
                    cardColor: const Color(0xFFFFECB3),
                  ),

                  // İskandinavya Theme
                  _buildThemeCard(
                    title: 'İskandinavya',
                    bgColor: const Color(0xFFE0F7FA),
                    appColor: const Color(0xFF00ACC1),
                    textColor: Colors.black87,
                    cardColor: const Color(0xFFB2EBF2),
                  ),

                  // Derin Uzay Theme
                  _buildThemeCard(
                    title: 'Derin Uzay',
                    bgColor: const Color(0xFF0A1628),
                    appColor: const Color(0xFF00E5FF),
                    textColor: Colors.white70,
                    cardColor: const Color(0xFF1A2744),
                  ),

                  // Yeşil Theme
                  _buildThemeCard(
                    title: 'Yeşil',
                    bgColor: const Color(0xFF388E3C),
                    appColor: const Color(0xFF4CAF50),
                    textColor: Colors.white70,
                    cardColor: const Color(0xFF1B5E20),
                  ),

                  // Turuncu Theme
                  _buildThemeCard(
                    title: 'Turuncu',
                    bgColor: const Color(0xFFF57C00),
                    appColor: const Color(0xFFFF9800),
                    textColor: Colors.white70,
                    cardColor: const Color(0xFFE65100),
                  ),

                ],
              ),
            ),
          ),
         ],
       ),
    );
  }
}

class CustomizeTimerView extends StatefulWidget {
  final VoidCallback onBack;
  const CustomizeTimerView({super.key, required this.onBack});

  @override
  State<CustomizeTimerView> createState() => _CustomizeTimerViewState();
}

class _CustomizeTimerViewState extends State<CustomizeTimerView> {
  // We no longer need separate local variables for timer settings as they will be managed by TimerSettingsController
  bool _wakeLockEnabled = false;
  bool _deepFocusEnabled = false;
  String _totalIntervals = timerSettings.totalIntervals.toString();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    // Add listener to the global timer settings to re-build if needed
    timerSettings.addListener(_onTimerSettingsChanged);
  }

  void _onTimerSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    timerSettings.removeListener(_onTimerSettingsChanged);
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _wakeLockEnabled = prefs.getBool('wakeLockEnabled') ?? false;
        _deepFocusEnabled = prefs.getBool('deepFocusEnabled') ?? false;
        // The other settings are loaded/managed via TimerSettingsController now
      });
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is String) {
      prefs.setString(key, value);
    }
  }

  Widget _buildConfigItem({
    required String title,
    required Widget trailing,
    Color backgroundColor = const Color(0xFFEEEEEE),
    Color textColor = Colors.black87,
    Widget? leading,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, String suffix, ValueChanged<String?> onChanged) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(suffix.isEmpty ? item : '$item $suffix'),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                  onPressed: widget.onBack,
                ),
                const Expanded(
                  child: Text(
                    'Zamanlayıcıyı Özelleştir',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance for centering
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildConfigItem(
                    title: 'Derin Odak Modu (Arka planda sayacı bozar)',
                    trailing: Switch(
                      value: _deepFocusEnabled,
                      onChanged: (val) {
                        setState(() => _deepFocusEnabled = val);
                        _saveSetting('deepFocusEnabled', val);
                      },
                      activeTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                      activeThumbColor: Theme.of(context).primaryColor,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                  ),
                  _buildConfigItem(
                    title: 'Ekran Uyanık Kalsın',
                    trailing: Switch(
                      value: _wakeLockEnabled,
                      onChanged: (val) {
                        setState(() => _wakeLockEnabled = val);
                        _saveSetting('wakeLockEnabled', val);
                      },
                      activeTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                      activeThumbColor: Theme.of(context).primaryColor,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                  ),
                  _buildConfigItem(
                    title: 'Mola Otomatik Başlatılsın mı?',
                    trailing: Switch(
                      value: timerSettings.autoStartBreak,
                      onChanged: (val) {
                         timerSettings.updateAutoStartBreak(val);
                      },
                      activeTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                      activeThumbColor: Theme.of(context).primaryColor,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                  ),
                  _buildConfigItem(
                    title: 'Pomodoro Otomatik Başlatılsın mı?',
                    trailing: Switch(
                      value: timerSettings.autoStartPomodoro,
                      onChanged: (val) {
                        timerSettings.updateAutoStartPomodoro(val);
                      },
                      activeTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                      activeThumbColor: Theme.of(context).primaryColor,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                  ),
                  _buildConfigItem(
                    title: 'Toplam Aralıklar',
                    trailing: _buildDropdown(
                      _totalIntervals,
                      ['2', '3', '4', '5', '6', '7', '8', '9', '10'],
                      '',
                      (val) {
                        if (val != null) {
                          setState(() => _totalIntervals = val);
                          timerSettings.updateTotalIntervals(int.parse(val));
                        }
                      },
                    ),
                  ),
                  _buildConfigItem(
                    title: 'Odak Süresi',
                    trailing: _buildDropdown(
                      timerSettings.focusDuration.toString(),
                      ['15', '20', '25', '30', '45', '60'],
                      'dak',
                      (val) => timerSettings.updateFocusDuration(int.parse(val!)),
                    ),
                  ),
                  _buildConfigItem(
                    title: 'Kısa Mola',
                    trailing: _buildDropdown(
                      timerSettings.shortBreakDuration.toString(),
                      ['3', '5', '10', '15'],
                      'dak',
                      (val) => timerSettings.updateShortBreakDuration(int.parse(val!)),
                    ),
                  ),
                  _buildConfigItem(
                    title: 'Uzun Mola',
                    trailing: _buildDropdown(
                      timerSettings.longBreakDuration.toString(),
                      ['10', '15', '20', '25', '30'],
                      'dak',
                      (val) => timerSettings.updateLongBreakDuration(int.parse(val!)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Painters remain the same
class DistantMountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA5D6A7).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(100, size.height - 80);
    path.lineTo(200, size.height - 40);
    path.lineTo(350, size.height - 120);
    path.lineTo(500, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ModernMountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height - 80); 
    path.lineTo(size.width, size.height - 200); 
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// A CustomClipper that matches the ModernMountainPainter but selects the "sky" 
// (the area ABOVE the mountain) to keep the weather constrained to the horizon.
class MountainClipClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // We want the weather to be visible in the area from the top of the screen
    // DOWN TO the mountain surface.
    
    // The mountain surface points: 
    // Left edge: size.height - 80 
    // Right edge: size.height - 200
    //
    // So the path should include the top-left, top-right, right-mountain-edge, left-mountain-edge
    final path = Path();
    path.lineTo(0, size.height - 80);            // Go down left side to the mountain start
    path.lineTo(size.width, size.height - 200);  // Trace the mountain slope to the right side
    path.lineTo(size.width, 0);                  // Go up the right side to the top
    path.close();                                // Close back to top-left (0,0)
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
