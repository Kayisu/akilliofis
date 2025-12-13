import 'package:flutter/material.dart';
import '../../data/sensor_model.dart';
import '../../data/forecast_model.dart';

import 'room_occupancy_chart.dart';
import 'room_comfort_donut.dart';
import 'room_sensor_stats.dart';

class RoomDetailPager extends StatefulWidget {
  final String roomId;
  // Dışarıdan gelen veriler
  final SensorData sensorData;
  final List<ForecastModel> forecasts;

  const RoomDetailPager({
    super.key, 
    required this.roomId,
    required this.sensorData,
    required this.forecasts,
  });

  @override
  State<RoomDetailPager> createState() => _RoomDetailPagerState();
}

class _RoomDetailPagerState extends State<RoomDetailPager> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    final pages = [
      // 1. Sayfa: Tahmin Grafiği
      RoomOccupancyChart(
        roomId: widget.roomId, 
        forecasts: widget.forecasts
      ),
      
      // 2. Sayfa: Anlık Konfor Donut
      // 'data' parametresi SensorData bekliyor
      RoomComfortDonut(data: widget.sensorData),
      
      // 3. Sayfa: Detaylı İstatistikler
      RoomSensorStats(data: widget.sensorData),
    ];

    return Column(
      children: [
        // İçerik Alanı
        Expanded(
          child: PageView(
            controller: _controller,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: pages,
          ),
        ),

        // Alt Navigasyon (Dots + Oklar)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.grey.withAlpha(_currentPage > 0 ? 255 : 50)),
                onPressed: _currentPage > 0 ? _prevPage : null,
              ),
              
              // Nokta İndikatörleri
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(pages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade700,
                    ),
                  );
                }),
              ),

              IconButton(
                icon: Icon(Icons.chevron_right, color: Colors.grey.withAlpha(_currentPage < pages.length - 1 ? 255 : 50)),
                onPressed: _currentPage < pages.length - 1 ? _nextPage : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}