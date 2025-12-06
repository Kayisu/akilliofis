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
  final PlaceRepo _placeRepo = PlaceRepo();
  late Future<List<PlaceModel>> _placesFuture;

  @override
  void initState() {
    super.initState();
    _placesFuture = _placeRepo.getPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ofis Yönetimi')),
      body: FutureBuilder<List<PlaceModel>>(
        future: _placesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final places = snapshot.data ?? [];
          if (places.isEmpty) {
            return const Center(child: Text('Kayıtlı ofis bulunamadı.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: places.length,
            // Masaüstü/Tablet için grid yapısı
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final place = places[index];
              return _buildAdminRoomCard(context, place);
            },
          );
        },
      ),
    );
  }

  Widget _buildAdminRoomCard(BuildContext context, PlaceModel place) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Admin Dashboard'a odayı parametre olarak gönderiyoruz
          context.go('/admin/dashboard', extra: place);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.meeting_room, size: 32, color: Theme.of(context).colorScheme.primary),
                  if (place.isActive)
                    const Chip(label: Text('Aktif'), backgroundColor: Colors.green, labelStyle: TextStyle(fontSize: 10))
                  else
                    const Chip(label: Text('Pasif'), backgroundColor: Colors.red, labelStyle: TextStyle(fontSize: 10)),
                ],
              ),
              const Spacer(),
              Text(
                place.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Kapasite: ${place.capacity} Kişi',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}