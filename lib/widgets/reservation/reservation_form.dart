// lib/widgets/reservation/reservation_form.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/place_model.dart';
import '../../data/reservation_model.dart';
import '../../data/reservation_repo.dart';
import '../../auth/auth_service.dart';

class ReservationForm extends StatefulWidget {
  final PlaceModel place;

  const ReservationForm({super.key, required this.place});

  @override
  State<ReservationForm> createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final _repo = ReservationRepo();
  
  // Başlangıç değerini 'late' yaptık çünkü initState'de atayacağız
  late DateTime _selectedDate;
  
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Uygulama açıldığında varsayılan tarih "Yarın" olsun
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    // En erken seçilebilecek tarih: Yarın
    final tomorrow = now.add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: tomorrow, // Bugünü ve geçmişi devre dışı bırakır
      lastDate: now.add(const Duration(days: 30)), // Örn: 30 gün sonrasına kadar
    );
    
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() => isStart ? _startTime = picked : _endTime = picked);
    }
  }

  Future<void> _handleSave() async {
    // Validasyon: Bitiş saati Başlangıçtan sonra olmalı
    final startVal = _startTime.hour * 60 + _startTime.minute;
    final endVal = _endTime.hour * 60 + _endTime.minute;

    if (endVal <= startVal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitiş saati başlangıçtan sonra olmalı.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // DateTime nesnelerini oluştur (Tarih + Saat)
      final startDt = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _startTime.hour, _startTime.minute,
      );
      final endDt = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _endTime.hour, _endTime.minute,
      );

      final reservation = ReservationModel(
        placeId: widget.place.id,
        userId: AuthService.instance.userId,
        startTs: startDt,
        endTs: endDt,
      );

      await _repo.createReservation(reservation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rezervasyon başarıyla oluşturuldu!')),
        );
        context.pop(); // Formu kapat, önceki ekrana dön
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tarih Seçimi
        ListTile(
          title: const Text('Tarih'),
          subtitle: Text('${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}'),
          trailing: const Icon(Icons.calendar_today),
          onTap: _isLoading ? null : _pickDate,
          tileColor: Colors.grey.withAlpha(25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        const SizedBox(height: 16),
        
        // Saat Seçimi (Yan yana)
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Başlangıç'),
                subtitle: Text(_startTime.format(context)),
                onTap: _isLoading ? null : () => _pickTime(true),
                tileColor: Colors.grey.withAlpha(25),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ListTile(
                title: const Text('Bitiş'),
                subtitle: Text(_endTime.format(context)),
                onTap: _isLoading ? null : () => _pickTime(false),
                tileColor: Colors.grey.withAlpha(25),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        
        const Spacer(),
        
        // Kaydet Butonu
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Rezervasyonu Onayla'),
          ),
        ),
      ],
    );
  }
}