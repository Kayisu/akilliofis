import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/reservation_model.dart';
import '../data/reservation_repo.dart';
import '../auth/auth_service.dart';
import '../widgets/reservation/reservation_card.dart';

class ReservationList extends StatefulWidget {
  const ReservationList({super.key});

  @override
  State<ReservationList> createState() => _ReservationListState();
}

class _ReservationListState extends State<ReservationList> {
  final _repo = ReservationRepo();
  // Late hatasını önlemek için nullable yapmıyoruz ama initState'de hemen atıyoruz.
  late Future<List<ReservationModel>> _future;

  @override
  void initState() {
    super.initState();
    // 1. HATA DÜZELTME: Build metodu çalışmadan önce future mutlaka dolu olmalı
    _future = _repo.getMyReservations(AuthService.instance.userId);
    
    // 2. Temizliği arka planda yap, bitince listeyi sessizce güncelle
    _runCleanup();
  }

  Future<void> _runCleanup() async {
    try {
      await _repo.processExpiredReservations();
      if (mounted) _refreshList();
    } catch (e) {
      debugPrint("Cleanup error: $e");
    }
  }

  void _refreshList() {
    setState(() {
      _future = _repo.getMyReservations(AuthService.instance.userId);
    });
  }

  Future<bool> _handleSwipe(ReservationModel item) async {
    final isCompleted = item.status == 'completed';
    
    // Metinler
    final actionText = isCompleted ? "listeden kaldırmak" : "iptal etmek";
    final dialogTitle = isCompleted ? "Kaydı Gizle" : "Rezervasyonu İptal Et";

    // Onay İste
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(dialogTitle),
        content: Text('Bu rezervasyonu $actionText istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: isCompleted ? Colors.blueGrey : Colors.red
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isCompleted ? 'Evet, Gizle' : 'Evet, İptal Et'),
          ),
        ],
      ),
    );

    if (confirm != true) return false;

    try {
      if (isCompleted) {
        // SENARYO 1: TAMAMLANMIŞ -> SİLME YOK, GİZLEME VAR
        // Status 'completed' kalır, is_hidden = true olur.
        await _repo.hideReservation(item.id!);
      } else {
        // SENARYO 2: AKTİF (Pending/Rejected) -> İPTAL ET
        // Status 'cancelled' olur. Repo zaten cancelled olanları getirmediği için listeden düşer.
        await _repo.cancelReservation(item.id!);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Rezervasyon iptal edildi.')),
           );
        }
      }
      
      // Listeyi yenile ki değişiklik (gizleme/iptal) yansısın
      // False dönüyoruz, refresh ile liste zaten güncellenecek
      _refreshList();
      return false; 

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
      return false;
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
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/rooms'),
            tooltip: 'Yeni Rezervasyon',
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
                  Icon(Icons.event_note, size: 64, color: Colors.grey.shade700),
                  const SizedBox(height: 16),
                  const Text('Henüz rezervasyonun yok.'),
                  TextButton(
                    onPressed: () => context.push('/rooms'),
                    child: const Text('Oda Kirala'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _runCleanup();
              await _future;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = list[index];
                
                // KAYDIRMA İŞLEMİ (Dismissible)
                return Dismissible(
                  key: Key(item.id!),
                  direction: DismissDirection.endToStart, // Sağdan sola
                  background: Container(
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
                  ),
                  confirmDismiss: (direction) => _handleSwipe(item),
                  child: ReservationCard(reservation: item),
                );
              },
            ),
          );
        },
      ),
    );
  }
}