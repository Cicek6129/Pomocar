import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ShopItem {
  final String id;
  final String category;
  final String name;
  final int price;
  final IconData? icon;
  final Color color;
  final String? imagePath;
  final double imageScale;
  final bool isWide;

  ShopItem({
    required this.id,
    required this.category,
    required this.name,
    required this.price,
    this.icon,
    required this.color,
    this.imagePath,
    this.imageScale = 1.0,
    this.isWide = false,
  });
}

class ShopView extends StatefulWidget {
  final int currentKm;
  final Function(int) onPurchase;
  final VoidCallback onEquipAction;
  final Function(String) onThemeEquipAction;

  const ShopView({
    Key? key,
    required this.currentKm,
    required this.onPurchase,
    required this.onEquipAction,
    required this.onThemeEquipAction,
  }) : super(key: key);

  @override
  State<ShopView> createState() => _ShopViewState();
}

final List<ShopItem> allShopItems = [
    // Klasik: Arabalar (Garaj)
    ShopItem(id: 'car1', category: 'garaj', name: 'Başlangıç Arabası', price: 0, imagePath: 'assets/car/car1.png', color: Colors.blueGrey),
    
    // Standart Sınıf (10-50 Km)
    ShopItem(id: 'car2', category: 'garaj', name: 'Standart Model 1', price: 10, imagePath: 'assets/car/car15.png', color: Colors.blueGrey),
    ShopItem(id: 'car3', category: 'garaj', name: 'Standart Model 2', price: 15, imagePath: 'assets/car/car2.png', color: Colors.blueGrey),
    ShopItem(id: 'car4', category: 'garaj', name: 'Standart Model 3', price: 20, imagePath: 'assets/car/car3.png', color: Colors.blueGrey),
    ShopItem(id: 'car5', category: 'garaj', name: 'Standart Model 4', price: 20, imagePath: 'assets/car/car12.png', color: Colors.blueGrey),
    ShopItem(id: 'car6', category: 'garaj', name: 'Standart Model 5', price: 25, imagePath: 'assets/car/car5.png', color: Colors.blueGrey),
    ShopItem(id: 'car7', category: 'garaj', name: 'Standart Model 6', price: 30, imagePath: 'assets/car/car7.png', color: Colors.blueGrey),
    ShopItem(id: 'car8', category: 'garaj', name: 'Standart Model 7', price: 30, imagePath: 'assets/car/car16.png', color: Colors.blueGrey),
    ShopItem(id: 'car9', category: 'garaj', name: 'Standart Model 8', price: 35, imagePath: 'assets/car/car8.png', color: Colors.blueGrey),
    ShopItem(id: 'car10', category: 'garaj', name: 'Standart Model 9', price: 40, imagePath: 'assets/car/car19.png', color: Colors.blueGrey),
    ShopItem(id: 'car11', category: 'garaj', name: 'Standart Model 10', price: 40, imagePath: 'assets/car/car9.png', color: Colors.blueGrey),
    ShopItem(id: 'car12', category: 'garaj', name: 'Standart Model 11', price: 45, imagePath: 'assets/car/car10.png', color: Colors.blueGrey, imageScale: 1.6),
    ShopItem(id: 'car13', category: 'garaj', name: 'Standart Model 12', price: 50, imagePath: 'assets/car/car11.png', color: Colors.blueGrey, imageScale: 1.6),
    ShopItem(id: 'car14', category: 'garaj', name: 'Standart Model 13', price: 50, imagePath: 'assets/car/car20.png', color: Colors.blueGrey),
    ShopItem(id: 'car15', category: 'garaj', name: 'Standart Model 14', price: 50, imagePath: 'assets/car/car22.png', color: Colors.blueGrey),

    // Orta Sınıf (60-140 Km)
    ShopItem(id: 'car16', category: 'garaj', name: 'Orta Sınıf 1', price: 80, imagePath: 'assets/car/car4.png', color: Colors.blueAccent),
    ShopItem(id: 'car17', category: 'garaj', name: 'Orta Sınıf 2', price: 100, imagePath: 'assets/car/carr.png', color: Colors.blueAccent, imageScale: 1.6),
    ShopItem(id: 'car18', category: 'garaj', name: 'Orta Sınıf 3', price: 120, imagePath: 'assets/car/car21.png', color: Colors.blueAccent),
    ShopItem(id: 'car19', category: 'garaj', name: 'Orta Sınıf 4', price: 140, imagePath: 'assets/car/car.png', color: Colors.blueAccent),

    // Premium/Spor Sınıf (150-1000+ Km)
    ShopItem(id: 'car20', category: 'garaj', name: 'Premium Spor 1', price: 150, imagePath: 'assets/car/car6.png', color: Colors.redAccent),
    ShopItem(id: 'car21', category: 'garaj', name: 'Premium Spor 2', price: 250, imagePath: 'assets/car/car13.png', color: Colors.redAccent, imageScale: 1.6),
    ShopItem(id: 'car22', category: 'garaj', name: 'Premium Spor 3', price: 400, imagePath: 'assets/car/car17.png', color: Colors.redAccent),
    ShopItem(id: 'car23', category: 'garaj', name: 'Premium Spor 4', price: 600, imagePath: 'assets/car/car18.png', color: Colors.redAccent),
    ShopItem(id: 'car24', category: 'garaj', name: 'Premium Spor 5', price: 1000, imagePath: 'assets/car/car14.png', color: Colors.redAccent),
    
    // Özel: Ağaçlar (Yol)
    ShopItem(id: 'tree1', category: 'yol', name: 'Başlangıç Ağacı 1', price: 0, imagePath: 'assets/tree/tree1.PNG', color: Colors.green),
    ShopItem(id: 'tree2', category: 'yol', name: 'Başlangıç Ağacı 2', price: 0, imagePath: 'assets/tree/tree2.png', color: Colors.green),
    ShopItem(id: 'tree3', category: 'yol', name: 'Başlangıç Ağacı 3', price: 0, imagePath: 'assets/tree/tree3.PNG', color: Colors.green),
    
    // Standart Ağaçlar (5-20 Km)
    ShopItem(id: 'tree4', category: 'yol', name: 'Standart Ağaç 1', price: 5, imagePath: 'assets/tree/tree4.png', color: Colors.green),
    ShopItem(id: 'tree5', category: 'yol', name: 'Standart Ağaç 2', price: 6, imagePath: 'assets/tree/tree5.png', color: Colors.green),
    ShopItem(id: 'tree6', category: 'yol', name: 'Standart Ağaç 3', price: 7, imagePath: 'assets/tree/tree6.png', color: Colors.green),
    ShopItem(id: 'tree7', category: 'yol', name: 'Standart Ağaç 4', price: 8, imagePath: 'assets/tree/tree7.png', color: Colors.green),
    ShopItem(id: 'tree8', category: 'yol', name: 'Standart Ağaç 5', price: 9, imagePath: 'assets/tree/tree8.png', color: Colors.green),
    ShopItem(id: 'tree9', category: 'yol', name: 'Standart Ağaç 6', price: 10, imagePath: 'assets/tree/tree9.png', color: Colors.green),
    ShopItem(id: 'tree10', category: 'yol', name: 'Standart Ağaç 7', price: 11, imagePath: 'assets/tree/tree10.png', color: Colors.green),
    ShopItem(id: 'tree11', category: 'yol', name: 'Standart Ağaç 8', price: 12, imagePath: 'assets/tree/tree11.png', color: Colors.green),
    ShopItem(id: 'tree12', category: 'yol', name: 'Standart Ağaç 9', price: 13, imagePath: 'assets/tree/tree12.png', color: Colors.green),
    ShopItem(id: 'tree13', category: 'yol', name: 'Standart Ağaç 10', price: 14, imagePath: 'assets/tree/tree13.png', color: Colors.green),
    ShopItem(id: 'tree14', category: 'yol', name: 'Standart Ağaç 11', price: 15, imagePath: 'assets/tree/tree14.png', color: Colors.green),
    ShopItem(id: 'tree15', category: 'yol', name: 'Standart Ağaç 12', price: 16, imagePath: 'assets/tree/tree15.png', color: Colors.green),
    ShopItem(id: 'tree16', category: 'yol', name: 'Standart Ağaç 13', price: 18, imagePath: 'assets/tree/tree16.png', color: Colors.green),
    ShopItem(id: 'tree17', category: 'yol', name: 'Standart Ağaç 14', price: 19, imagePath: 'assets/tree/tree17.png', color: Colors.green),
    ShopItem(id: 'tree18', category: 'yol', name: 'Standart Ağaç 15', price: 20, imagePath: 'assets/tree/tree18.png', color: Colors.green),

    // Premium Ağaçlar (50-150 Km)
    ShopItem(id: 'tree19', category: 'yol', name: 'Premium Ağaç 1', price: 50, imagePath: 'assets/tree/tree19.png', color: Colors.amber),
    ShopItem(id: 'tree20', category: 'yol', name: 'Premium Ağaç 2', price: 55, imagePath: 'assets/tree/tree20.png', color: Colors.amber),
    ShopItem(id: 'tree21', category: 'yol', name: 'Premium Ağaç 3', price: 65, imagePath: 'assets/tree/tree21.png', color: Colors.amber),
    ShopItem(id: 'tree22', category: 'yol', name: 'Premium Ağaç 4', price: 75, imagePath: 'assets/tree/tree22.png', color: Colors.amber),
    ShopItem(id: 'tree23', category: 'yol', name: 'Premium Ağaç 5', price: 85, imagePath: 'assets/tree/tree23.png', color: Colors.amber),
    ShopItem(id: 'tree24', category: 'yol', name: 'Premium Ağaç 6', price: 90, imagePath: 'assets/tree/tree24.png', color: Colors.amber),
    ShopItem(id: 'tree25', category: 'yol', name: 'Premium Ağaç 7', price: 95, imagePath: 'assets/tree/tree25.png', color: Colors.amber),
    ShopItem(id: 'tree26', category: 'yol', name: 'Premium Ağaç 8', price: 100, imagePath: 'assets/tree/tree26.png', color: Colors.amber),
    ShopItem(id: 'tree27', category: 'yol', name: 'Premium Ağaç 9', price: 110, imagePath: 'assets/tree/tree27.png', color: Colors.amber),
    ShopItem(id: 'tree28', category: 'yol', name: 'Premium Ağaç 10', price: 120, imagePath: 'assets/tree/tree28.png', color: Colors.amber),
    ShopItem(id: 'tree29', category: 'yol', name: 'Premium Ağaç 11', price: 130, imagePath: 'assets/tree/tree29.png', color: Colors.amber),
    ShopItem(id: 'tree30', category: 'yol', name: 'Premium Ağaç 12', price: 140, imagePath: 'assets/tree/tree30.png', color: Colors.amber),
    ShopItem(id: 'tree31', category: 'yol', name: 'Premium Ağaç 13', price: 150, imagePath: 'assets/tree/tree31.png', color: Colors.amber),
    
    // Çalılar
    ShopItem(id: 'bush0', category: 'gokyuzu', name: 'Başlangıç Çalısı', price: 0,  imagePath: 'assets/bush/bush.png',  color: Colors.green),
    ShopItem(id: 'bush1', category: 'gokyuzu', name: 'Çalı 1',           price: 5,  imagePath: 'assets/bush/bush1.png', color: Colors.green),
    ShopItem(id: 'bush2', category: 'gokyuzu', name: 'Çalı 2',           price: 8,  imagePath: 'assets/bush/bush2.png', color: Colors.green),
    ShopItem(id: 'bush3', category: 'gokyuzu', name: 'Çalı 3',           price: 12, imagePath: 'assets/bush/bush3.png', color: Colors.green),
    ShopItem(id: 'bush4', category: 'gokyuzu', name: 'Çalı 4',           price: 16, imagePath: 'assets/bush/bush4.png', color: Colors.green),
    ShopItem(id: 'bush5', category: 'gokyuzu', name: 'Çalı 5',           price: 20, imagePath: 'assets/bush/bush5.png', color: Colors.green),
    ShopItem(id: 'bush6', category: 'gokyuzu', name: 'Çalı 6',           price: 25, imagePath: 'assets/bush/bush6.png', color: Colors.green),
    ShopItem(id: 'bush7', category: 'gokyuzu', name: 'Çalı 7',           price: 30, imagePath: 'assets/bush/bush7.png', color: Colors.green),
    ShopItem(id: 'bush8', category: 'gokyuzu', name: 'Çalı 8',           price: 35, imagePath: 'assets/bush/bush8.png', color: Colors.green),

    // Kayalar
    ShopItem(id: 'rock0', category: 'gokyuzu', name: 'Başlangıç Kayası', price: 0,  imagePath: 'assets/bush/rock.png',  color: Colors.brown),
    ShopItem(id: 'rock1', category: 'gokyuzu', name: 'Kaya 1',           price: 8,  imagePath: 'assets/bush/rock1.png', color: Colors.brown),
    ShopItem(id: 'rock2', category: 'gokyuzu', name: 'Kaya 2',           price: 12, imagePath: 'assets/bush/rock2.png', color: Colors.brown),
    ShopItem(id: 'rock3', category: 'gokyuzu', name: 'Kaya 3',           price: 18, imagePath: 'assets/bush/rock3.png', color: Colors.brown),
    ShopItem(id: 'rock4', category: 'gokyuzu', name: 'Kaya 4',           price: 25, imagePath: 'assets/bush/rock4.png', color: Colors.brown),
    ShopItem(id: 'rock5', category: 'gokyuzu', name: 'Kaya 5',           price: 35, imagePath: 'assets/bush/rock5.png', color: Colors.brown),
    
    // Ses: Arka Plan Müzikleri (Teyp)
    // Ücretsiz
    ShopItem(id: 'assets/sounds/back/creatorarts-relaxing-heavy-rain-sounds-on-roof-perfect-for-sleep-focus-323383.mp3', category: 'teyp', name: 'Yoğun Yağmur', price: 0, icon: Icons.thunderstorm, color: Colors.indigo),

    // Basic (Doğa / Ambiyans)
    ShopItem(id: 'assets/sounds/back/Rain_Sound_Effect_-_Relaxation_-_Free_Download_-_No_Copyright_320k.mp3', category: 'teyp', name: 'Hafif Yağmur', price: 30, icon: Icons.cloud, color: Colors.lightBlue),
    ShopItem(id: 'assets/sounds/back/liecio-calming-rain-257596.mp3', category: 'teyp', name: 'Sakin Yağmur', price: 40, icon: Icons.umbrella, color: Colors.blueGrey),
    ShopItem(id: 'assets/sounds/back/nils_vega-birds-singing-in-early-summer-359446.mp3', category: 'teyp', name: 'Kuş Sesleri', price: 30, icon: Icons.pets, color: Colors.green),
    ShopItem(id: 'assets/sounds/back/dragon-studio-soothing-river-flow-372456.mp3', category: 'teyp', name: 'Nehir Sesi', price: 50, icon: Icons.water, color: Colors.blue),
    ShopItem(id: 'assets/sounds/back/shrek_30-spring-339281.mp3', category: 'teyp', name: 'Bahar Havası', price: 50, icon: Icons.local_florist, color: Colors.lightGreen),
    ShopItem(id: 'assets/sounds/back/dragon-studio-meditation-music-sound-bite-339735.mp3', category: 'teyp', name: 'Meditasyon', price: 60, icon: Icons.self_improvement, color: Colors.purple),

    // Premium (Müzikler)
    ShopItem(id: 'assets/sounds/back/freesound_community-study-in-b-minor-75946.mp3', category: 'teyp', name: 'Çalışma (B Minor)', price: 100, icon: Icons.menu_book, color: Colors.brown),
    ShopItem(id: 'assets/sounds/back/chill_background-study-110111.mp3', category: 'teyp', name: 'Chill Çalışma', price: 120, icon: Icons.headphones, color: Colors.deepPurple),
    ShopItem(id: 'assets/sounds/back/grand_project-background-lofi-hip-hop-late-night-study-502734.mp3', category: 'teyp', name: 'Lofi Çalışma', price: 150, icon: Icons.nightlife, color: Colors.deepOrange),
    ShopItem(id: 'assets/sounds/back/ikoliks_aj-acoustic-spring-mothers-day-music-320427.mp3', category: 'teyp', name: 'Akustik Bahar', price: 150, icon: Icons.queue_music, color: Colors.pink),
    ShopItem(id: 'assets/sounds/back/kontraa-water-afro-pop-music-445661.mp3', category: 'teyp', name: 'Afro Pop', price: 200, icon: Icons.music_note, color: Colors.orange),

    // Ses: Alarm Sesleri
    // Ücretsiz
    ShopItem(id: 'assets/sounds/alarms/dragon-studio-cute-chime-439613.mp3', category: 'alarm', name: 'Sevimli Çan', price: 0, icon: Icons.notifications_active, color: Colors.blue),

    // Basic (30 Km)
    ShopItem(id: 'assets/sounds/alarms/162851__tempouser__alarm.wav', category: 'alarm', name: 'Klasik Alarm', price: 30, icon: Icons.access_alarm, color: Colors.teal),
    ShopItem(id: 'assets/sounds/alarms/dragon-studio-festive-chime-439612.mp3', category: 'alarm', name: 'Festival Çanı', price: 30, icon: Icons.celebration, color: Colors.orange),

    // Premium (50-80 Km)
    ShopItem(id: 'assets/sounds/alarms/163562__erh__ring-tone-cbn2-b1-93.wav', category: 'alarm', name: 'Modern Zil', price: 50, icon: Icons.phonelink_ring, color: Colors.indigo),
    ShopItem(id: 'assets/sounds/alarms/501880__greenworm__cellphone-alarm-clock.mp3', category: 'alarm', name: 'Telefon Alarmı', price: 60, icon: Icons.phone_android, color: Colors.deepPurple),
    ShopItem(id: 'assets/sounds/alarms/gigidelaromusic-celestial-chime-soft-short-450958.mp3', category: 'alarm', name: 'Göksel Çan', price: 80, icon: Icons.auto_awesome, color: Colors.cyan),

    // Temalar
    ShopItem(id: 'Japon', category: 'tema', name: 'Japon Teması', price: 100, imagePath: 'assets/backgrounds/japan_bg.png', color: Colors.pink, isWide: false),
    ShopItem(id: 'Mısır', category: 'tema', name: 'Mısır Teması', price: 100, imagePath: 'assets/backgrounds/egypt_bg.png', color: Colors.amber, isWide: false),
    ShopItem(id: 'İskandinavya', category: 'tema', name: 'İskandinavya Teması', price: 50, imagePath: 'assets/backgrounds/scandinavia_bg.png', color: Colors.cyan, isWide: false),
    ShopItem(id: 'Derin Uzay', category: 'tema', name: 'Derin Uzay Teması', price: 50, imagePath: 'assets/backgrounds/space_bg.png', color: Colors.indigo, isWide: false),
    ShopItem(id: 'Yeşil', category: 'tema', name: 'Yeşil Tema', price: 50, icon: Icons.color_lens, color: Colors.green, isWide: false),
    ShopItem(id: 'Turuncu', category: 'tema', name: 'Turuncu Tema', price: 50, icon: Icons.color_lens, color: Colors.orange, isWide: false),
  ];

class _ShopViewState extends State<ShopView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AudioPlayer _previewPlayer = AudioPlayer();
  String? _currentlyPlayingId;
  
  List<String> _purchasedItems = [];
  Map<String, String> _equippedItems = {};

  List<String> unlockedTrees = ['tree1', 'tree2', 'tree3'];
  List<String> equippedTrees = ['tree1', 'tree2', 'tree3'];

  List<String> unlockedCalilar = ['bush0', 'rock0'];
  List<String> equippedCalilar = ['bush0', 'rock0'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _previewPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _currentlyPlayingId = null;
        });
      }
    });
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final purchased = prefs.getStringList('purchased_items') ?? [];
    if (purchased.contains('Mor') && !purchased.contains('İskandinavya')) {
      purchased[purchased.indexOf('Mor')] = 'İskandinavya';
      await prefs.setStringList('purchased_items', purchased);
    }
    if (purchased.contains('Mavi') && !purchased.contains('Derin Uzay')) {
      purchased[purchased.indexOf('Mavi')] = 'Derin Uzay';
      await prefs.setStringList('purchased_items', purchased);
    }
    var equippedTheme = prefs.getString('theme_color_key') ?? 'Varsayılan';
    if (equippedTheme == 'Mor') {
      equippedTheme = 'İskandinavya';
      await prefs.setString('theme_color_key', equippedTheme);
    }
    if (equippedTheme == 'Mavi') {
      equippedTheme = 'Derin Uzay';
      await prefs.setString('theme_color_key', equippedTheme);
    }
    setState(() {
      _purchasedItems = purchased;
      
      unlockedTrees = prefs.getStringList('unlocked_trees') ?? ['tree1', 'tree2', 'tree3'];
      equippedTrees = prefs.getStringList('equipped_trees') ?? ['tree1', 'tree2', 'tree3'];
      
      unlockedCalilar = prefs.getStringList('unlocked_calilar') ?? ['bush0', 'rock0'];
      equippedCalilar = prefs.getStringList('equipped_calilar') ?? ['bush0', 'rock0'];
      
      // Default equipped logic or loading from prefs
      _equippedItems['garaj'] = prefs.getString('equipped_garaj') ?? 'car1';
      _equippedItems['yol'] = prefs.getString('equipped_yol') ?? 'default';
      _equippedItems['teyp'] = prefs.getString('equipped_teyp') ?? 'default';
      _equippedItems['tema'] = equippedTheme;
    });
  }

  Future<void> _savePurchases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('purchased_items', _purchasedItems);
    await prefs.setStringList('unlocked_trees', unlockedTrees);
    await prefs.setStringList('unlocked_calilar', unlockedCalilar);
  }

  Future<void> _saveEquips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equipped_garaj', _equippedItems['garaj'] ?? 'car1');
    await prefs.setString('equipped_yol', _equippedItems['yol'] ?? 'default');
    await prefs.setString('equipped_teyp', _equippedItems['teyp'] ?? 'default');
    
    await prefs.setStringList('equipped_trees', equippedTrees);
    await prefs.setStringList('equipped_calilar', equippedCalilar);
    
    widget.onEquipAction(); // Notify parent
  }

  void _purchaseItem(ShopItem item) {
    if (widget.currentKm >= item.price) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Satın Alma Onayı',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.imagePath != null)
                  Transform.scale(
                    scale: item.imageScale,
                    child: Image.asset(item.imagePath!, height: 90, fit: BoxFit.contain)
                  )
                else if (item.icon != null)
                  Icon(item.icon, size: 90, color: item.color),
                const SizedBox(height: 16),
                Text(
                  '\'${item.name}\' adlı öğeyi ${item.price} Km karşılığında satın almak istediğinize emin misiniz?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.grey.shade800),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('İptal', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onPurchase(item.price);
                  setState(() {
                    if (item.category == 'yol') {
                      unlockedTrees.add(item.id);
                    } else if (item.category == 'gokyuzu') {
                      unlockedCalilar.add(item.id);
                    } else {
                      _purchasedItems.add(item.id);
                    }
                  });
                  _savePurchases();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Harika! Yeni öğe başarıyla eklendi.'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Satın Al', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yetersiz Km! Biraz daha odaklanmalısın.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _equipItem(ShopItem item) {
    setState(() {
      _equippedItems[item.category] = item.id;
    });
    _saveEquips();

    if (item.category == 'tema') {
      widget.onThemeEquipAction(item.id);
    }
  }

  void _equipTree(ShopItem item) {
    if (equippedTrees.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dağda en fazla 3 ağaç sergileyebilirsiniz. Lütfen önce birini çıkarın.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      equippedTrees.add(item.id);
    });
    _saveEquips();
  }

  void _unequipTree(ShopItem item) {
    setState(() {
      equippedTrees.remove(item.id);
    });
    _saveEquips();
  }

  void _equipCali(ShopItem item) {
    if (equippedCalilar.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tepede en fazla 3 çalı veya kaya sergileyebilirsiniz. Lütfen önce birini çıkarın.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      equippedCalilar.add(item.id);
    });
    _saveEquips();
  }

  void _unequipCali(ShopItem item) {
    setState(() {
      equippedCalilar.remove(item.id);
    });
    _saveEquips();
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildRibbon(String text, Color bgColor) {
    return Positioned(
      top: 12,
      left: -28,
      child: Transform.rotate(
        angle: -0.785, // -45 degrees
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 4),
          color: bgColor,
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(ShopItem item) {
    bool isTree = item.category == 'yol';
    bool isCali = item.category == 'gokyuzu';
    bool isPurchased = isTree 
        ? unlockedTrees.contains(item.id) 
        : (isCali 
            ? unlockedCalilar.contains(item.id) 
            : (_purchasedItems.contains(item.id) || item.price == 0));
    bool isEquipped = isTree 
        ? equippedTrees.contains(item.id) 
        : (isCali 
            ? equippedCalilar.contains(item.id) 
            : _equippedItems[item.category] == item.id);
    bool isMusic = item.category == 'teyp' || item.category == 'alarm';

    return GestureDetector(
      onTap: () {
        if (!isPurchased) {
          _purchaseItem(item);
        } else if (isTree) {
          if (isEquipped) {
            _unequipTree(item);
          } else {
            _equipTree(item);
          }
        } else if (isCali) {
          if (isEquipped) {
            _unequipCali(item);
          } else {
            _equipCali(item);
          }
        } else if (!isEquipped) {
          _equipItem(item);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Subtle border mimicking premium cards
          border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 1),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Visual Placeholder matching category
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: item.imagePath != null ? 8.0 : 16.0),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      // Squircle for garaj/yol/gokyuzu, Circle for teyp
                      borderRadius: isMusic ? null : BorderRadius.circular(24),
                      shape: isMusic ? BoxShape.circle : BoxShape.rectangle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                          if (item.imagePath != null)
                             item.category == 'tema'
                               ? ClipRRect(
                                   borderRadius: BorderRadius.circular(24),
                                   child: Image.asset(
                                     item.imagePath!,
                                     height: double.infinity,
                                     width: double.infinity,
                                     fit: BoxFit.cover,
                                     alignment: Alignment.bottomCenter,
                                   ),
                                 )
                               : Padding(
                                   padding: const EdgeInsets.all(4.0),
                                   child: Center(
                                     child: Transform.scale(
                                       scale: item.imageScale,
                                       child: Image.asset(item.imagePath!, height: 90, width: double.infinity, fit: BoxFit.contain)
                                     ),
                                   ),
                                 )
                          else if (item.icon != null)
                             Center(child: Icon(item.icon, size: item.isWide ? 64 : 48, color: item.color)),
                          if (isMusic)
                             GestureDetector(
                               onTap: () async {
                                 if (_currentlyPlayingId == item.id) {
                                   await _previewPlayer.stop();
                                   setState(() {
                                     _currentlyPlayingId = null;
                                   });
                                 } else {
                                   await _previewPlayer.stop();
                                   try {
                                     if (kIsWeb) {
                                       await _previewPlayer.play(UrlSource(item.id));
                                     } else {
                                       String assetPath = item.id.replaceAll('assets/', '');
                                       await _previewPlayer.play(AssetSource(assetPath));
                                     }
                                     setState(() {
                                       _currentlyPlayingId = item.id;
                                     });
                                   } catch (e) {
                                     debugPrint('Error playing preview: $e');
                                   }
                                 }
                               },
                               child: Container(
                                   decoration: const BoxDecoration(
                                       color: Colors.white54,
                                       shape: BoxShape.circle,
                                   ),
                                   padding: const EdgeInsets.all(8),
                                   child: Icon(
                                     _currentlyPlayingId == item.id ? Icons.stop_rounded : Icons.play_arrow_rounded, 
                                     color: Colors.black54, 
                                     size: 24
                                   ),
                               ),
                             ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF424242)),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                // Price & Action Button Area
                if (!isPurchased)
                  GestureDetector(
                    onTap: () => _purchaseItem(item),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (isTree || isCali) ? 'Satın Al - ${item.price} Km' : '${item.price} Km',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF616161)),
                          ),
                        ],
                      ),
                    ),
                  )
                else if ((isTree || isCali) && isEquipped)
                  GestureDetector(
                    onTap: () => isTree ? _unequipTree(item) : _unequipCali(item),
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Kaldır',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red),
                      ),
                    ),
                  )
                else if (!isEquipped)
                  GestureDetector(
                    onTap: () {
                      if (isTree) _equipTree(item);
                      else if (isCali) _equipCali(item);
                      else _equipItem(item);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Seç',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Seçili',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                    ),
                  ),
              ],
            ),
            
            // Ribbon / Banner logic
            if (item.price == 0)
              _buildRibbon('Ücretsiz', const Color(0xFF66BB6A))
            else if (isEquipped)
               _buildRibbon('Seçili', Theme.of(context).primaryColor)
            else if (isPurchased)
               _buildRibbon('Alındı', Theme.of(context).primaryColor.withValues(alpha: 0.8)),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildGridForCategory(String category) {
    final items = allShopItems.where((i) => i.category == category).toList();
    final wideItems = items.where((i) => i.isWide).toList();
    final normalItems = items.where((i) => !i.isWide).toList();

    if (wideItems.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildItemCard(items[index]);
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...wideItems.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: _buildItemCard(item),
          ),
        )),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: normalItems.length,
          itemBuilder: (context, index) {
            return _buildItemCard(normalItems[index]);
          },
        ),
      ],
    );
  }

  Widget _buildSesTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Inner TabBar
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: const [
                Tab(text: '🎵 Arka Plan Sesi'),
                Tab(text: '⏰ Alarm Sesi'),
              ],
            ),
          ),
          // Inner TabBarView
          Expanded(
            child: TabBarView(
              children: [
                _buildGridForCategory('teyp'),
                _buildGridForCategory('alarm'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Background color adapting to Theme
      appBar: AppBar(
        title: const Text('Mağaza', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              // Translucent wrapper for balance
              color: Colors.black.withValues(alpha: 0.2), 
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '${widget.currentKm} Km',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            color: Theme.of(context).primaryColor,
            child: Theme(
              data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.center, // Precisely center the tabs
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                // Forest-style pill tabs
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withValues(alpha: 0.2), // Pill background for active tab
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                tabs: const [
                   Tab(text: 'Garaj'),
                   Tab(text: 'Ağaçlar'),
                   Tab(text: 'Çalılar'),
                   Tab(text: 'Ses'),
                   Tab(text: 'Temalar'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGridForCategory('garaj'),
          _buildGridForCategory('yol'),
          _buildGridForCategory('gokyuzu'),
          _buildSesTab(),
          _buildGridForCategory('tema'),
        ],
      ),
    );
  }
}
