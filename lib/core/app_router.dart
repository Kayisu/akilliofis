import 'package:go_router/go_router.dart';
//import 'package:flutter/material.dart'; 
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
    initialLocation: AuthService.instance.isAuthenticated
        ? (AuthService.instance.isAdmin ? '/admin/places' : '/home') 
        : '/login',
        
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // --- NORMAL KULLANICI ROTASI ---
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeShell(),
      ),
      // Diğer kullanıcı alt sayfaları (room-detail vb.) burada kalabilir...
      GoRoute(
        path: '/room-detail',
        builder: (context, state) {
          final place = state.extra as dynamic;
          return RoomDetailScreen(place: place);
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

      // --- ADMIN ROTASI (ShellRoute) ---
      ShellRoute(
        builder: (context, state, child) {
          return AdminShell(child: child);
        },
        routes: [
          // YENİ ANA SAYFA: Places
          GoRoute(
            path: '/admin/places',
            builder: (context, state) => const AdminPlacesScreen(),
          ),
          // DASHBOARD (PlaceModel alır)
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) {
              final place = state.extra as PlaceModel?;
              return AdminDashboard(place: place);
            },
          ),
          GoRoute(
            path: '/admin/reservations',
            builder: (context, state) => const AdminReservations(), // Artık gerçek ekranı çağırıyoruz
          ),
        ],
      ),
    ],

    redirect: (context, state) {
      final isLoggedIn = AuthService.instance.isAuthenticated;
      final isAdmin = AuthService.instance.isAdmin;
      
      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';
      final isGoingToAdmin = state.uri.toString().startsWith('/admin');

      // 1. Giriş yapmamışsa Login'e gönder
      if (!isLoggedIn && !isLoggingIn && !isRegistering) return '/login';

      // 2. Giriş yapmışsa ve Login/Register sayfasındaysa yönlendir
      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        // BURAYI DÜZELTTİK: Admin ise Places'a, değilse Home'a
        return isAdmin ? '/admin/places' : '/home';
      }

      // 3. Yetki Kontrolü: Normal kullanıcı Admin sayfasına girmeye çalışırsa
      if (isLoggedIn && !isAdmin && isGoingToAdmin) {
        return '/home';
      }

      // 4. Yetki Kontrolü: Admin normal anasayfaya girmeye çalışırsa
      // (Eğer admin mobildeki arayüzü de görsün derseniz burayı silebilirsiniz)
      if (isLoggedIn && isAdmin && state.uri.toString() == '/home') {
        return '/admin/places'; // Dashboard değil Places'a atıyoruz
      }

      return null;
    },
  );
}