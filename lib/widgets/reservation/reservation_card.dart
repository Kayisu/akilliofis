import 'package:flutter/material.dart';
import '../../data/reservation_model.dart';

class ReservationCard extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationCard({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(reservation.status);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: reservation.status == 'completed' 
          ? Theme.of(context).cardColor.withAlpha(120) 
          : Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: statusInfo.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
          
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        reservation.placeName ?? 'Oda',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: reservation.status == 'cancelled' ? TextDecoration.lineThrough : null,
                          color: reservation.status == 'cancelled' ? Colors.grey : null,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusInfo.color.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusInfo.color.withAlpha(50)),
                        ),
                        child: Text(
                          statusInfo.label,
                          style: TextStyle(
                            color: statusInfo.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatDate(reservation.startTs)}  •  ${_formatTime(reservation.startTs)} - ${_formatTime(reservation.endTs)}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.day}.${dt.month}.${dt.year}';
  String _formatTime(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  _StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'approved': return _StatusInfo('Onaylandı', Colors.greenAccent);
      case 'pending': return _StatusInfo('Bekliyor', Colors.orangeAccent);
      case 'rejected': return _StatusInfo('Reddedildi', Colors.redAccent);
      case 'cancelled': return _StatusInfo('İptal', Colors.grey);
      case 'completed': return _StatusInfo('Tamamlandı', Colors.blueGrey);
      default: return _StatusInfo('?', Colors.grey);
    }
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  _StatusInfo(this.label, this.color);
}