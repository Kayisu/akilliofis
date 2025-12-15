import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../auth/auth_service.dart';
import '../screens/home_shell.dart';
import '../screens/room_detail_screen.dart';
import '../screens/profile_edit_screen.dart';
import '../screens/reservation_create.dart';
import '../data/place_model.dart';
import '../screens/room_list_screen.dart'; // Oda listesi ekranı için gerekli import
import '../screens/admin/admin_places.dart'; 
import '../screens/admin/admin_shell.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_reservations.dart'; 

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: AuthService.instance,
    
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // --- Normal kullanıcı rotaları ---
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeShell(),
      ),
      
      // --- Oda seçim ekranı rotası ---
      // Bu rota sayesinde '/rooms' yönlendirmesi çalışır
      GoRoute(
        path: '/rooms',
        builder: (context, state) => const RoomListScreen(),
      ),
      
      // --- Detay sayfaları ---
      GoRoute(
        path: '/room-detail',
        builder: (context, state) {
          if (state.extra is PlaceModel) {
            return RoomDetailScreen(place: state.extra as PlaceModel);
          }
          return const Scaffold(body: Center(child: Text("Hatalı Oda Verisi")));
        },
      ),
      GoRoute(
        path: '/reservation/create',
        builder: (context, state) {
          final place = state.extra as PlaceModel?;
          return ReservationCreate(place: place);
        },
      ),
      GoRoute(
        path: '/profile-edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),

      // --- Yönetici paneli rotaları ---
      ShellRoute(
        builder: (context, state, child) {
          return AdminShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/admin/places',
            builder: (context, state) => const AdminPlacesScreen(),
          ),
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) {
              final place = state.extra as PlaceModel?;
              return AdminDashboard(place: place);
            },
          ),
          GoRoute(
            path: '/admin/reservations',
            builder: (context, state) => const AdminReservations(),
          ),
        ],
      ),
    ],

    redirect: (context, state) {
      final isLoggedIn = AuthService.instance.isAuthenticated;
      final isAdmin = AuthService.instance.isAdmin;
      
      final location = state.uri.toString();
      final isLoggingIn = location == '/login';
      final isRegistering = location == '/register';
      final isGoingToAdmin = location.startsWith('/admin');

      if (!isLoggedIn && !isLoggingIn && !isRegistering) return '/login';

      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        return isAdmin ? '/admin/places' : '/home';
      }

      if (isLoggedIn && !isAdmin && isGoingToAdmin) {
        return '/home';
      }

      return null;
    },
  );
}