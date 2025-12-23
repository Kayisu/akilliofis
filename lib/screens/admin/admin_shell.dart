//admin_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_service.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  // URL'e bakarak hangi menü elemanının seçili olması gerektiğini hesaplar
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    
    if (location.startsWith('/admin/places') || location.startsWith('/admin/dashboard')) {
      return 0; // Ofisler veya Dashboard
    }
    if (location.startsWith('/admin/reservations')) {
      return 1; // Rezervasyonlar
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    // build metodu her tetiklendiğinde (sayfa değişimi dahil) index yeniden hesaplanır
    final int selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            extended: MediaQuery.of(context).size.width >= 800,
            minExtendedWidth: 200,
            onDestinationSelected: (int index) {
              switch (index) {
                case 0:
                  context.go('/admin/places');
                  break;
                case 1:
                  context.go('/admin/reservations');
                  break;
                case 2:
                  // Çıkış İşlemi
                  AuthService.instance.logout();
                  context.go('/login');
                  break;
              }
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.meeting_room_outlined),
                selectedIcon: Icon(Icons.meeting_room),
                label: Text('Ofisler'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: Text('Rezervasyonlar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.logout, color: Colors.redAccent),
                label: Text('Çıkış', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}