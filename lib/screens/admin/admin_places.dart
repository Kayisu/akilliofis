//admin_places.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/place_model.dart';
import '../../data/place_repo.dart';

class AdminPlacesScreen extends StatefulWidget {
  const AdminPlacesScreen({super.key});

  @override
  State<AdminPlacesScreen> createState() => _AdminPlacesScreenState();
}

class _AdminPlacesScreenState extends State<AdminPlacesScreen> {
  final _repo = PlaceRepo();
  late Future<List<PlaceModel>> _future;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _future = _repo.getPlaces();
    });
  }

  // --- EKLEME & DÜZENLEME PENCERESİ ---
  Future<void> _showEditor(PlaceModel? place) async {
    final isEditing = place != null;
    final nameCtrl = TextEditingController(text: place?.name ?? '');
    final capCtrl = TextEditingController(text: place?.capacity.toString() ?? '1');
    bool isActive = place?.isActive ?? true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Odayı Düzenle' : 'Yeni Oda Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Oda Adı', hintText: 'Örn: Toplantı Odası 1'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kapasite', suffixText: 'Kişi'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Aktif mi?'),
                value: isActive,
                onChanged: (val) {
                  setDialogState(() => isActive = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal', style: TextStyle(color: Colors.grey)),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final cap = int.tryParse(capCtrl.text) ?? 1;

                if (name.isEmpty) return;

                try {
                  final newPlace = PlaceModel(
                    id: place?.id ?? '',
                    name: name,
                    capacity: cap,
                    isActive: isActive,
                  );

                  if (isEditing) {
                    await _repo.updatePlace(newPlace);
                  } else {
                    await _repo.createPlace(newPlace);
                  }

                  if (mounted) {
                    if (ctx.mounted) Navigator.pop(ctx);
                    _refreshList();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? 'Güncellendi' : 'Oluşturuldu')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
                  }
                }
              },
              child: Text(isEditing ? 'Kaydet' : 'Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteItem(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silmek istiyor musun?'),
        content: const Text('Oda artık listelerde görünmeyecek.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hayır')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Evet, Sil', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _repo.deletePlace(id);
        _refreshList();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silindi.')));
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofis Yönetimi'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(null),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<PlaceModel>>(
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
            return const Center(
              child: Text('Henüz hiç oda eklenmemiş.\nSağ alttan ekleyebilirsin.', textAlign: TextAlign.center),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final place = list[index];
              return Card(
                color: place.isActive ? null : Theme.of(context).cardColor.withAlpha(128),
                child: ListTile(
                  // DÜZELTME BURADA: Sadece aktifse Dashboard'a git, değilse null (tıklanamaz)
                  onTap: place.isActive ? () {
                    context.push('/admin/dashboard', extra: place);
                  } : null,
                  
                  leading: CircleAvatar(
                    backgroundColor: place.isActive ? Colors.green.withAlpha(50) : Colors.grey.withAlpha(50),
                    child: Icon(Icons.meeting_room, color: place.isActive ? Colors.green : Colors.grey),
                  ),
                  title: Text(
                    place.name, 
                    style: TextStyle(
                      decoration: place.isActive ? null : TextDecoration.lineThrough,
                      color: place.isActive ? null : Colors.grey,
                    )
                  ),
                  subtitle: Text('${place.capacity} Kişilik Kapasite'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _showEditor(place),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteItem(place.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}