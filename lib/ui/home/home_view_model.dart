// [TAHAP 2] BARU: ViewModel Beranda. Menggabungkan data dari BEBERAPA Repository
// (katalog + Library + sesi) sesuai syarat dosen no. 6.
import 'package:flutter/foundation.dart';

import '../../data/repositories/book_info_repository.dart';
import '../../data/repositories/library_book_repository.dart';
import '../../data/repositories/reading_session_repository.dart';
import '../../domain/models/book_info.dart';
import '../../domain/models/library_book.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required BookInfoRepository bookRepository,
    required LibraryBookRepository libraryRepository,
    required ReadingSessionRepository sessionRepository,
  })  : _books = bookRepository,
        _library = libraryRepository,
        _sessions = sessionRepository {
    // Repository data aksi berubah (tambah/checklist) -> Beranda ikut diperbarui.
    _library.addListener(notifyListeners);
    // [TAHAP 4 - BARU] Sesi baru disimpan -> kalender Beranda ikut diperbarui.
    _sessions.addListener(notifyListeners);
  }

  final BookInfoRepository _books;
  final LibraryBookRepository _library;
  final ReadingSessionRepository _sessions;

  // Setiap ViewModel punya isLoading, error, dan load() (syarat dosen no. 2)
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BookInfo> get recommendations => _books.cached.take(6).toList();
  List<LibraryBook> get inProgress => _library.inProgress;

  int minutesOn(DateTime day) => _sessions.minutesOn(day);
  BookInfo? findBook(String? id) => id == null ? null : _books.findById(id);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await Future.wait<Object?>([
        _books.getBooks(),
        _library.load(),
        _sessions.getSessions(),
      ]);
    } catch (e) {
      _error = 'Gagal memuat data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _library.removeListener(notifyListeners);
    _sessions.removeListener(notifyListeners); // [TAHAP 4 - BARU]
    super.dispose();
  }
}
