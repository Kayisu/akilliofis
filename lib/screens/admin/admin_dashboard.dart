import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/place_model.dart';

class AdminDashboard extends StatelessWidget {
  // Artık dashboard bir odaya bağlı
  final PlaceModel? place;

  const AdminDashboard({super.key, this.place});

  @override
  Widget build(BuildContext context) {
    // Eğer odayla gelmediyse (direkt URL erişimi vb.) listeye geri atalım veya uyarı verelim
    if (place == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Ofis seçimi yapılmadı.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/admin/places'),
                child: const Text('Ofis Listesine Dön'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${place!.name} - Özet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/places'), // Listeye dönüş butonu
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // KPI KARTLARI
          const Text('Anlık Durum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              // Veriler gelince buraları place.id ile stream'e bağlayacağız
              _buildKpiCard(context, 'Konfor Skoru', '0.85', Icons.sentiment_satisfied_alt, Colors.green),
              _buildKpiCard(context, 'Doluluk', '3/${place!.capacity}', Icons.people_outline, Colors.blue),
              _buildKpiCard(context, 'CO2 Seviyesi', '750 ppm', Icons.air, Colors.orange),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // GRAFİK ALANI
          const Text('Sensör Verileri (Canlı)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withAlpha(50)),
            ),
            child: Center(
              child: Text('${place!.name} için Grafikler Yükleniyor...'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.only(right: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 30),
                  Text(value, style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}