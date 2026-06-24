import 'package:flutter/material.dart';
import 'plain_color_themes.dart';
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
  final bool isJaponTheme;

  const ShopView({
    Key? key,
    required this.currentKm,
    required this.onPurchase,
    required this.onEquipAction,
    required this.onThemeEquipAction,
    this.isJaponTheme = false,
  }) : super(key: key);

  @override
  State<ShopView> createState() => ShopViewState();
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
    
    // Uzay Teması Mekikleri
    ShopItem(id: 'uzay_1', category: 'garaj', name: 'Mekik 1', price: 0, imagePath: 'assets/car/uzay_1.png', color: Colors.indigo, imageScale: 1.0),
    ShopItem(id: 'uzay_2', category: 'garaj', name: 'Mekik 2', price: 250, imagePath: 'assets/car/uzay_2.png', color: Colors.indigo, imageScale: 1.0),
    ShopItem(id: 'uzay_3', category: 'garaj', name: 'Mekik 3', price: 250, imagePath: 'assets/car/uzay_3.png', color: Colors.indigo, imageScale: 1.0),
    ShopItem(id: 'uzay_4', category: 'garaj', name: 'Mekik 4', price: 250, imagePath: 'assets/car/uzay_4.png', color: Colors.indigo, imageScale: 1.0),
    // Özel: Ağaçlar (Yol)
    // (Ağaçlar assets/tree içerisinde yer alır)

    // Standart Ağaçlar (50-150 Km) (Eskiden Premium)
    ShopItem(id: 'tree19', category: 'yol', name: 'Standart Ağaç 1', price: 50, imagePath: 'assets/tree/tree19.png', color: Colors.green),
    ShopItem(id: 'tree20', category: 'yol', name: 'Standart Ağaç 2', price: 55, imagePath: 'assets/tree/tree20.png', color: Colors.green),
    ShopItem(id: 'tree21', category: 'yol', name: 'Standart Ağaç 3', price: 65, imagePath: 'assets/tree/tree21.png', color: Colors.green),
    ShopItem(id: 'tree22', category: 'yol', name: 'Standart Ağaç 4', price: 75, imagePath: 'assets/tree/tree22.png', color: Colors.green),
    ShopItem(id: 'tree23', category: 'yol', name: 'Standart Ağaç 5', price: 85, imagePath: 'assets/tree/tree23.png', color: Colors.green),
    ShopItem(id: 'tree24', category: 'yol', name: 'Standart Ağaç 6', price: 90, imagePath: 'assets/tree/tree24.png', color: Colors.green),
    ShopItem(id: 'tree25', category: 'yol', name: 'Standart Ağaç 7', price: 95, imagePath: 'assets/tree/tree25.png', color: Colors.green),
    ShopItem(id: 'tree26', category: 'yol', name: 'Standart Ağaç 8', price: 100, imagePath: 'assets/tree/tree26.png', color: Colors.green),
    ShopItem(id: 'tree27', category: 'yol', name: 'Standart Ağaç 9', price: 110, imagePath: 'assets/tree/tree27.png', color: Colors.green),
    ShopItem(id: 'tree28', category: 'yol', name: 'Standart Ağaç 10', price: 120, imagePath: 'assets/tree/tree28.png', color: Colors.green),
    ShopItem(id: 'tree29', category: 'yol', name: 'Standart Ağaç 11', price: 130, imagePath: 'assets/tree/tree29.png', color: Colors.green),
    ShopItem(id: 'tree30', category: 'yol', name: 'Standart Ağaç 12', price: 140, imagePath: 'assets/tree/tree30.png', color: Colors.green),
    ShopItem(id: 'tree31', category: 'yol', name: 'Standart Ağaç 13', price: 150, imagePath: 'assets/tree/tree31.png', color: Colors.green),

    // Tema Ağaçları (Sakura)
    ShopItem(id: 'tree_sakura1', category: 'yol', name: 'Hasır Meşesi', price: 250, imagePath: 'assets/tree/Hasır Meşesi.png', color: Colors.pinkAccent),
    ShopItem(id: 'tree_sakura2', category: 'yol', name: 'Pagoda Yaprağı', price: 250, imagePath: 'assets/tree/Pagoda Yaprağı.png', color: Colors.pinkAccent),
    ShopItem(id: 'tree_sakura3', category: 'yol', name: 'Sakura Sürgünü', price: 250, imagePath: 'assets/tree/Sakura Sürgünü.png', color: Colors.pinkAccent),
    ShopItem(id: 'tree_sakura4', category: 'yol', name: 'Zen Çamı', price: 250, imagePath: 'assets/tree/Zen Çamı.png', color: Colors.pinkAccent),

    // Tema Ağaçları (Mısır)
    ShopItem(id: 'tree_misir1', category: 'yol', name: 'Hurma Palmiyesi', price: 250, imagePath: 'assets/tree/Hurma Palmiyesi.png', color: Colors.amber),
    ShopItem(id: 'tree_misir2', category: 'yol', name: 'Papirüs Sazı', price: 250, imagePath: 'assets/tree/Papirüs Sazı.png', color: Colors.amber),
    ShopItem(id: 'tree_misir3', category: 'yol', name: 'Saguaro Kaktüsü', price: 250, imagePath: 'assets/tree/Saguaro Kaktüsü.png', color: Colors.amber),
    ShopItem(id: 'tree_misir4', category: 'yol', name: 'Şemsiye Akasya', price: 250, imagePath: 'assets/tree/Şemsiye Akasya.png', color: Colors.amber),

    // Tema Ağaçları (Uzay - Gezegenler)
    ShopItem(id: 'planet_2', category: 'yol', name: 'Gezegen 1', price: 0, imagePath: 'assets/planets/planet_2.png', color: Colors.indigo),
    ShopItem(id: 'planet_3', category: 'yol', name: 'Gezegen 2', price: 0, imagePath: 'assets/planets/planet_3.png', color: Colors.indigo),
    ShopItem(id: 'planet_4', category: 'yol', name: 'Gezegen 3', price: 0, imagePath: 'assets/planets/planet_4.png', color: Colors.indigo),
    ShopItem(id: 'planet_5', category: 'yol', name: 'Gezegen 4', price: 0, imagePath: 'assets/planets/planet_5.png', color: Colors.indigo),
    ShopItem(id: 'planet_6', category: 'yol', name: 'Gezegen 5', price: 0, imagePath: 'assets/planets/planet_6.png', color: Colors.indigo),
    ShopItem(id: 'planet_7', category: 'yol', name: 'Gezegen 6', price: 50, imagePath: 'assets/planets/planet_7.png', color: Colors.indigo),
    ShopItem(id: 'planet_8', category: 'yol', name: 'Gezegen 7', price: 50, imagePath: 'assets/planets/planet_8.png', color: Colors.indigo),
    ShopItem(id: 'planet_9', category: 'yol', name: 'Gezegen 8', price: 50, imagePath: 'assets/planets/planet_9.png', color: Colors.indigo),
    ShopItem(id: 'planet_10', category: 'yol', name: 'Gezegen 9', price: 50, imagePath: 'assets/planets/planet_10.png', color: Colors.indigo),
    ShopItem(id: 'planet_11', category: 'yol', name: 'Gezegen 10', price: 50, imagePath: 'assets/planets/planet_11.png', color: Colors.indigo),

    // Tema Ağaçları (İskandinavya)
    ShopItem(id: 'tree_isk1', category: 'yol', name: 'Bodur Huş Ağacı', price: 250, imagePath: 'assets/tree/Bodur Huş Ağacı.png', color: Colors.cyan),
    ShopItem(id: 'tree_isk2', category: 'yol', name: 'Kadim Yggdrasil Dişbudak', price: 250, imagePath: 'assets/tree/Kadim Yggdrasil Dişbudak.png', color: Colors.cyan),
    ShopItem(id: 'tree_isk3', category: 'yol', name: 'Karlı Norveç Ladini', price: 250, imagePath: 'assets/tree/Karlı Norveç Ladini.png', color: Colors.cyan),
    ShopItem(id: 'tree_isk4', category: 'yol', name: 'Rüzgar Dövülmüş İskoç Çamı', price: 250, imagePath: 'assets/tree/Rüzgar Dövülmüş İskoç Çamı.png', color: Colors.cyan),

    // Tema Ağaçları (Machu Picchu)
    ShopItem(id: 'tree_mac1', category: 'yol', name: 'Arrayán Ağacı', price: 250, imagePath: 'assets/tree/Arrayán Ağacı.png', color: Colors.green),
    ShopItem(id: 'tree_mac2', category: 'yol', name: 'Cinchona Ağacı', price: 250, imagePath: 'assets/tree/Cinchona Ağacı.png', color: Colors.green),
    ShopItem(id: 'tree_mac3', category: 'yol', name: 'Queñua Ağacı', price: 250, imagePath: 'assets/tree/Queñua Ağacı.png', color: Colors.green),
    ShopItem(id: 'tree_mac4', category: 'yol', name: 'Sauco Ağacı', price: 250, imagePath: 'assets/tree/Sauco Ağacı.png', color: Colors.green),
    
    // Çalılar
    ShopItem(id: 'bush0', category: 'cali', name: 'Başlangıç Çalısı', price: 0,  imagePath: 'assets/bush/bush.png',  color: Colors.green),
    ShopItem(id: 'bush1', category: 'cali', name: 'Çalı 1',           price: 5,  imagePath: 'assets/bush/bush1.png', color: Colors.green),
    ShopItem(id: 'bush2', category: 'cali', name: 'Çalı 2',           price: 8,  imagePath: 'assets/bush/bush2.png', color: Colors.green),
    ShopItem(id: 'bush3', category: 'cali', name: 'Çalı 3',           price: 12, imagePath: 'assets/bush/bush3.png', color: Colors.green),
    ShopItem(id: 'bush7', category: 'cali', name: 'Çalı 4',           price: 16, imagePath: 'assets/bush/bush7.png', color: Colors.green),
    ShopItem(id: 'bush8', category: 'cali', name: 'Çalı 5',           price: 20, imagePath: 'assets/bush/bush8.png', color: Colors.green),
    
    // Tema Çalıları (Sakura)
    ShopItem(id: 'sakura_bush1', category: 'cali', name: 'Başlangıç Sakurası', price: 250, imagePath: 'assets/bush/Sakura_Bush_and_rock/Başlangıç Sakurası.png', color: Colors.pinkAccent),
    ShopItem(id: 'sakura_bush2', category: 'cali', name: 'Bulut Sakura', price: 250, imagePath: 'assets/bush/Sakura_Bush_and_rock/Bulut Sakura.png', color: Colors.pinkAccent),
    ShopItem(id: 'sakura_bush3', category: 'cali', name: 'Gelişmiş Sakura Çalısı', price: 250, imagePath: 'assets/bush/Sakura_Bush_and_rock/Gelişmiş Sakura Çalısı.png', color: Colors.pinkAccent),
    ShopItem(id: 'sakura_bush4', category: 'cali', name: 'Nadir Beyaz Sakura', price: 250, imagePath: 'assets/bush/Sakura_Bush_and_rock/Nadir Beyaz Sakura.png', color: Colors.pinkAccent),
    ShopItem(id: 'sakura_bush5', category: 'cali', name: 'Yoğun Koyu Pembe Sakura', price: 250, imagePath: 'assets/bush/Sakura_Bush_and_rock/Yoğun Koyu Pembe Sakura.png', color: Colors.pinkAccent),

    // Tema Çalıları (Mısır)
    ShopItem(id: 'misir_bush1', category: 'cali', name: 'Kaktüs', price: 250, imagePath: 'assets/bush/misir_bush_and_rock/kaktus.png', color: Colors.amber),
    ShopItem(id: 'misir_bush2', category: 'cali', name: 'Kuru Çalı', price: 250, imagePath: 'assets/bush/misir_bush_and_rock/kuru_cali.png', color: Colors.amber),
    ShopItem(id: 'misir_bush3', category: 'cali', name: 'Papirüs Demeti', price: 250, imagePath: 'assets/bush/misir_bush_and_rock/papirus_demeti.png', color: Colors.amber),

    // Tema Çalıları (Uzay - Meteorlar)
    ShopItem(id: 'meteor_1', category: 'cali', name: 'Meteor 1', price: 0, imagePath: 'assets/planets/meteor_1.png', color: Colors.indigo),
    ShopItem(id: 'meteor_2', category: 'cali', name: 'Meteor 2', price: 0, imagePath: 'assets/planets/meteor_2.png', color: Colors.indigo),
    ShopItem(id: 'meteor_3', category: 'cali', name: 'Meteor 3', price: 0, imagePath: 'assets/planets/meteor_3.png', color: Colors.indigo),
    ShopItem(id: 'meteor_4', category: 'cali', name: 'Meteor 4', price: 20, imagePath: 'assets/planets/meteor_4.png', color: Colors.indigo),
    ShopItem(id: 'meteor_5', category: 'cali', name: 'Meteor 5', price: 20, imagePath: 'assets/planets/meteor_5.png', color: Colors.indigo),

    // Tema Çalıları (İskandinavya)
    ShopItem(id: 'isk_bush1', category: 'cali', name: 'Bodur Huş Ağacı', price: 250, imagePath: 'assets/bush/iskandinavya_Bush_and_Rock/bodur_hus.png', color: Colors.cyan),
    ShopItem(id: 'isk_bush2', category: 'cali', name: 'Kar Kaplı Ardıç', price: 250, imagePath: 'assets/bush/iskandinavya_Bush_and_Rock/ardic_dali.png', color: Colors.cyan),
    ShopItem(id: 'isk_bush3', category: 'cali', name: 'Kar Kaplı Funda', price: 250, imagePath: 'assets/bush/iskandinavya_Bush_and_Rock/funda_calisi.png', color: Colors.cyan),
    ShopItem(id: 'isk_bush4', category: 'cali', name: 'Eğrelti ve Yaban Mersini', price: 250, imagePath: 'assets/bush/iskandinavya_Bush_and_Rock/egrelti_yaban_mersini.png', color: Colors.cyan),

    // Tema Çalıları (Machu Picchu)
    ShopItem(id: 'mac_bush1', category: 'cali', name: 'And Eğrelti Otu', price: 250, imagePath: 'assets/bush/Machu_Pichu_Bush_and_rock/and_egrelti.png', color: Colors.green),
    ShopItem(id: 'mac_bush2', category: 'cali', name: 'Miconia Yaprakları', price: 250, imagePath: 'assets/bush/Machu_Pichu_Bush_and_rock/miconia.png', color: Colors.green),
    ShopItem(id: 'mac_bush3', category: 'cali', name: 'Yabani And Orkidesi', price: 250, imagePath: 'assets/bush/Machu_Pichu_Bush_and_rock/and_orkidesi.png', color: Colors.green),
    ShopItem(id: 'mac_bush4', category: 'cali', name: 'And Küpesi', price: 250, imagePath: 'assets/bush/Machu_Pichu_Bush_and_rock/and_kupesi.png', color: Colors.green),
    ShopItem(id: 'mac_bush5', category: 'cali', name: 'Machu Picchu Bromeliad', price: 250, imagePath: 'assets/bush/Machu_Pichu_Bush_and_rock/mp_bromeliad.png', color: Colors.green),
    ShopItem(id: 'mac_bush6', category: 'cali', name: 'Yerli Podocarpus', price: 250, imagePath: 'assets/bush/Machu_Pichu_Bush_and_rock/podocarpus.png', color: Colors.green),

    // Kayalar
    ShopItem(id: 'rock0', category: 'kaya', name: 'Başlangıç Kayası', price: 0,  imagePath: 'assets/bush/rock.png',  color: Colors.brown),
    
    // Tema Kayaları (Sakura)
    ShopItem(id: 'sakura_rock1', category: 'kaya', name: 'Doğal Bahçe Taşı', price: 250, imagePath: 'assets/bush/Sakura_Bush_and_rock/Doğal Bahçe Taşı.png', color: Colors.grey),
    ShopItem(id: 'sakura_rock2', category: 'kaya', name: 'Sakura Su Havuzu', price: 250, imagePath: 'assets/bush/Sakura_Bush_and_rock/Sakura Su Havuzu.png', color: Colors.grey),
    ShopItem(id: 'sakura_rock3', category: 'kaya', name: 'Sakura Taş Feneri', price: 250, imagePath: 'assets/bush/Sakura_Bush_and_rock/Sakura Taş Feneri.png', color: Colors.grey),
    ShopItem(id: 'sakura_rock4', category: 'kaya', name: 'Sakura Taş Köprü', price: 250, imagePath: 'assets/bush/Sakura_Bush_and_rock/Sakura Taş Köprü.png', color: Colors.grey),
    ShopItem(id: 'sakura_rock5', category: 'kaya', name: 'Sakura Çakıl Paketi', price: 250, imagePath: 'assets/bush/Sakura_Bush_and_rock/Sakura Çakıl Paketi.png', color: Colors.grey),
    
    // Tema Kayaları (Uzay - Gezegenler)
    // Removed because meteors are only 5.


    // Tema Kayaları (Mısır)
    ShopItem(id: 'misir_rock1', category: 'kaya', name: 'Hiyeroglif Taşı', price: 250, imagePath: 'assets/bush/misir_bush_and_rock/hiyeroglif_tasi.png', color: Colors.amber),
    ShopItem(id: 'misir_rock2', category: 'kaya', name: 'Kaya Yığını', price: 250, imagePath: 'assets/bush/misir_bush_and_rock/kaya_yigini.png', color: Colors.amber),
    ShopItem(id: 'misir_rock3', category: 'kaya', name: 'Sütun Kaidesi', price: 250, imagePath: 'assets/bush/misir_bush_and_rock/sutun_kaidesi.png', color: Colors.amber),
    ShopItem(id: 'misir_rock4', category: 'kaya', name: 'Oturan Kedi', price: 250, imagePath: 'assets/bush/misir_bush_and_rock/oturan_kedi.png', color: Colors.amber),
    ShopItem(id: 'misir_rock5', category: 'kaya', name: 'Yatan Kedi', price: 250, imagePath: 'assets/bush/misir_bush_and_rock/yatan_kedi.png', color: Colors.amber),

    // Tema Kayaları (İskandinavya)
    ShopItem(id: 'isk_rock1', category: 'kaya', name: 'Kar Kaplı Kaya', price: 250, imagePath: 'assets/bush/iskandinavya_Bush_and_Rock/karli_kaya.png', color: Colors.cyan),
    ShopItem(id: 'isk_rock2', category: 'kaya', name: 'Savaş Baltası', price: 250, imagePath: 'assets/bush/iskandinavya_Bush_and_Rock/savas_baltasi.png', color: Colors.cyan),
    ShopItem(id: 'isk_rock3', category: 'kaya', name: 'Ejderha Rünü', price: 250, imagePath: 'assets/bush/iskandinavya_Bush_and_Rock/ejderha_runu.png', color: Colors.cyan),
    ShopItem(id: 'isk_rock4', category: 'kaya', name: 'FRI Rünü', price: 250, imagePath: 'assets/bush/iskandinavya_Bush_and_Rock/fri_runu.png', color: Colors.cyan),

    // Tema Kayaları (Machu Picchu)
    ShopItem(id: 'mac_rock1', category: 'kaya', name: 'And Teras Duvarı 1', price: 250, imagePath: 'assets/bush/Machu_Pichu_Bush_and_rock/and_teras_1.png', color: Colors.green),
    ShopItem(id: 'mac_rock2', category: 'kaya', name: 'And Teras Duvarı 2', price: 250, imagePath: 'assets/bush/Machu_Pichu_Bush_and_rock/and_teras_2.png', color: Colors.green),
    ShopItem(id: 'mac_rock3', category: 'kaya', name: 'And Teras Duvarı 3', price: 250, imagePath: 'assets/bush/Machu_Pichu_Bush_and_rock/and_teras_3.png', color: Colors.green),
    ShopItem(id: 'mac_rock4', category: 'kaya', name: 'And Teras Duvarı 4', price: 250, imagePath: 'assets/bush/Machu_Pichu_Bush_and_rock/and_teras_4.png', color: Colors.green),
    ShopItem(id: 'mac_rock5', category: 'kaya', name: 'And Teras Duvarı 5', price: 250, imagePath: 'assets/bush/Machu_Pichu_Bush_and_rock/and_teras_5.png', color: Colors.green),

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
    ShopItem(id: 'Machu Picchu', category: 'tema', name: 'Machu Picchu Teması', price: 100, imagePath: 'assets/backgrounds/machu_picchu_bg.png', color: Colors.green, isWide: false),
    ShopItem(id: 'İskandinavya', category: 'tema', name: 'İskandinavya Teması', price: 50, imagePath: 'assets/backgrounds/scandinavia_bg.png', color: Colors.cyan, isWide: false),
    ShopItem(id: 'Derin Uzay', category: 'tema', name: 'Derin Uzay Teması', price: 50, imagePath: 'assets/backgrounds/space_bg.png', color: Colors.indigo, isWide: false),
    ...plainColorThemes.map(
      (t) => ShopItem(
        id: t.id,
        category: 'tema',
        name: t.shopName,
        price: t.price,
        icon: Icons.color_lens,
        color: t.primary,
        isWide: false,
      ),
    ),
  ];

class ShopViewState extends State<ShopView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AudioPlayer _previewPlayer = AudioPlayer();
  String? _currentlyPlayingId;
  
  List<String> _purchasedItems = [];
  Map<String, String> _equippedItems = {};

  List<String> unlockedTrees = ['tree19', 'tree20', 'tree21'];
  List<String> equippedTrees = ['tree19', 'tree20', 'tree21'];

  List<String> unlockedCalilar = ['bush0'];
  List<String> equippedCalilar = ['bush0'];

  List<String> unlockedKayalar = ['rock0'];
  List<String> equippedKayalar = ['rock0'];

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
      
      unlockedTrees = prefs.getStringList('unlocked_trees') ?? ['tree19', 'tree20', 'tree21'];
      equippedTrees = prefs.getStringList('equipped_trees') ?? ['tree19', 'tree20', 'tree21'];
      
      unlockedCalilar = prefs.getStringList('unlocked_calilar') ?? ['bush0'];
      equippedCalilar = prefs.getStringList('equipped_calilar') ?? ['bush0'];

      unlockedKayalar = prefs.getStringList('unlocked_kayalar') ?? ['rock0'];
      equippedKayalar = prefs.getStringList('equipped_kayalar') ?? ['rock0'];
      
      // Default equipped logic or loading from prefs
      _equippedItems['garaj'] = prefs.getString('equipped_garaj') ?? 'car1';
      _equippedItems['yol'] = prefs.getString('equipped_yol') ?? 'default';
      _equippedItems['teyp'] = prefs.getString('equipped_teyp') ?? 'default';
      _equippedItems['tema'] = equippedTheme;
      // Retroactive unlock for themes already purchased
      if (_purchasedItems.contains('Japon')) {
        for (var t in ['tree_sakura1', 'tree_sakura2', 'tree_sakura3', 'tree_sakura4']) {
          if (!unlockedTrees.contains(t)) unlockedTrees.add(t);
        }
        for (var b in ['sakura_bush1', 'sakura_bush2', 'sakura_bush3', 'sakura_bush4', 'sakura_bush5']) {
          if (!unlockedCalilar.contains(b)) unlockedCalilar.add(b);
        }
        for (var r in ['sakura_rock1', 'sakura_rock2', 'sakura_rock3', 'sakura_rock4', 'sakura_rock5']) {
          if (!unlockedKayalar.contains(r)) unlockedKayalar.add(r);
        }
      }
      if (_purchasedItems.contains('Mısır')) {
        for (var t in ['tree_misir1', 'tree_misir2', 'tree_misir3', 'tree_misir4']) {
          if (!unlockedTrees.contains(t)) unlockedTrees.add(t);
        }
        for (var b in ['misir_bush1', 'misir_bush2', 'misir_bush3']) {
          if (!unlockedCalilar.contains(b)) unlockedCalilar.add(b);
        }
        for (var r in ['misir_rock1', 'misir_rock2', 'misir_rock3', 'misir_rock4', 'misir_rock5']) {
          if (!unlockedKayalar.contains(r)) unlockedKayalar.add(r);
        }
      }
      if (_purchasedItems.contains('İskandinavya')) {
        for (var t in ['tree_isk1', 'tree_isk2', 'tree_isk3', 'tree_isk4']) {
          if (!unlockedTrees.contains(t)) unlockedTrees.add(t);
        }
        for (var b in ['isk_bush1', 'isk_bush2', 'isk_bush3', 'isk_bush4']) {
          if (!unlockedCalilar.contains(b)) unlockedCalilar.add(b);
        }
        for (var r in ['isk_rock1', 'isk_rock2', 'isk_rock3', 'isk_rock4']) {
          if (!unlockedKayalar.contains(r)) unlockedKayalar.add(r);
        }
      }
      if (_purchasedItems.contains('Machu Picchu')) {
        for (var t in ['tree_mac1', 'tree_mac2', 'tree_mac3', 'tree_mac4']) {
          if (!unlockedTrees.contains(t)) unlockedTrees.add(t);
        }
        for (var b in ['mac_bush1', 'mac_bush2', 'mac_bush3', 'mac_bush4', 'mac_bush5', 'mac_bush6']) {
          if (!unlockedCalilar.contains(b)) unlockedCalilar.add(b);
        }
        for (var r in ['mac_rock1', 'mac_rock2', 'mac_rock3', 'mac_rock4', 'mac_rock5']) {
          if (!unlockedKayalar.contains(r)) unlockedKayalar.add(r);
        }
      }
    });
  }

  Future<void> _savePurchases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('purchased_items', _purchasedItems);
    await prefs.setStringList('unlocked_trees', unlockedTrees);
    await prefs.setStringList('unlocked_calilar', unlockedCalilar);
    await prefs.setStringList('unlocked_kayalar', unlockedKayalar);
  }

  Future<void> _saveEquips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equipped_garaj', _equippedItems['garaj'] ?? 'car1');
    await prefs.setString('equipped_yol', _equippedItems['yol'] ?? 'default');
    await prefs.setString('equipped_teyp', _equippedItems['teyp'] ?? 'default');
    
    await prefs.setStringList('equipped_trees', equippedTrees);
    await prefs.setStringList('equipped_calilar', equippedCalilar);
    await prefs.setStringList('equipped_kayalar', equippedKayalar);
    
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
                    } else if (item.category == 'cali') {
                      unlockedCalilar.add(item.id);
                    } else if (item.category == 'kaya') {
                      unlockedKayalar.add(item.id);
                    } else {
                      _purchasedItems.add(item.id);
                      
                      // Tema satın alındığında, ilgili temanın ağaçlarını otomatik aç
                      if (item.id == 'Japon') {
                        var sakuraTrees = ['tree_sakura1', 'tree_sakura2', 'tree_sakura3', 'tree_sakura4'];
                        for (var t in sakuraTrees) {
                          if (!unlockedTrees.contains(t)) unlockedTrees.add(t);
                        }
                        var sakuraBushes = ['sakura_bush1', 'sakura_bush2', 'sakura_bush3', 'sakura_bush4', 'sakura_bush5'];
                        for (var b in sakuraBushes) {
                          if (!unlockedCalilar.contains(b)) unlockedCalilar.add(b);
                        }
                        var sakuraRocks = ['sakura_rock1', 'sakura_rock2', 'sakura_rock3', 'sakura_rock4', 'sakura_rock5'];
                        for (var r in sakuraRocks) {
                          if (!unlockedKayalar.contains(r)) unlockedKayalar.add(r);
                        }
                      } else if (item.id == 'Mısır') {
                        var misirTrees = ['tree_misir1', 'tree_misir2', 'tree_misir3', 'tree_misir4'];
                        for (var t in misirTrees) {
                          if (!unlockedTrees.contains(t)) unlockedTrees.add(t);
                        }
                        var misirBushes = ['misir_bush1', 'misir_bush2', 'misir_bush3'];
                        for (var b in misirBushes) {
                          if (!unlockedCalilar.contains(b)) unlockedCalilar.add(b);
                        }
                        var misirRocks = ['misir_rock1', 'misir_rock2', 'misir_rock3', 'misir_rock4', 'misir_rock5'];
                        for (var r in misirRocks) {
                          if (!unlockedKayalar.contains(r)) unlockedKayalar.add(r);
                        }
                      } else if (item.id == 'İskandinavya') {
                        var iskTrees = ['tree_isk1', 'tree_isk2', 'tree_isk3', 'tree_isk4'];
                        for (var t in iskTrees) {
                          if (!unlockedTrees.contains(t)) unlockedTrees.add(t);
                        }
                        var iskBushes = ['isk_bush1', 'isk_bush2', 'isk_bush3', 'isk_bush4'];
                        for (var b in iskBushes) {
                          if (!unlockedCalilar.contains(b)) unlockedCalilar.add(b);
                        }
                        var iskRocks = ['isk_rock1', 'isk_rock2', 'isk_rock3', 'isk_rock4'];
                        for (var r in iskRocks) {
                          if (!unlockedKayalar.contains(r)) unlockedKayalar.add(r);
                        }
                      } else if (item.id == 'Machu Picchu') {
                        var macTrees = ['tree_mac1', 'tree_mac2', 'tree_mac3', 'tree_mac4'];
                        for (var t in macTrees) {
                          if (!unlockedTrees.contains(t)) unlockedTrees.add(t);
                        }
                        var macBushes = ['mac_bush1', 'mac_bush2', 'mac_bush3', 'mac_bush4', 'mac_bush5', 'mac_bush6'];
                        for (var b in macBushes) {
                          if (!unlockedCalilar.contains(b)) unlockedCalilar.add(b);
                        }
                        var macRocks = ['mac_rock1', 'mac_rock2', 'mac_rock3', 'mac_rock4', 'mac_rock5'];
                        for (var r in macRocks) {
                          if (!unlockedKayalar.contains(r)) unlockedKayalar.add(r);
                        }
                      } else if (item.id == 'Derin Uzay') {
                        if (!_purchasedItems.contains('uzay_1')) {
                          _purchasedItems.add('uzay_1');
                        }
                        var uzayTrees = ['planet_2', 'planet_3', 'planet_4', 'planet_5', 'planet_6'];
                        for (var t in uzayTrees) {
                          if (!unlockedTrees.contains(t)) unlockedTrees.add(t);
                        }
                        var uzayBushes = ['meteor_1', 'meteor_2', 'meteor_3'];
                        for (var b in uzayBushes) {
                          if (!unlockedCalilar.contains(b)) unlockedCalilar.add(b);
                          if (!unlockedKayalar.contains(b)) unlockedKayalar.add(b);
                        }
                      }
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

      if (item.category == 'tema') {
        if (item.id == 'Derin Uzay') {
          _equippedItems['garaj'] = 'uzay_1';
          equippedTrees = ['planet_2', 'planet_3', 'planet_4', 'planet_5', 'planet_6'];
          equippedCalilar = ['meteor_1', 'meteor_2', 'meteor_3'];
          equippedKayalar = ['meteor_1', 'meteor_2', 'meteor_3'];
        } else {
          // Revert garaj if a spaceship is currently equipped
          if (_equippedItems['garaj'] != null && _equippedItems['garaj']!.startsWith('uzay_')) {
            _equippedItems['garaj'] = 'car1';
          }

          if (item.id == 'Japon') {
            equippedTrees = ['tree_sakura1', 'tree_sakura2', 'tree_sakura3', 'tree_sakura4'];
            equippedCalilar = ['sakura_bush1', 'sakura_bush2', 'sakura_bush3', 'sakura_bush4', 'sakura_bush5'];
            equippedKayalar = ['sakura_rock1', 'sakura_rock2', 'sakura_rock3', 'sakura_rock4', 'sakura_rock5'];
          } else if (item.id == 'Mısır') {
            equippedTrees = ['tree_misir1', 'tree_misir2', 'tree_misir3', 'tree_misir4'];
            equippedCalilar = ['misir_bush1', 'misir_bush2', 'misir_bush3'];
            equippedKayalar = ['misir_rock1', 'misir_rock2', 'misir_rock3', 'misir_rock4', 'misir_rock5'];
          } else if (item.id == 'İskandinavya') {
            equippedTrees = ['tree_isk1', 'tree_isk2', 'tree_isk3', 'tree_isk4'];
            equippedCalilar = ['isk_bush1', 'isk_bush2', 'isk_bush3', 'isk_bush4'];
            equippedKayalar = ['isk_rock1', 'isk_rock2', 'isk_rock3', 'isk_rock4'];
          } else if (item.id == 'Machu Picchu') {
            equippedTrees = ['tree_mac1', 'tree_mac2', 'tree_mac3', 'tree_mac4'];
            equippedCalilar = ['mac_bush1', 'mac_bush2', 'mac_bush3', 'mac_bush4', 'mac_bush5', 'mac_bush6'];
            equippedKayalar = ['mac_rock1', 'mac_rock2', 'mac_rock3', 'mac_rock4', 'mac_rock5'];
          } else {
            // Standard color themes: revert planets/meteors back to terrestrial default if needed
            if (equippedTrees.isNotEmpty && equippedTrees.first.startsWith('planet_')) {
              equippedTrees = ['tree1', 'tree2', 'tree3'];
            }
            if (equippedCalilar.isNotEmpty && equippedCalilar.first.startsWith('meteor_')) {
              equippedCalilar = ['bush0'];
            }
            if (equippedKayalar.isNotEmpty && equippedKayalar.first.startsWith('meteor_')) {
              equippedKayalar = ['rock0'];
            }
          }
        }
      }
    });
    _saveEquips();

    if (item.category == 'tema') {
      widget.onThemeEquipAction(item.id);
    }
  }

  void switchToThemesTab() {
    _tabController.animateTo(4); // Themes tab index is 4
  }

  void equipThemeByName(String themeName) {
    try {
      final item = allShopItems.firstWhere(
        (i) => i.category == 'tema' && i.id == themeName,
      );
      _equipItem(item);
    } catch (e) {
      // In case it's a standard color theme not present in the shop
      setState(() {
        _equippedItems['tema'] = themeName;
        // Revert planets/meteors back to terrestrial default if needed
        if (equippedTrees.isNotEmpty && equippedTrees.first.startsWith('planet_')) {
          equippedTrees = ['tree1', 'tree2', 'tree3'];
        }
        if (equippedCalilar.isNotEmpty && equippedCalilar.first.startsWith('meteor_')) {
          equippedCalilar = ['bush0'];
        }
        if (equippedKayalar.isNotEmpty && equippedKayalar.first.startsWith('meteor_')) {
          equippedKayalar = ['rock0'];
        }
        
        // Revert garaj if a spaceship is currently equipped
        if (_equippedItems['garaj'] != null && _equippedItems['garaj']!.startsWith('uzay_')) {
          _equippedItems['garaj'] = 'car1';
        }
        
        _saveEquips();
        widget.onThemeEquipAction(themeName);
      });
    }
  }

  void _equipTree(ShopItem item) {
    if (equippedTrees.length >= 5 && _equippedItems['tema'] != 'Derin Uzay') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dağda en fazla 5 ağaç sergileyebilirsiniz. Lütfen önce birini çıkarın.'),
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
    if (equippedCalilar.length >= 5 && _equippedItems['tema'] != 'Derin Uzay') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tepede en fazla 5 çalı sergileyebilirsiniz. Lütfen önce birini çıkarın.'),
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

  void _equipKaya(ShopItem item) {
    if (equippedKayalar.length >= 5 && _equippedItems['tema'] != 'Derin Uzay') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tepede en fazla 5 kaya sergileyebilirsiniz. Lütfen önce birini çıkarın.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      equippedKayalar.add(item.id);
    });
    _saveEquips();
  }

  void _unequipKaya(ShopItem item) {
    setState(() {
      equippedKayalar.remove(item.id);
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
    bool isCali = item.category == 'cali';
    bool isKaya = item.category == 'kaya';
    bool isPurchased = isTree 
        ? unlockedTrees.contains(item.id) 
        : (isCali 
            ? unlockedCalilar.contains(item.id) 
            : (isKaya
                ? unlockedKayalar.contains(item.id)
                : (_purchasedItems.contains(item.id) || item.price == 0)));
    bool isEquipped = isTree 
        ? equippedTrees.contains(item.id) 
        : (isCali 
            ? equippedCalilar.contains(item.id) 
            : (isKaya
                ? equippedKayalar.contains(item.id)
                : _equippedItems[item.category] == item.id));
    bool isMusic = item.category == 'teyp' || item.category == 'alarm';
    final Color actionColor = _equippedItems['tema'] == 'Derin Uzay' ? Colors.indigoAccent : Theme.of(context).primaryColor;

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
        } else if (isKaya) {
          if (isEquipped) {
            _unequipKaya(item);
          } else {
            _equipKaya(item);
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: actionColor),
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
               _buildRibbon('Seçili', actionColor)
            else if (isPurchased)
               _buildRibbon('Alındı', actionColor.withValues(alpha: 0.8)),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildGridForCategory(String category) {
    var items = allShopItems.where((i) => i.category == category).toList();
    if (_equippedItems['tema'] == 'Derin Uzay' && category == 'cali') {
      items = allShopItems.where((i) => i.category == 'cali' || i.category == 'kaya').toList();
    }

    if (category == 'garaj') {
      if (_equippedItems['tema'] == 'Derin Uzay') {
        items = items.where((i) => i.id.startsWith('uzay_')).toList();
      } else {
        items = items.where((i) => !i.id.startsWith('uzay_')).toList();
      }
    } else if (category == 'yol') {
      if (_equippedItems['tema'] == 'Derin Uzay') {
        items = items.where((i) => i.id.startsWith('planet_')).toList();
      } else {
        items = items.where((i) => !i.id.startsWith('planet_') && !i.id.startsWith('meteor_')).toList();
      }
    } else if (category == 'cali' || category == 'kaya') {
      if (_equippedItems['tema'] == 'Derin Uzay') {
        items = items.where((i) => i.id.startsWith('meteor_')).toList();
      } else {
        items = items.where((i) => !i.id.startsWith('planet_') && !i.id.startsWith('meteor_')).toList();
      }
    }
    final wideItems = items.where((i) => i.isWide).toList();
    final normalItems = items.where((i) => !i.isWide).toList();

    final double bottomPadding = _equippedItems['tema'] == 'Derin Uzay' ? 90.0 : 20.0;

    if (wideItems.isEmpty) {
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
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
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
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

  Widget _buildCaliKayaTab() {
    if (_equippedItems['tema'] == 'Derin Uzay') {
      return _buildGridForCategory('cali');
    }
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
              tabs: [
                Tab(text: _equippedItems['tema'] == 'Derin Uzay' ? '🪐 İrili Ufaklı' : '🌿 Çalılar'),
                Tab(text: _equippedItems['tema'] == 'Derin Uzay' ? '☄️ Meteorlar' : '🪨 Kayalar'),
              ],
            ),
          ),
          // Inner TabBarView
          Expanded(
            child: TabBarView(
              children: [
                _buildGridForCategory('cali'),
                _buildGridForCategory('kaya'),
              ],
            ),
          ),
        ],
      ),
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
    final bool isJapon = widget.isJaponTheme;
    final bool isDerinUzay = _equippedItems['tema'] == 'Derin Uzay';
    final String activeTheme = _equippedItems['tema'] ?? 'Varsayılan';
    final bool hasCustomBg = activeTheme == 'Japon' || activeTheme == 'Derin Uzay' || activeTheme == 'Mısır' || activeTheme == 'İskandinavya' || activeTheme == 'Machu Picchu';
    
    return Scaffold(
      backgroundColor: hasCustomBg ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mağaza', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
        centerTitle: true,
        backgroundColor: _equippedItems['tema'] == 'Derin Uzay' ? const Color(0xFF0A1628) : Theme.of(context).primaryColor,
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
            color: _equippedItems['tema'] == 'Derin Uzay' ? const Color(0xFF0A1628) : Theme.of(context).primaryColor,
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
                tabs: [
                   const Tab(text: 'Garaj'),
                   Tab(text: _equippedItems['tema'] == 'Derin Uzay' ? 'Gezegenler' : 'Ağaçlar'),
                   Tab(text: _equippedItems['tema'] == 'Derin Uzay' ? 'Göktaşları' : 'Çalılar'),
                   const Tab(text: 'Ses'),
                   const Tab(text: 'Temalar'),
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
          _buildCaliKayaTab(),
          _buildSesTab(),
          _buildGridForCategory('tema'),
        ],
      ),
    );
  }
}
