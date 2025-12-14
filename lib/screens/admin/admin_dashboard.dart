import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Modeller ve Repolar
import '../../data/place_model.dart';
import '../../data/sensor_model.dart';
import '../../data/sensor_repo.dart';

// YENİ WIDGET IMPORTU
import '../../widgets/admin/mini_chart.dart'; 

class AdminDashboard extends StatefulWidget {
  final PlaceModel? place;

  const AdminDashboard({super.key, this.place});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _sensorRepo = SensorRepository();
  
  List<SensorData> _chartData = [];
  SensorData? _latestData;
  StreamSubscription? _sub;
  bool _isLoading = true;

  // Grafikte tutulacak maksimum veri sayısı
  final int _maxChartPoints = 300; 

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _initData() async {
    final place = widget.place;
    if (place == null) return;

    // Geçmiş veriyi çek (Son 300 kayıt)
    final history = await _sensorRepo.getHistory(place.id, limit: 300);
    
    if (mounted) {
      setState(() {
        _chartData = history;
        if (history.isNotEmpty) _latestData = history.last;
        _isLoading = false;
      });
    }

    // Canlı yayına abone ol
    _sub = _sensorRepo.subscribeToPlace(place.id).listen((newData) {
      if (mounted) {
        setState(() {
          _latestData = newData;
          _chartData.add(newData);
          // Liste şişmesin diye baştan kırpıyoruz
          if (_chartData.length > _maxChartPoints) {
            _chartData.removeAt(0);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.place == null) return const Scaffold(body: Center(child: Text("Hata: Ofis seçilmedi")));

    final current = _latestData ?? SensorData.empty();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.place!.name} Kokpit', style: const TextStyle(fontSize: 16)),
            Text(
              _isLoading ? 'Bağlanıyor...' : 'Canlı Veri Akışı', 
              style: const TextStyle(fontSize: 12, color: Colors.greenAccent),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/places'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), 
            onPressed: _initData,
            tooltip: 'Yenile',
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // 1. KPI ÖZETİ (Tek satırda 3 önemli veri)
              Row(
                children: [
                  _buildKpiCard(context, 'Hareket', current.isOccupied ? 'VAR' : 'YOK', Icons.motion_photos_on, current.isOccupied ? Colors.red : Colors.grey),
                  _buildKpiCard(context, 'Konfor', '%${(current.comfortScore * 100).toInt()}', Icons.sentiment_satisfied, Colors.green),
                  _buildKpiCard(context, 'Son Veri', _formatTime(current.recordedAt), Icons.access_time, Colors.blueGrey),
                ],
              ),
              
              const SizedBox(height: 16),
              const Text("Sensör Grafikleri (Son 300 Kayıt)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // 2. GRAFİK IZGARASI (2x2 Layout)
              GridView.count(
                crossAxisCount: 2, 
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // GÜNCEL: Kartlar daha yatay/ince olsun diye oranı artırdık
                childAspectRatio: 2.2, 
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  MiniChart(
                    title: 'Sıcaklık (°C)',
                    color: Colors.orange,
                    data: _chartData,
                    valueMapper: (d) => d.temperature,
                    currentValue: current.temperature.toStringAsFixed(1),
                  ),
                  MiniChart(
                    title: 'Nem (%)',
                    color: Colors.blue,
                    data: _chartData,
                    valueMapper: (d) => d.humidity,
                    currentValue: current.humidity.toStringAsFixed(0),
                  ),
                  MiniChart(
                    title: 'CO2 (ppm)',
                    color: _getCo2Color(current.co2),
                    data: _chartData,
                    valueMapper: (d) => d.co2.toDouble(),
                    currentValue: '${current.co2}',
                  ),
                  MiniChart(
                    title: 'VOC / Gaz',
                    color: Colors.purple,
                    data: _chartData,
                    valueMapper: (d) => d.gas.toDouble(),
                    currentValue: '${current.gas}',
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text("Detaylı Veri Günlüğü", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // 3. YAZILI LİSTE (Tablo Görünümü)
              _buildLogTable(),
            ],
          ),
    );
  }

  // Log Tablosu (Son veriler en üstte)
  Widget _buildLogTable() {
    final logs = List<SensorData>.from(_chartData.reversed).take(50).toList();

    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Başlık Satırı
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade200,
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text("Zaman", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text("Sıcaklık", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(child: Text("Nem", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(child: Text("CO2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(child: Text("Konfor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
          ),
          // Veri Satırları
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = logs[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(_formatTime(item.recordedAt), style: const TextStyle(fontSize: 12))),
                    Expanded(child: Text('${item.temperature}°', style: const TextStyle(fontSize: 12))),
                    Expanded(child: Text('%${item.humidity.toInt()}', style: const TextStyle(fontSize: 12))),
                    Expanded(child: Text('${item.co2}', style: TextStyle(fontSize: 12, color: _getCo2Color(item.co2)))),
                    Expanded(child: Text('%${(item.comfortScore * 100).toInt()}', style: const TextStyle(fontSize: 12))),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: color.withAlpha(20),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: color.withAlpha(50))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('HH:mm:ss').format(date.toLocal());
  }

  Color _getCo2Color(int co2) {
    if (co2 < 800) return Colors.green;
    if (co2 < 1200) return Colors.orange;
    return Colors.red;
  }
}