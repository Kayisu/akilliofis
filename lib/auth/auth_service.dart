import 'package:pocketbase/pocketbase.dart';
import '../core/pb_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;

  AuthService._internal();

  final PocketBase _pb = PbClient.I.client;

  bool get isAuthenticated => _pb.authStore.isValid;
  String get userId => _pb.authStore.model?.id ?? '';
  
  // Kullanıcı modeline erişim (RecordModel olarak döner)
  // Kullanıcı verilerine erişmek için: currentUser?.data['fullName'] veya currentUser?.getStringValue('fullName')
  RecordModel? get currentUser => _pb.authStore.model is RecordModel ? _pb.authStore.model as RecordModel : null;

  Future<RecordAuth> login(String email, String password) async {
    return await _pb.collection('users').authWithPassword(email, password);
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
      // PocketBase'den dönen hatayı analiz et
      final errorString = e.toString();
      // Hata mesajı genellikle JSON formatında validation hatalarını içerir
      // "email" ve "unique" veya "taken" gibi anahtar kelimeleri kontrol ediyoruz
      if (errorString.contains('email') && 
          (errorString.contains('unique') || errorString.contains('taken') || errorString.contains('validation'))) {
        throw Exception('EMAIL_ALREADY_EXISTS'); // Özel bir hata kodu fırlatıyoruz
      }
      rethrow;
    }
  }

  bool get isAdmin {
    if (!isAuthenticated) return false;
    return _pb.authStore.model is RecordModel 
        ? (_pb.authStore.model as RecordModel).getBoolValue('isAdmin') 
        : false;
  }

  Future<RecordModel> updateProfile({required String fullName}) async {
    final body = <String, dynamic>{
      'fullName': fullName,
    };
    return await _pb.collection('users').update(userId, body: body);
  }

  void logout() {
    _pb.authStore.clear();
  }
}
