// lib/widgets/room_detail/room_detail_pager.dart
import 'package:flutter/material.dart';
import 'room_occupancy_chart.dart';
import 'room_comfort_donut.dart';
import 'room_sensor_stats.dart';

class RoomDetailPager extends StatefulWidget {
  final VoidCallback onCreateReservation;

  const RoomDetailPager({
    super.key,
    required this.onCreateReservation,
  });

  @override
  State<RoomDetailPager> createState() => _RoomDetailPagerState();
}

class _RoomDetailPagerState extends State<RoomDetailPager> {
  final _controller = PageController();
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      RoomOccupancyChart(onCreateReservation: widget.onCreateReservation),
      RoomComfortDonut(onCreateReservation: widget.onCreateReservation),
      RoomSensorStats(onCreateReservation: widget.onCreateReservation),
    ];

    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            children: pages,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pages.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _page == i ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
