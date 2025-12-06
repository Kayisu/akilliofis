import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/place_model.dart';
import '../widgets/room_detail/room_detail_pager.dart';

class RoomDetailScreen extends StatelessWidget {
  final PlaceModel place;

  const RoomDetailScreen({super.key, required this.place});

  void _openReservation(BuildContext context) {
    // router.dart'taki yapıya uygun olarak extra parametresiyle odayı gönderiyoruz
    context.push('/reservation/create', extra: place);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          place.name,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Kaydırmalı Grafikler (Sensör verileri burada dönecek)
            Expanded(
              child: RoomDetailPager(roomId: place.id),
            ),
            
            // Alt Kısım: Rezervasyon Butonu
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () => _openReservation(context),
                  child: const Text('Rezervasyon Oluştur'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}