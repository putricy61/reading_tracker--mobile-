// [TAHAP 2] BARU: Repository data utama (katalog ebook).
import '../../domain/models/book_info.dart';
import '../services/reading_tracker_service.dart';

class BookInfoRepository {
  BookInfoRepository({required ReadingTrackerService service}) : _service = service;

  final ReadingTrackerService _service;
  List<BookInfo> _cache = const [];

  /// Data yang sudah dimuat (kosong sebelum getBooks() selesai).
  List<BookInfo> get cached => _cache;

  Future<List<BookInfo>> getBooks() async {
    // Ambil dari Service hanya sekali, selanjutnya pakai cache.
    if (_cache.isEmpty) {
      final raw = await _service.fetchBooks();
      _cache = raw.map(BookInfo.fromJson).toList();
    }
    return _cache;
  }

  BookInfo? findById(String id) {
    for (final b in _cache) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// Cari berdasarkan judul/penulis dan (opsional) genre.
  List<BookInfo> search({String query = '', String? genre}) {
    final q = query.trim().toLowerCase();
    return _cache.where((b) {
      final matchGenre = genre == null || b.genre == genre;
      final matchQuery = q.isEmpty ||
          b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q);
      return matchGenre && matchQuery;
    }).toList();
  }

  /// Buku serupa = genre yang sama, selain buku itu sendiri.
  List<BookInfo> similarTo(BookInfo book) {
    return _cache.where((b) => b.genre == book.genre && b.id != book.id).toList();
  }
}
