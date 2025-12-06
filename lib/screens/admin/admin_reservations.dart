import 'package:flutter/material.dart';
import '../../data/reservation_model.dart';
import '../../data/reservation_repo.dart';

class AdminReservations extends StatefulWidget {
  const AdminReservations({super.key});

  @override
  State<AdminReservations> createState() => _AdminReservationsState();
}

class _AdminReservationsState extends State<AdminReservations> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repo = ReservationRepo();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervasyon Yönetimi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bekleyenler', icon: Icon(Icons.hourglass_empty)),
            Tab(text: 'Tüm Kayıtlar', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Sekme 1: Bekleyenler (Onayla, Reddet, Sil)
          _ReservationListBuilder(
            repo: _repo, 
            statusFilter: 'pending', 
            showActions: true,
          ),
          
          // Sekme 2: Tümü (Sadece Sil)
          _ReservationListBuilder(
            repo: _repo, 
            statusFilter: null, 
            showActions: false, // Onay/Reddet yok, ama Sil her zaman var
          ),
        ],
      ),
    );
  }
}

class _ReservationListBuilder extends StatefulWidget {
  final ReservationRepo repo;
  final String? statusFilter;
  final bool showActions; // True ise Onayla/Reddet butonlarını gösterir

  const _ReservationListBuilder({
    required this.repo,
    this.statusFilter,
    required this.showActions,
  });

  @override
  State<_ReservationListBuilder> createState() => _ReservationListBuilderState();
}

class _ReservationListBuilderState extends State<_ReservationListBuilder> {
  late Future<List<ReservationModel>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = widget.repo.getAdminReservations(filterStatus: widget.statusFilter);
    });
  }

  // Durum Güncelleme (Onayla / Reddet)
  Future<void> _updateStatus(String id, String status) async {
    try {
      await widget.repo.updateStatus(id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Durum güncellendi: $status')),
        );
        _refresh();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  // YENİ: Silme İşlemi (Dialog ile onay alalım)
  Future<void> _deleteItem(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silmek İstediğine Emin misin?'),
        content: const Text('Bu işlem geri alınamaz. Kayıt veritabanından tamamen silinecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.repo.deleteReservation(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt silindi.')),
          );
          _refresh();
        }
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $message'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ReservationModel>>(
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
          return const Center(child: Text('Kayıt bulunamadı.'));
        }

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = list[index];
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(item.status).withAlpha(50),
                    child: Icon(_getStatusIcon(item.status), color: _getStatusColor(item.status)),
                  ),
                  title: Text(item.userName ?? 'Misafir', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${item.placeName ?? "Bilinmeyen Oda"} \n${_formatDate(item.startTs)}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sadece Bekleyenler sekmesindeyse Onay/Ret göster
                      if (widget.showActions) ...[
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                          tooltip: 'Onayla',
                          onPressed: () => _updateStatus(item.id!, 'approved'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined, color: Colors.orange),
                          tooltip: 'Reddet',
                          onPressed: () => _updateStatus(item.id!, 'rejected'),
                        ),
                      ],
                      
                      // Silme butonu her zaman var (ama biraz ayırmak için Divider veya SizedBox koyabiliriz)
                      if (widget.showActions) const SizedBox(width: 8), // Boşluk
                      
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Sil',
                        onPressed: () => _deleteItem(item.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day}.${local.month} ${local.year}  ${local.hour.toString().padLeft(2,'0')}:${local.minute.toString().padLeft(2,'0')}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green.shade700;
      case 'rejected': return Colors.red.shade700;
      case 'pending': return Colors.orange.shade700;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.check;
      case 'rejected': return Icons.close;
      case 'pending': return Icons.hourglass_top;
      default: return Icons.info;
    }
  }
}