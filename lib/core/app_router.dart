import 'package:flutter/material.dart'; // Widget ve Colors için şart
import 'package:go_router/go_router.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../auth/auth_service.dart';
import '../screens/home_shell.dart';
import '../screens/room_detail_screen.dart';
import '../screens/profile_edit_screen.dart';
import '../screens/reservation_create.dart';
import '../data/place_model.dart';
import '../screens/admin/admin_places.dart'; 
import '../screens/admin/admin_shell.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_reservations.dart'; 

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login', // Başlangıç her zaman login olsun, redirect çözer
    refreshListenable: AuthService.instance, // Artık hata vermez
    
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // --- NORMAL KULLANICI (HomeShell kendi içinde tab yönetiyor) ---
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeShell(),
      ),
      
      // --- DETAY SAYFALARI ---
      GoRoute(
        path: '/room-detail',
        builder: (context, state) {
          // Tip güvenliği için kontrol
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

      // --- ADMIN ROTASI (ShellRoute kullanıyoruz çünkü AdminShell child alıyor) ---
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

      // 1. Giriş yapmamışsa ve Login/Register değilse -> Login
      if (!isLoggedIn && !isLoggingIn && !isRegistering) return '/login';

      // 2. Giriş yapmış ama hala Login/Register sayfalarındaysa
      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        return isAdmin ? '/admin/places' : '/home';
      }

      // 3. Normal kullanıcı Admin'e girmeye çalışırsa -> Home
      if (isLoggedIn && !isAdmin && isGoingToAdmin) {
        return '/home';
      }

      return null; // Değişiklik yok
    },
  );
}