//reservation_create.dart
import 'package:flutter/material.dart';
import '../data/place_model.dart';
import '../widgets/reservation/reservation_form.dart';

class ReservationCreate extends StatelessWidget {
  final PlaceModel? place;

  const ReservationCreate({super.key, this.place});

  @override
  Widget build(BuildContext context) {
    if (place == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: const Center(child: Text('Oda bilgisi bulunamadı.')),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('${place!.name} Rezerve Et'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ReservationForm(place: place!),
        ),
      ),
    );
  }
}