import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../data/reservation_model.dart';
import '../data/reservation_repo.dart';
import '../widgets/reservation/reservation_card.dart';

class ReservationList extends StatefulWidget {
  const ReservationList({super.key});

  @override
  State<ReservationList> createState() => _ReservationListState();
}

class _ReservationListState extends State<ReservationList> {
  final _repo = ReservationRepo();
  late Future<List<ReservationModel>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = _repo.getMyReservations(AuthService.instance.userId);
    });
  }

  // Fonksiyon ismi artık cancelItem
  Future<void> _cancelItem(String id) async {
    try {
      await _repo.cancelReservation(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rezervasyon iptal edildi.')),
        );
      }
      // Listeyi sunucudan tekrar çekmemize gerek yok, 
      // Dismissible zaten görsel olarak sildi.
      // Ama veri tutarlılığı için arka planda _refresh çağrılabilir.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İptal hatası: $e'), backgroundColor: Colors.red),
        );
      }
      // Hata olursa listeyi yenile ki sildiğimiz eleman geri gelsin
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervasyonlarım'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<ReservationModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          
          final list = snapshot.data ?? [];
          
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available, size: 80, color: Colors.grey.withAlpha(128)),
                  const SizedBox(height: 16),
                  const Text(
                    'Aktif rezervasyonunuz yok.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = list[index];
              final String itemKey = item.id ?? UniqueKey().toString();

              return Dismissible(
                key: Key(itemKey),
                direction: DismissDirection.endToStart, // Sola kaydır
                
                // Arkaplan Tasarımı (Turuncu + İptal İkonu)
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700, // İptal rengi
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        'İPTAL ET', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.cancel_presentation, color: Colors.white, size: 28),
                    ],
                  ),
                ),
                
                // Onay Diyaloğu
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Rezervasyon İptali'),
                      content: const Text(
                        'Bu rezervasyonu iptal etmek ve listeden kaldırmak istediğinize emin misiniz?'
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.orange.shade800,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Evet, İptal Et'),
                        ),
                      ],
                    ),
                  );
                },

                // Onaylanınca çalışır
                onDismissed: (direction) {
                  if (item.id != null) {
                    _cancelItem(item.id!);
                  }
                },
                
                child: ReservationCard(reservation: item),
              );
            },
          );
        },
      ),
    );
  }
}