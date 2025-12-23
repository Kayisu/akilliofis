//admin_reservations.dart
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
    _runCleanup(); 
  }

  Future<void> _runCleanup() async {
    await _repo.processExpiredReservations();
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
          _ReservationListBuilder(
            repo: _repo, 
            statusFilter: 'pending', 
            showActions: true,
          ),
          _ReservationListBuilder(
            repo: _repo, 
            statusFilter: null, 
            showActions: false, 
          ),
        ],
      ),
    );
  }
}

class _ReservationListBuilder extends StatefulWidget {
  final ReservationRepo repo;
  final String? statusFilter;
  final bool showActions;

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

  Future<void> _refresh() async {
    if (widget.statusFilter == null) {
       await widget.repo.processExpiredReservations();
    }
    if (mounted) {
      setState(() {
        _future = widget.repo.getAdminReservations(filterStatus: widget.statusFilter);
      });
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      await widget.repo.updateStatus(id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Durum: $status')));
        _refresh();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  Future<void> _deleteItem(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kalıcı Olarak Sil'),
        content: const Text('Bu işlem geri alınamaz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.repo.deleteReservation(id);
      if (mounted) _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ReservationModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Hata: ${snapshot.error}'));

        final list = snapshot.data ?? [];
        if (list.isEmpty) return const Center(child: Text('Kayıt bulunamadı.'));

        return RefreshIndicator(
          onRefresh: _refresh,
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
                  subtitle: Text('${item.placeName ?? "Oda"} \n${_formatDate(item.startTs)} - ${item.status.toUpperCase()}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.showActions && item.status == 'pending') ...[
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                          onPressed: () => _updateStatus(item.id!, 'approved'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined, color: Colors.orange),
                          onPressed: () => _updateStatus(item.id!, 'rejected'),
                        ),
                      ],
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
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
    return '${local.day}.${local.month} ${local.hour}:${local.minute.toString().padLeft(2,'0')}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green.shade700;
      case 'rejected': return Colors.red.shade700;
      case 'pending': return Colors.orange.shade700;
      case 'completed': return Colors.blueGrey;
      case 'cancelled': return Colors.grey; // İptaller gri
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.check;
      case 'rejected': return Icons.close;
      case 'pending': return Icons.hourglass_top;
      case 'completed': return Icons.done_all;
      case 'cancelled': return Icons.block;
      default: return Icons.info;
    }
  }
}