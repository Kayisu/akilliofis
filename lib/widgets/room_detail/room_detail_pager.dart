import 'dart:async';
import 'package:flutter/material.dart';

// --- KENDİ DOSYALARINI İMPORT ET ---
import '../../data/sensor_model.dart'; // Model dosyan
import '../../data/sensor_repo.dart'; // Repo dosyan

import 'room_occupancy_chart.dart';
import 'room_comfort_donut.dart';
import 'room_sensor_stats.dart';

class RoomDetailPager extends StatefulWidget {
  final String roomId;

  const RoomDetailPager({super.key, required this.roomId});

  @override
  State<RoomDetailPager> createState() => _RoomDetailPagerState();
}

class _RoomDetailPagerState extends State<RoomDetailPager> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // 1. REPO VE TIMER TANIMLARI (EKSİKTİ, EKLENDİ)
  final SensorRepository _repository = SensorRepository();
  Timer? _timer;

  // Başlangıç verisi (Boş)
  SensorData _currentData = SensorData(
    temperature: 0,
    humidity: 0,
    co2: 0,
    gas: 0,
    comfortScore: 0,
  );

  @override
  void initState() {
    super.initState();
    // 2. VERİ ÇEKMEYİ BAŞLAT (EKSİKTİ, EKLENDİ)
    _startDataFetching();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hafıza sızıntısını önle
    _controller.dispose();
    super.dispose();
  }

  // --- VERİ ÇEKME FONKSİYONLARI ---
  void _startDataFetching() {
    _fetchData(); // İlk açılışta çek
    // Her 3 saniyede bir güncelle
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final newData = await _repository.getSensorData();
    if (mounted) {
      setState(() {
        _currentData = newData;
      });
    }
  }

  // --- SAYFA GEÇİŞ FONKSİYONLARI ---
  void _prevPage() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3. SAYFALARI 'BUILD' İÇİNE ALDIK
    // Neden? Çünkü _currentData değiştiğinde (setState olduğunda)
    // ekranın güncellenmesi için sayfaların yeniden oluşturulması lazım.
    final pages = [
      // 1. Sayfa
      RoomOccupancyChart(roomId: widget.roomId),
      // 2. Sayfa
      RoomComfortDonut(roomId: widget.roomId),
      // 3. Sayfa: DİNAMİK VERİYİ BURADAN GÖNDERİYORUZ
      RoomSensorStats(data: _currentData),
    ];

    // Senin istediğin Expanded yapısı:
    return Expanded(
      child: Column(
        children: [
          // --- ÜST KISIM: OKLAR VE SLIDER ---
          Expanded(
            child: Row(
              children: [
                // Sol Ok
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 24),
                  color:
                      _currentPage > 0
                          ? Colors.black
                          : Colors.grey.withOpacity(0.3),
                  onPressed: _currentPage > 0 ? _prevPage : null,
                ),

                // Orta: Kayan Grafikler
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: pages, // Yukarıda tanımladığımız dinamik liste
                  ),
                ),

                // Sağ Ok
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 24),
                  color:
                      _currentPage < pages.length - 1
                          ? Colors.black
                          : Colors.grey.withOpacity(0.3),
                  onPressed: _currentPage < pages.length - 1 ? _nextPage : null,
                ),
              ],
            ),
          ),

          // --- ALT KISIM: NOKTALAR (DOTS) ---
          const SizedBox(
            height: 20,
          ), // Boşluğu biraz azalttım (50 çok fazlaydı)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pages.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 10 : 8,
                height: _currentPage == index ? 10 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentPage == index
                          ? Colors.black
                          : Colors.grey.shade400,
                ),
              );
            }),
          ),
          const SizedBox(height: 20), // Alt boşluk
        ],
      ),
    );
  }
}
