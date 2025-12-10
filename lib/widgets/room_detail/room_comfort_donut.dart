import 'package:flutter/material.dart';
import '../../data/sensor_model.dart';

class RoomComfortDonut extends StatelessWidget {
  final SensorData data;

  const RoomComfortDonut({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final double score = data.comfortScore;
    final int percent = (score * 100).toInt();

    // Yeni Renk ve İkon Mantığı
    Color scoreColor;
    IconData statusIcon;
    String statusText;

    if (percent <= 30) {
      scoreColor =
          Colors.grey.shade800; // Siyah yerine koyu gri (görünürlük için)
      statusIcon = Icons.sentiment_very_dissatisfied;
      statusText = "Kötü";
    } else if (percent <= 40) {
      scoreColor = Colors.redAccent;
      statusIcon = Icons.sentiment_dissatisfied;
      statusText = "Rahatsız";
    } else if (percent <= 50) {
      scoreColor = Colors.yellowAccent;
      statusIcon = Icons.sentiment_neutral;
      statusText = "İdare Eder";
    } else if (percent <= 85) {
      scoreColor = Colors.lightGreenAccent;
      statusIcon = Icons.sentiment_satisfied;
      statusText = "İyi";
    } else {
      scoreColor = Colors.greenAccent;
      statusIcon = Icons.sentiment_very_satisfied;
      statusText = "Mükemmel";
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 200, // Biraz küçülttük, daha kompakt
          width: 200,
          child: Stack(
            children: [
              // Arka plan halkası (Çok ince)
              Center(
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8, // İnceltildi (önceki 15'ti)
                    color: Colors.white.withAlpha(13),
                  ),
                ),
              ),
              // Değer halkası (İnce ve zarif)
              Center(
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value:
                        score > 0 ? score : 0.01, // 0 olsa bile minik görünsün
                    strokeWidth: 8, // İnceltildi
                    color: scoreColor,
                    strokeCap: StrokeCap.round, // Yuvarlak uçlar
                  ),
                ),
              ),
              // Ortadaki İçerik
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      color: scoreColor.withAlpha(204),
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$percent",
                          style: const TextStyle(
                            fontSize: 56, // Büyük ama
                            fontWeight: FontWeight.w200, // Çok ince (Thin)
                            color: Colors.white,
                            height: 1.0, // Satır yüksekliğini sıkılaştır
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            "%",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 14,
                        color: scoreColor.withAlpha(204),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "GENEL KONFOR SKORU",
          style: TextStyle(
            color: Colors.white.withAlpha(77),
            fontSize: 10,
            letterSpacing: 2.0, // Harfler arası boşluk (premium hissi)
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
