// [TAHAP 2] BARU: Repository data informasi (riwayat sesi membaca).
// [TAHAP 4] AKAN DITAMBAH: method untuk menyimpan sesi baru dari fitur Rekam.
import '../../domain/models/reading_session.dart';
import '../services/reading_tracker_service.dart';

class ReadingSessionRepository {
  ReadingSessionRepository({required ReadingTrackerService service}) : _service = service;

  final ReadingTrackerService _service;
  List<ReadingSession> _cache = const [];

  List<ReadingSession> get cached => _cache;

  Future<List<ReadingSession>> getSessions() async {
    if (_cache.isEmpty) {
      final raw = await _service.fetchSessions();
      _cache = raw.map(ReadingSession.fromJson).toList();
    }
    return _cache;
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
