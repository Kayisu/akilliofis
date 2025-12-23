// room_occupancy_chart.dart
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
  int? _focusedIndex;

  final List<String> _days = ['PZT', 'SAL', 'ÇAR', 'PER', 'CUM', 'CMT', 'PAZ'];
  

  final List<String> _timeLabels = ['09:00', '11:00', '13:00', '15:00', '17:00'];
  final List<int> _targetHours = [9, 11, 13, 15, 17]; 

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

    final occupancyData = _targetHours.map((hour) {
      try {
        final match = dailyData.firstWhere((f) => f.targetTs.hour == hour);

        return match.predictedOccupancy.clamp(0.0, 1.0);
      } catch (e) {
        return 0.0;
      }
    }).toList();

    final comfortData = _targetHours.map((hour) {
      try {
        final match = dailyData.firstWhere((f) => f.targetTs.hour == hour);
        return match.predictedComfort.clamp(0.0, 1.0);
      } catch (e) {
        return 0.0;
      }
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        children: [
        
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildHeaderInfo(occupancyData, comfortData),
          ),

          const SizedBox(height: 10),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),

          SizedBox(
            height: 220, 
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                final stepX = width / _timeLabels.length;
                
                return GestureDetector(
                  onTap: () => setState(() => _focusedIndex = null),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        top: height * 0.5,
                        left: 0, right: 0,
                        child: Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                      ),

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
                            child: Container(
                              color: Colors.transparent,
                              width: stepX, 
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Bar
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: isFocused ? 28 : 24,
                                    height: barHeight == 0 ? 4 : barHeight,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                      border: isFocused ? Border.all(color: Colors.white, width: 1) : null,
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          const Color(0xFF26C6DA).withValues(alpha: isFocused ? 1.0 : 0.6), 
                                          const Color(0xFF26C6DA).withValues(alpha: 0.1), 
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _timeLabels[index],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isFocused ? FontWeight.bold : FontWeight.w400,
                                      color: isFocused ? Colors.white : Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      Positioned.fill(
                        bottom: 30,
                        child: IgnorePointer(
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

          Container(
            height: 50,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08), 
              borderRadius: BorderRadius.circular(25), 
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_days.length, (index) {
                final isSelected = _selectedDayIndex == index;
                return Expanded( 
                  child: GestureDetector(
                    onTap: () => setState(() { 
                      _selectedDayIndex = index;
                      _focusedIndex = null;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8), 
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE1BEE7) : Colors.transparent, 
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _days[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
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

  Widget _buildHeaderInfo(List<double> occupancyData, List<double> comfortData) {
    if (_focusedIndex == null) {
      return Text(
        "TAHMİNİ DOLULUK & KONFOR",
        key: const ValueKey('default'),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.4),
          letterSpacing: 1.5,
        ),
      );
    }

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
            color: Colors.white.withValues(alpha: 0.6), letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

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

    if (points.isNotEmpty) {
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}