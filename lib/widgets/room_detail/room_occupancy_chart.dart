import 'package:flutter/material.dart';
import '../../data/forecast_model.dart';

class RoomOccupancyChart extends StatefulWidget {
  final String roomId;
  final List<ForecastModel> forecasts;

  const RoomOccupancyChart({
    super.key, 
    required this.roomId, 
    required this.forecasts,
  });

  @override
  State<RoomOccupancyChart> createState() => _RoomOccupancyChartState();
}

class _RoomOccupancyChartState extends State<RoomOccupancyChart> {
  int _selectedDayIndex = 0;
  final List<String> _days = ['PZT', 'SAL', 'ÇAR', 'PER', 'CUM', 'CMT', 'PAZ']; // Hepsi büyük, teknik durur

  List<ForecastModel> _getForecastsForDay(int dayIndex) {
    if (widget.forecasts.isEmpty) return [];
    final targetWeekday = dayIndex + 1;
    return widget.forecasts.where((f) => f.targetTs.weekday == targetWeekday).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dailyData = _getForecastsForDay(_selectedDayIndex);
    
    // Veri hazırlığı (Aynı mantık)
    final occupancyData = dailyData.isEmpty 
        ? List.filled(5, 0.0) 
        : dailyData.take(5).map((e) => e.predictedOccupancy).toList();
        
    final comfortData = dailyData.isEmpty 
        ? List.filled(5, 0.0) 
        : dailyData.take(5).map((e) => e.predictedComfort).toList();

    while(occupancyData.length < 5) {
      occupancyData.add(0.0);
    }
    while(comfortData.length < 5) {
      comfortData.add(0.0);
    }

    final timeLabels = ['09:00', '11:00', '13:00', '15:00', '17:00'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Column(
        children: [
          // BAŞLIK (Zarif Tipografi)
          Text(
            "TAHMİNİ DOLULUK & KONFOR",
            style: TextStyle(
              fontSize: 10, 
              fontWeight: FontWeight.w600, 
              color: Colors.white.withAlpha(102),
              letterSpacing: 2.0 // Harf aralığı modernlik katar
            ),
          ),
          
          const SizedBox(height: 24),

          // --- GRAFİK ALANI ---
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                // Barların yerleşimi
                final barWidth = (width / timeLabels.length) * 0.3; // Biraz daha ince barlar

                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // ARKA PLAN ÇİZGİLERİ (Rehber olması için çok silik)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(3, (index) => Container(
                        height: 1, 
                        color: Colors.white.withAlpha(13),
                        width: double.infinity,
                      )),
                    ),

                    // 1. DOLULUK BARLARI (Gradient)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(timeLabels.length, (index) {
                        final occupancy = occupancyData[index];
                        final maxBarHeight = height - 25; // Text için yer bırak
                        final barHeight = (occupancy / 100) * maxBarHeight;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: barWidth,
                              height: barHeight.clamp(0, maxBarHeight),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                // DÜZ RENK YERİNE GRADIENT:
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.cyanAccent.withAlpha(153), // Üstte parlak
                                    Colors.cyanAccent.withAlpha(26), // Alta doğru kayboluyor
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              timeLabels[index],
                              style: TextStyle(
                                fontSize: 10, 
                                fontWeight: FontWeight.w300, // İnce font
                                color: Colors.white.withAlpha(153)
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    // 2. KONFOR ÇİZGİSİ (CustomPainter - Zarif)
                    Positioned.fill(
                      bottom: 25, // Text alanı kadar yukarı
                      child: CustomPaint(
                        painter: _ElegantComfortLinePainter(
                          data: comfortData,
                          color: Colors.orangeAccent,
                          pointsCount: timeLabels.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // --- LEJANT (Minimalist) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.cyanAccent, "Doluluk"),
              Container(width: 1, height: 12, color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal: 16)),
              _buildLegendItem(Colors.orangeAccent, "Konfor"),
            ],
          ),

          const SizedBox(height: 24),

          // --- GÜN SEÇİCİ (Zarif Kapsül Tasarım) ---
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(16), // Tam yuvarlak köşeler
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_days.length, (index) {
                final isSelected = _selectedDayIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDayIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFFD1C4E9) // Lila (Seçili)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _days[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Colors.black : Colors.white.withAlpha(128),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(), 
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white.withAlpha(153), letterSpacing: 1.0)
        ),
      ],
    );
  }
}

// Zarif Çizgi Çizici
class _ElegantComfortLinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final int pointsCount;

  _ElegantComfortLinePainter({required this.data, required this.color, required this.pointsCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0 // Daha ince çizgi
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaintFill = Paint()
      ..color = const Color(0xFF1E1E1E) // Arka plan rengi (veya siyah) ile aynı olmalı ki "içi boş" görünsün
      ..style = PaintingStyle.fill;
      
    final dotPaintBorder = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / pointsCount;
    final startOffset = stepX / 2;

    // Noktaları hesapla
    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final x = startOffset + (i * stepX);
      final availableHeight = size.height * 0.9; // Biraz padding
      // 1.0 en üstte
      final y = (size.height * 0.05) + ((1.0 - data[i]) * availableHeight);
      points.add(Offset(x, y));
    }

    // Çizgiyi çiz (Düz çizgiler daha teknik durur, ama yumuşatmak istersek buraya curve ekleriz)
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // Noktaları çiz (İçi boş halkalar - "Hollow Dots")
    for (var point in points) {
      // Önce içini temizle (arka plan rengiyle boya)
      canvas.drawCircle(point, 3.5, dotPaintFill);
      // Sonra kenarını boya
      canvas.drawCircle(point, 3.5, dotPaintBorder);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}