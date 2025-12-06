import 'package:flutter/material.dart';

//ikinci page
class RoomComfortDonut extends StatelessWidget {
  final VoidCallback onCreateReservation;

  const RoomComfortDonut({super.key, required this.onCreateReservation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Kenarlardan boşluk
      child: Column(
        children: [
          // Başlık
          const Text(
            "Konfor Analizi",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20), // Başlık ile grafik arası boşluk
          // Grafik Alanı
          Expanded(
            child: Center(
              child: SizedBox(
                height: 200, // Grafik boyutu
                width: 200,
                child: Stack(
                  children: [
                    const SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: 0.75, // %75 Konfor Skoru
                        strokeWidth: 50,
                        color: Colors.grey, // Konfor Skoru Rengi
                        backgroundColor: Colors.black, // Konforsuzluk Rengi
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "Konfor Skoru",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            "%75",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20), // Alt boşluk
          // Lejant (Açıklama)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.grey, "Konfor Skoru %75"),
              const SizedBox(width: 20),
              _buildLegendItem(Colors.black, "Konforsuzluk %25"),
            ],
          ),

          // Rezervasyon Butonu
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onCreateReservation,
            child: const Text("Rezervasyon Oluştur"),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
