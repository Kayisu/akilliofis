import 'package:flutter/foundation.dart'; // ChangeNotifier için gerekli
import 'package:pocketbase/pocketbase.dart';
import '../core/pb_client.dart';

// Router'ın dinleyebilmesi için ChangeNotifier ekledik
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;

  AuthService._internal();

  final PocketBase _pb = PbClient.I.client;

  bool get isAuthenticated => _pb.authStore.isValid;
  String get userId => _pb.authStore.model?.id ?? '';
  
  RecordModel? get currentUser => _pb.authStore.model is RecordModel ? _pb.authStore.model as RecordModel : null;

  bool get isAdmin {
    if (!isAuthenticated) return false;
    return _pb.authStore.model is RecordModel 
        ? (_pb.authStore.model as RecordModel).getBoolValue('isAdmin') 
        : false;
  }

  Future<RecordAuth> login(String email, String password) async {
    final auth = await _pb.collection('users').authWithPassword(email, password);
    notifyListeners(); // Router'ı haberdar et
    return auth;
  }

  Future<RecordModel> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'passwordConfirm': password,
      'fullName': fullName,
      'emailVisibility': false,
      'verified': false,
      'isAdmin': false,
    };

    try {
      return await _pb.collection('users').create(body: body);
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('email') && 
          (errorString.contains('unique') || errorString.contains('taken') || errorString.contains('validation'))) {
        throw Exception('EMAIL_ALREADY_EXISTS');
      }
      rethrow;
    }
  }

  Future<RecordModel> updateProfile({required String fullName}) async {
    final body = <String, dynamic>{
      'fullName': fullName,
    };
    final record = await _pb.collection('users').update(userId, body: body);
    notifyListeners(); // Profil güncellendiğinde arayüzü yenile
    return record;
  }

  void logout() {
    _pb.authStore.clear();
    notifyListeners(); // Router'ı haberdar et (Giriş ekranına yönlendirir)
  }
}