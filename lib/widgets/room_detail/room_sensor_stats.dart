// room_sensor_stats.dart
import 'package:flutter/material.dart';
import '../../data/sensor_model.dart';

class RoomSensorStats extends StatelessWidget {
  final SensorData data;

  const RoomSensorStats({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Yüzdelik hesaplama
    final int comfortPercent = (data.comfortScore * 100).toInt();

    // Konfor Mantığı (RoomComfortDonut ile eşitlendi)
    Color comfortColor;
    IconData comfortIcon;
    String comfortText;

    if (comfortPercent <= 30) {
      comfortColor = Colors.grey.shade800;
      comfortIcon = Icons.sentiment_very_dissatisfied;
      comfortText = "Kötü";
    } else if (comfortPercent <= 40) {
      comfortColor = Colors.redAccent;
      comfortIcon = Icons.sentiment_dissatisfied;
      comfortText = "Rahatsız";
    } else if (comfortPercent <= 50) {
      comfortColor = Colors.yellowAccent;
      comfortIcon = Icons.sentiment_neutral;
      comfortText = "İdare Eder";
    } else if (comfortPercent <= 85) {
      comfortColor = Colors.lightGreenAccent;
      comfortIcon = Icons.sentiment_satisfied;
      comfortText = "İyi";
    } else {
      comfortColor = Colors.greenAccent;
      comfortIcon = Icons.sentiment_very_satisfied;
      comfortText = "Mükemmel";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // 1. Fiziksel Sensörler (2x2 Izgara)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6, 
            children: [
              _buildStatCard(
                context,
                title: "Sıcaklık",
                value: "${data.temperature}°",
                icon: Icons.thermostat_outlined,
                color: _getTempColor(data.temperature),
              ),
              _buildStatCard(
                context,
                title: "Nem",
                value: "%${data.humidity.toInt()}",
                icon: Icons.water_drop_outlined,
                color: Colors.blueAccent,
              ),
              _buildStatCard(
                context,
                title: "CO₂",
                value: "${data.co2}",
                unit: "ppm",
                icon: Icons.cloud_queue,
                color: _getCo2Color(data.co2),
              ),
              _buildStatCard(
                context,
                title: "Hava Kalitesi",
                value: "${data.gas}",
                icon: Icons.air,
                color: Colors.purpleAccent,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 2. Genel Konfor Kartı (Footer)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "GENEL KONFOR",
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "%$comfortPercent",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            color: comfortColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          comfortText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: comfortColor.withAlpha(204),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(comfortIcon, color: comfortColor, size: 42),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    String? unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color.withAlpha(204), size: 18),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey.shade500, 
                  fontSize: 10, 
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.w300, 
                  color: Colors.white
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12, 
                    color: Colors.grey.shade400
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  // Renk mantıkları
  Color _getTempColor(double temp) {
    if (temp < 18) return Colors.cyanAccent;
    if (temp > 28) return Colors.redAccent;
    return Colors.greenAccent;
  }

  Color _getCo2Color(int co2) {
    if (co2 < 800) return Colors.greenAccent;
    if (co2 < 1200) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}