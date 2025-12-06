import 'dart:math';
import '../data/sensor_model.dart'; // Model dosyanı import et

class SensorRepository {
  // Simülasyon için başlangıç değerleri
  double _temp = 24.0;
  double _hum = 40.0;
  int _co2 = 700;

  // Veriyi getiren fonksiyon
  // İleride buradaki 'Future' sayesinde internetten çekiyormuş gibi bekletebiliriz
  Future<SensorData> getSensorData() async {
    final random = Random();

    // Simülasyon Mantığı: Eski değere göre biraz artır/azalt
    _temp += (random.nextDouble() * 2 - 1); // +/- 1 derece
    _hum += (random.nextDouble() * 4 - 2); // +/- 2 nem
    _co2 += (random.nextInt(50) - 25); // +/- 25 ppm

    // Veriyi paketleyip geri gönderiyoruz (Model formatında)
    return SensorData(
      temperature: double.parse(_temp.toStringAsFixed(1)),
      humidity: double.parse(_hum.toStringAsFixed(1)),
      co2: _co2,
      gas: 75, // Sabit örnek
      comfortScore: 0.6 + (random.nextDouble() * 0.2),
    );
  }
}
