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
  // Veri depoları
  final SensorRepository _sensorRepo = SensorRepository();
  final ForecastRepo _forecastRepo = ForecastRepo();
  
  Timer? _timer;

  // Veriler (Varsayılan boş)
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
    // Başlangıçta tüm verileri getir
    _refreshData();
    
    // Sensör verisini 5 saniyede bir güncelle
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      // En güncel sensör verisini al
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
      // Veri kaynaklarından güncel bilgileri al
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
      appBar: AppBar(title: Text(widget.place.name)),
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
                          // Verileri sayfalayıcıya aktar
                          Expanded(
                            child: RoomDetailPager(
                              roomId: widget.place.id,
                              sensorData: _currentSensorData,
                              forecasts: _currentForecasts,
                            ),
                          ),
                          
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
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 30), 
      child: SizedBox(
        height: 48, 
        width: double.infinity,
        child: FilledButton(
          onPressed: () => context.push('/reservation/create', extra: widget.place),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF7E57C2), 
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 8),
              Text(
                'Rezervasyon Oluştur',
                style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}