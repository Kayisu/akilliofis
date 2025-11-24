import 'package:flutter/material.dart';
import '../widgets/sensor_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  List<SensorModel> _sample() => [
    SensorModel(
      id: '1',
      name: 'Sıcaklık',
      type: 'temperature',
      value: 23.5,
      unit: '°C',
      updatedAt: DateTime.now(),
    ),
    SensorModel(
      id: '2',
      name: 'Nem',
      type: 'humidity',
      value: 48,
      unit: '%',
      updatedAt: DateTime.now(),
    ),
    SensorModel(
      id: '3',
      name: 'CO₂',
      type: 'co2',
      value: 420,
      unit: 'ppm',
      updatedAt: DateTime.now(),
    ),
    // PIR kullanıcı ekranında gizli — admin tarafından görüntülenecekse ayrı ekran/route ekleyin
  ];

  @override
  Widget build(BuildContext context) {
    final sensors = _sample();

    return Scaffold(
      backgroundColor: const Color(0xFF08030A),
      appBar: AppBar(title: const Text('Akıllı Ofis')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: sensors.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.05,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, idx) => SensorCard(sensor: sensors[idx]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
