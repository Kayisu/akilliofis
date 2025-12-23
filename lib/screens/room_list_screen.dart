//room_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/place_model.dart';
import '../data/place_repo.dart';
import '../widgets/room_list/room_card.dart';
import '../widgets/home_header.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
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
      body: SafeArea(
        child: Column(
          children: [
            const HomeHeader(),
            Expanded(
              child: FutureBuilder<List<PlaceModel>>(
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
                    return const Center(child: Text('Hiç oda bulunamadı.'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: places.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.3,
                    ),
                    itemBuilder: (context, index) {
                      final place = places[index];
                      return RoomCard(
                        place: place,
                        onTap: () {
                          context.push('/room-detail', extra: place);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
