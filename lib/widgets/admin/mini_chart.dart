//mini_chart.dart
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title, 
                style: TextStyle(
                  fontSize: 11, 
                  color: Colors.grey.shade400, 
                  fontWeight: FontWeight.bold
                )
              ),
              Text(
                currentValue, 
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.bold, 
                  color: color
                )
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Expanded(
            child: LineChart(
              LineChartData(
                clipData: FlClipData.all(),
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false), 
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