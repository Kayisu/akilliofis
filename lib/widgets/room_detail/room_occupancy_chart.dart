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
  int? _focusedIndex; // Hangi barın seçili olduğunu tutar

  final List<String> _days = ['PZT', 'SAL', 'ÇAR', 'PER', 'CUM', 'CMT', 'PAZ'];
  final List<String> _timeLabels = ['09:00', '11:00', '13:00', '15:00', '17:00'];

  List<ForecastModel> _getForecastsForDay(int dayIndex) {
    if (widget.forecasts.isEmpty) return [];
    final targetWeekday = dayIndex + 1;
    return widget.forecasts
        .where((f) => f.targetTs.weekday == targetWeekday)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final dailyData = _getForecastsForDay(_selectedDayIndex);

    final occupancyData = dailyData.isEmpty
        ? List.filled(5, 0.0)
        : dailyData.take(5).map((e) => e.predictedOccupancy).toList();

    final comfortData = dailyData.isEmpty
        ? List.filled(5, 0.0)
        : dailyData.take(5).map((e) => e.predictedComfort).toList();

    while (occupancyData.length < 5) occupancyData.add(0.0);
    while (comfortData.length < 5) comfortData.add(0.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        children: [
          // 1. BAŞLIK (Dinamik Bilgi Alanı)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildHeaderInfo(occupancyData, comfortData),
          ),

          const SizedBox(height: 10),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),

          // 2. GRAFİK ALANI
          SizedBox(
            height: 220, 
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                final stepX = width / _timeLabels.length;
                
                return GestureDetector(
                  // Boşluğa tıklayınca seçimi kaldır
                  onTap: () => setState(() => _focusedIndex = null),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Arka Plan Çizgisi
                      Positioned(
                        top: height * 0.5,
                        left: 0, right: 0,
                        child: Container(height: 1, color: Colors.white.withAlpha(13)),
                      ),

                      // Barlar (Tıklanabilir Alanlar)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(_timeLabels.length, (index) {
                          final occupancy = occupancyData[index];
                          final maxBarHeight = height - 30; 
                          final barHeight = (occupancy * maxBarHeight).clamp(0.0, maxBarHeight);
                          final isFocused = _focusedIndex == index;

                          return GestureDetector(
                            onTapDown: (_) => setState(() => _focusedIndex = index),
                            // Parmağını çekince seçimi kaldırmak istersen bu satırı aç:
                            // onTapUp: (_) => setState(() => _focusedIndex = null),
                            child: Container(
                              color: Colors.transparent, // Tıklama alanını genişletir
                              width: stepX, 
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Bar
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: isFocused ? 28 : 24, // Seçilince kalınlaşır
                                    height: barHeight == 0 ? 4 : barHeight,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                      border: isFocused ? Border.all(color: Colors.white, width: 1) : null, // Seçilince beyaz çerçeve
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          const Color(0xFF26C6DA).withOpacity(isFocused ? 1.0 : 0.6), 
                                          const Color(0xFF26C6DA).withOpacity(0.1), 
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Saat Etiketi
                                  Text(
                                    _timeLabels[index],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isFocused ? FontWeight.bold : FontWeight.w400,
                                      color: isFocused ? Colors.white : Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),

                      // Konfor Çizgisi
                      Positioned.fill(
                        bottom: 30, 
                        child: IgnorePointer( // Çizgi tıklamayı engellemesin
                          child: CustomPaint(
                            painter: _ComfortLinePainter(
                              data: comfortData,
                              color: const Color(0xFFFFB74D), 
                              pointsCount: _timeLabels.length,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          // 3. LEJANT
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(const Color(0xFF26C6DA), "DOLULUK"),
              Container(
                height: 12, width: 1, color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildLegendDot(const Color(0xFFFFB74D), "KONFOR"),
            ],
          ),

          const SizedBox(height: 30),

          // 4. GÜN SEÇİCİ
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08), 
              borderRadius: BorderRadius.circular(25), 
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_days.length, (index) {
                final isSelected = _selectedDayIndex == index;
                return GestureDetector(
                  onTap: () => setState(() { 
                    _selectedDayIndex = index;
                    _focusedIndex = null; // Gün değişince seçimi sıfırla
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE1BEE7) : Colors.transparent, 
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _days[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.white.withOpacity(0.6),
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

  // Dinamik Başlık Widget'ı
  Widget _buildHeaderInfo(List<double> occupancyData, List<double> comfortData) {
    // Eğer hiçbir şeye basılmadıysa varsayılan başlık
    if (_focusedIndex == null) {
      return Text(
        "TAHMİNİ DOLULUK & KONFOR",
        key: const ValueKey('default'),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.4),
          letterSpacing: 1.5,
        ),
      );
    }

    // Basıldıysa detayları göster
    final occ = (occupancyData[_focusedIndex!] * 100).toInt();
    final comf = (comfortData[_focusedIndex!] * 100).toInt();
    final time = _timeLabels[_focusedIndex!];

    return Row(
      key: const ValueKey('focused'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$time  •  ",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          "DOLULUK %$occ",
          style: const TextStyle(color: Color(0xFF26C6DA), fontWeight: FontWeight.bold),
        ),
        Container(width: 1, height: 10, color: Colors.white54, margin: const EdgeInsets.symmetric(horizontal: 8)),
        Text(
          "KONFOR %$comf",
          style: const TextStyle(color: Color(0xFFFFB74D), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.6), letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

// --- ÖZEL ÇİZİM SINIFI (Aynı kaldı) ---
class _ComfortLinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final int pointsCount;

  _ComfortLinePainter({required this.data, required this.color, required this.pointsCount});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paintLine = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintDotFill = Paint()..color = const Color(0xFF121212)..style = PaintingStyle.fill;
    final paintDotBorder = Paint()..color = color..strokeWidth = 2.0..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / pointsCount;
    final startOffset = stepX / 2;

    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final x = startOffset + (i * stepX);
      final y = size.height - (data[i] * size.height);
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paintLine);

    for (var point in points) {
      canvas.drawCircle(point, 4.0, paintDotFill);
      canvas.drawCircle(point, 4.0, paintDotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}