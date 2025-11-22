// lib/features/sensor/presentation/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../data/sensor_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _sensorRepo = SensorRepository();
  List<RecordModel> _readings = [];
  bool _loading = true;
  UnsubscribeFunc? _unsub; // realtime'i dispose'da kapatmak için

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _setupRealtime();
  }

  Future<void> _loadInitial() async {
    try {
      final items = await _sensorRepo.getLatestReadings(limit: 50);
      setState(() {
        _readings = items;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading sensor data: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _setupRealtime() async {
    _unsub = await _sensorRepo.subscribeSensorReadings((event) {
      if (!mounted) return;
      if (event.action == 'create' && event.record != null) {
        setState(() {
          _readings.insert(0, event.record!);
          if (_readings.length > 100) {
            _readings.removeLast();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _unsub?.call(); // realtime subscription'ı kapat
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sensör Dashboard')),
      body: ListView.builder(
        itemCount: _readings.length,
        itemBuilder: (context, index) {
          final r = _readings[index];
          final co2 = r.data['co2_ppm'];
          final comfort = r.data['comfort_score'];
          final temp = r.data['temp_c'];
          final ts = r.data['recorded_at'];

          return ListTile(
            title: Text('CO₂: $co2 ppm | Comfort: $comfort'),
            subtitle: Text('Sıcaklık: $temp °C\n$ts'),
          );
        },
      ),
    );
  }
}
