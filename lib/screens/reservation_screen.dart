// lib/screens/reservation_screen.dart
import 'package:flutter/material.dart';

class ReservationScreen extends StatelessWidget {
  const ReservationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: TextFormField + date/time picker + ReservationRepo entegrasyonu
    return Scaffold(
      appBar: AppBar(title: const Text('Rezervasyon Oluştur')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Expanded(
              child: Center(child: Text('Rezervasyon formu (TODO)')),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: formu validate et, PocketBase'e POST et
                },
                child: const Text('Rezervasyon Oluştur'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
