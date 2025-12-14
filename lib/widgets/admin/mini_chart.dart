import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/sensor_model.dart';

class MiniChart extends StatelessWidget {
  final String title;
  final String currentValue;
  final Color color;
  final List<SensorData> data;
  final double Function(SensorData) valueMapper;

  const MiniChart({
    super.key,
    required this.title,
    required this.currentValue,
    required this.color,
    required this.data,
    required this.valueMapper,
  });

  @override
  Widget build(BuildContext context) {
    // Veri noktalarını hazırla
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), valueMapper(e.value));
    }).toList();

    return Container(
      // GÜNCEL: Dikey boşlukları kıstık, kart daha zarif dursun diye
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Koyu Lacivert Arka Plan
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(25)), // Hafif saydam kenarlık
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Başlık ve Değer Satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title, 
                style: TextStyle(
                  fontSize: 11, // GÜNCEL: Font küçüldü
                  color: Colors.grey.shade400, 
                  fontWeight: FontWeight.bold
                )
              ),
              Text(
                currentValue, 
                style: TextStyle(
                  fontSize: 14, // GÜNCEL: Değer fontu dengelendi
                  fontWeight: FontWeight.bold, 
                  color: color
                )
              ),
            ],
          ),
          
          // GÜNCEL: Grafik ile yazı arasındaki boşluk azaltıldı (12 -> 4)
          const SizedBox(height: 4),
          
          // Grafik Alanı
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false), // Etkileşim kapalı
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true, 
                      color: color.withAlpha(50)
                    ),
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