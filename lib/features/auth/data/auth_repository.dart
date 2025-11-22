// lib/features/auth/data/auth_repository.dart
import 'package:pocketbase/pocketbase.dart';
import '../../../core/pb_client.dart';

class AuthRepository {
  final PocketBase _pb = PbClient.I.client;

  // Nullable döndürelim ki login_screen'de ?. kullanabilelim
  Future<RecordAuth?> login(String email, String password) async {
    final authData = await _pb.collection('users').authWithPassword(
          email,
          password,
        );
    return authData;
  }

  bool get isLoggedIn => _pb.authStore.isValid;

  RecordModel? get currentUser => _pb.authStore.model;

  void logout() {
    _pb.authStore.clear();
  }
}
