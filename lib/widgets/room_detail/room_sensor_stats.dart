import 'package:flutter/material.dart';
import '../../data/sensor_model.dart';

class RoomSensorStats extends StatelessWidget {
  final SensorData data;

  const RoomSensorStats({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Yüzdelik hesaplama
    final int comfortPercent = (data.comfortScore * 100).toInt();

    // Konfor Mantığı (İstediğin gibi revize edildi)
    Color comfortColor;
    IconData comfortIcon;
    String comfortText;

    if (comfortPercent <= 30) {
      comfortColor = Colors.black; // Veya koyu gri (Dark modda görünmesi için)
      comfortIcon = Icons.sentiment_very_dissatisfied; // Ölü gibi
      comfortText = "Kötü";
    } else if (comfortPercent <= 55) {
      comfortColor = Colors.redAccent;
      comfortIcon = Icons.sentiment_dissatisfied; // Üzgün
      comfortText = "Rahatsız";
    } else if (comfortPercent <= 70) {
      comfortColor = Colors.yellowAccent; // Sarı
      comfortIcon = Icons.sentiment_neutral; // Durgun
      comfortText = "İdare Eder";
    } else {
      comfortColor = Colors.greenAccent; // Yeşil
      comfortIcon = Icons.sentiment_very_satisfied; // Mutlu
      comfortText = "Mükemmel";
    }
    
    // Eğer siyah zemin kullanıyorsak siyah ikon görünmez, onu koyu gri yapalım
    // veya özel bir "ölü" efekti için gri tonu kullanalım.
    if (comfortColor == Colors.black) comfortColor = Colors.grey.shade800;

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
            childAspectRatio: 1.6, // Biraz daha yatay, zarif oran
            children: [
              _buildStatCard(
                context,
                title: "Sıcaklık",
                value: "${data.temperature}°",
                icon: Icons.thermostat_outlined, // Outlined ikonlar daha zariftir
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
                icon: Icons.cloud_queue, // Daha ince bulut ikonu
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
              // Hafif gradient veya düz renk
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
                        letterSpacing: 1.5, // Harf aralığı modernlik katar
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
                            fontWeight: FontWeight.w300, // İnce font (Thin/Light)
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(40), // Daha şeffaf
        borderRadius: BorderRadius.circular(20), // Daha yuvarlak köşeler
        border: Border.all(color: Colors.white.withAlpha(15)), // Çok ince kenarlık
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Üst Kısım: İkon ve Başlık
          Row(
            children: [
              Icon(icon, color: color.withAlpha(204), size: 18),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(), // Büyük harf her zaman daha "teknik" durur
                style: TextStyle(
                  color: Colors.grey.shade500, 
                  fontSize: 10, 
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
          
          // Alt Kısım: Değer
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.w300, // Light font
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

  // Renk mantıkları (Aynı)
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