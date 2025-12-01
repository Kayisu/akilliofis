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

  Future<void> _cancelItem(String id) async {
    try {
      await _repo.cancelReservation(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Liste güncellendi.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İşlem başarısız: $e'), backgroundColor: Colors.red),
        );
      }
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
              
              // Duruma göre tasarım değişkenlerini belirle
              final isRejected = item.status == 'rejected';
              
              final actionColor = isRejected ? Colors.red.shade700 : Colors.orange.shade700;
              final actionText = isRejected ? 'LİSTEDEN SİL' : 'İPTAL ET';
              final actionIcon = isRejected ? Icons.delete_sweep_outlined : Icons.cancel_presentation;
              
              final dialogTitle = isRejected ? 'Listeden Sil' : 'Rezervasyon İptali';
              final dialogContent = isRejected 
                  ? 'Bu reddedilmiş rezervasyonu listeden kaldırmak istiyor musunuz?'
                  : 'Bu rezervasyonu iptal etmek istediğinize emin misiniz?';
              final dialogButtonText = isRejected ? 'Evet, Sil' : 'Evet, İptal Et';

              return Dismissible(
                key: Key(itemKey),
                direction: DismissDirection.endToStart,
                
                // Dinamik Arkaplan
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: actionColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        actionText, 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(width: 8),
                      Icon(actionIcon, color: Colors.white, size: 28),
                    ],
                  ),
                ),
                
                // Dinamik Onay Diyaloğu
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(dialogTitle),
                      content: Text(dialogContent),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: actionColor,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(dialogButtonText),
                        ),
                      ],
                    ),
                  );
                },

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