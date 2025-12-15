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
  
  // Kişi sayısı girişi kontrolcüsü
  final TextEditingController _countController = TextEditingController(text: '1');
  
  late DateTime _selectedDate;
  
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Varsayılan tarih: Yarın
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: tomorrow,
      lastDate: now.add(const Duration(days: 30)),
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
    // 1. Doğrulamalar
    final startVal = _startTime.hour * 60 + _startTime.minute;
    final endVal = _endTime.hour * 60 + _endTime.minute;

    if (endVal <= startVal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitiş saati başlangıçtan sonra olmalı.')),
      );
      return;
    }

    // Kişi sayısı doğrulaması
    final count = int.tryParse(_countController.text);
    if (count == null || count < 1) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir kişi sayısı giriniz.')),
      );
      return;
    }

    // Kapasite kontrolü
    if (count > widget.place.capacity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kişi sayısı odanın kapasitesini (${widget.place.capacity}) aşamaz!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final startDt = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _startTime.hour, _startTime.minute,
      );
      final endDt = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _endTime.hour, _endTime.minute,
      );

      // 2. ÇAKIŞMA KONTROLÜ
      final hasOverlap = await _repo.checkOverlap(widget.place.id, startDt, endDt);
      if (hasOverlap) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu saat aralığı dolu! Lütfen başka bir saat seçin.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return; 
      }

      // 3. Rezervasyon Oluşturma
      final reservation = ReservationModel(
        placeId: widget.place.id,
        userId: AuthService.instance.userId,
        startTs: startDt,
        endTs: endDt,
        attendeeCount: count, // Modele eklenen yeni alan
        // status varsayılan olarak 'pending' gidecek
        // isHidden varsayılan olarak false gidecek
      );

      await _repo.createReservation(reservation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rezervasyon başarıyla oluşturuldu!')),
        );
        context.pop();
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
        // TARİH SEÇİMİ
        ListTile(
          title: const Text('Tarih'),
          subtitle: Text('${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}'),
          trailing: const Icon(Icons.calendar_today),
          onTap: _isLoading ? null : _pickDate,
          tileColor: Colors.grey.withAlpha(25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        const SizedBox(height: 16),
        
        // SAAT SEÇİMİ
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
        const SizedBox(height: 16),

        // YENİ: KİŞİ SAYISI GİRİŞİ
        TextFormField(
          controller: _countController,
          keyboardType: TextInputType.number,
          enabled: !_isLoading,
          decoration: InputDecoration(
            labelText: 'Kişi Sayısı',
            hintText: 'Kaç kişi kullanacak?',
            suffixText: '/ ${widget.place.capacity}', // Kullanıcıya kapasiteyi gösterir
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.people),
            filled: true,
            fillColor: Colors.grey.withAlpha(10),
          ),
        ),

        const Spacer(),
        
        // KAYDET BUTONU
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: _isLoading 
                ? const SizedBox(
                    width: 24, 
                    height: 24, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                : const Text('Rezervasyonu Onayla', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}