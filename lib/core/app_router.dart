import 'package:go_router/go_router.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../screens/home_shell.dart';
import '../screens/profile_edit_screen.dart';
import '../screens/room_detail_screen.dart';
import '../auth/auth_service.dart';
import '../data/place_model.dart';
import '../screens/reservation_create.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AuthService.instance.isAuthenticated ? '/home' : '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: '/room-detail',
        builder: (context, state) {
          final place = state.extra as dynamic; 
          return RoomDetailScreen(place: place);
        },
      ),
      GoRoute(
        path: '/profile-edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/reservation/create',
        builder: (context, state) {
          // Gelen 'extra' verisini PlaceModel olarak alıyoruz
          final place = state.extra as PlaceModel?; 
          return ReservationCreate(place: place);
        },
      ),
      
    ],
    redirect: (context, state) {
      final isLoggedIn = AuthService.instance.isAuthenticated;
      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';

      if (!isLoggedIn && !isLoggingIn && !isRegistering) return '/login';
      if (isLoggedIn && (isLoggingIn || isRegistering)) return '/home';

      return null;
    },
  );
}
