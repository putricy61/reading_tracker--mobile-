// [TAHAP 2] BARU: Repository data informasi (riwayat sesi membaca).
// [TAHAP 4 - UBAH] Kini ChangeNotifier + method addSession(), supaya kalender
// Beranda dan riwayat di halaman Rekam langsung ikut berubah saat sesi disimpan.
import 'package:flutter/foundation.dart';

import '../../domain/models/reading_session.dart';
import '../services/reading_tracker_service.dart';

class ReadingSessionRepository extends ChangeNotifier {
  ReadingSessionRepository({required ReadingTrackerService service}) : _service = service;

  final ReadingTrackerService _service;
  List<ReadingSession> _cache = const [];

  /// Urutan: sesi terbaru di depan.
  List<ReadingSession> get cached => _cache;

  Future<List<ReadingSession>> getSessions() async {
    if (_cache.isEmpty) {
      final raw = await _service.fetchSessions();
      _cache = raw.map(ReadingSession.fromJson).toList();
      notifyListeners();
    }
    return _cache;
  }

  /// [TAHAP 4 - BARU] Simpan sesi baru (diletakkan paling depan).
  Future<void> addSession(ReadingSession session) async {
    await _service.saveSession(session.toJson());
    _cache = [session, ..._cache];
    notifyListeners();
  }

  /// Total menit membaca pada satu tanggal (untuk kalender Beranda).
  int minutesOn(DateTime day) {
    var total = 0;
    for (final s in _cache) {
      if (s.date.year == day.year && s.date.month == day.month && s.date.day == day.day) {
        total += s.durationMinutes;
      }
    }
    return total;
  }
}
