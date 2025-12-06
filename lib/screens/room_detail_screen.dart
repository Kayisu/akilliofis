import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/place_model.dart';
import '../data/sensor_model.dart';
import '../data/forecast_model.dart';
import '../data/sensor_repo.dart';
import '../data/forecast_repo.dart';
import '../widgets/room_detail/room_detail_pager.dart';

class RoomDetailScreen extends StatefulWidget {
  final PlaceModel place;

  const RoomDetailScreen({super.key, required this.place});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  // Repolar
  final SensorRepository _sensorRepo = SensorRepository();
  final ForecastRepo _forecastRepo = ForecastRepo();
  
  Timer? _timer;

  // Veriler
  SensorData _currentSensorData = SensorData.empty();
  List<ForecastModel> _currentForecasts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startLiveUpdate(); 
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLiveUpdate() {
    _refreshData();
    // 5 saniyede bir sadece sensör verisini güncelle
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final sensor = await _sensorRepo.getLatestSensorData(widget.place.id);
      if (mounted) {
        setState(() {
          _currentSensorData = sensor;
        });
      }
    });
  }

  Future<void> _refreshData() async {
    try {
      final results = await Future.wait([
        _sensorRepo.getLatestSensorData(widget.place.id),
        _forecastRepo.getWeeklyForecasts(widget.place.id),
      ]);

      if (mounted) {
        setState(() {
          _currentSensorData = results[0] as SensorData;
          _currentForecasts = results[1] as List<ForecastModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Veri yenileme hatası: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... AppBar aynı ...
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB39DDB)))
          : LayoutBuilder(
              builder: (context, constraints) {
                return RefreshIndicator(
                  onRefresh: _refreshData,
                  color: const Color(0xFFB39DDB),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: constraints.maxHeight, 
                      child: Column(
                        children: [
                          // Pager
                          Expanded(
                            child: RoomDetailPager(
                              roomId: widget.place.id,
                              sensorData: _currentSensorData,
                              forecasts: _currentForecasts,
                            ),
                          ),
                          
                          // ZARİF VE MİNİMAL BUTON
                          _buildMinimalButton(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMinimalButton(BuildContext context) {
    return Padding(
      // Kenarlardan daha fazla boşluk bırakarak butonu küçültüyoruz
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 30), 
      child: SizedBox(
        height: 48, // Yüksekliği azalttık (Önceki 64'tü)
        width: double.infinity,
        child: FilledButton(
          onPressed: () => context.push('/reservation/create', extra: widget.place),
          style: FilledButton.styleFrom(
            // Göz yormayan, mat ve şık bir Lila/Mor tonu
            backgroundColor: const Color(0xFF7E57C2), 
            foregroundColor: Colors.white,
            elevation: 0, // Gölgeyi kaldırdık (Düz tasarım)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24), // Tam yuvarlak kenarlar
            ),
            // Basınca hafif bir renk değişimi (Splash)
            overlayColor: Colors.white.withAlpha(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add, size: 18), // Çok minimal bir ikon
              SizedBox(width: 8),
              Text(
                'Rezervasyon Oluştur', // Normal yazım (Bağırmayan font)
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500, // Medium kalınlık
                  letterSpacing: 0.5, // Hafif aralık
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}