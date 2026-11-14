// [TAHAP 4] BARU: ViewModel fitur khusus Rekam Sesi (memakai data informasi ReadingSession).
// Ini ViewModel yang diuji di test/reading_view_model_test.dart (syarat dosen no. 10).
import 'package:flutter/foundation.dart';

import '../../data/repositories/library_book_repository.dart';
import '../../data/repositories/reading_session_repository.dart';
import '../../domain/models/library_book.dart';
import '../../domain/models/reading_session.dart';

enum ReadingMode { physical, ebook }

class ReadingViewModel extends ChangeNotifier {
  ReadingViewModel({
    required ReadingSessionRepository sessionRepository,
    required LibraryBookRepository libraryRepository,
  })  : _sessions = sessionRepository,
        _library = libraryRepository {
    _sessions.addListener(notifyListeners);
    _library.addListener(notifyListeners);
  }

  final ReadingSessionRepository _sessions;
  final LibraryBookRepository _library;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error; // error saat memuat
  String? _formError; // error validasi / simpan form
  ReadingMode _mode = ReadingMode.physical;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String? get formError => _formError;
  ReadingMode get mode => _mode;

  /// Riwayat sesi, terbaru di depan.
  List<ReadingSession> get sessions => _sessions.cached;

  /// Ebook yang bisa dipilih untuk rekam ebook (semua yang ada di Library).
  List<LibraryBook> get libraryBooks => _library.items;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await Future.wait<Object?>([_sessions.getSessions(), _library.load()]);
    } catch (e) {
      _error = 'Gagal memuat sesi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setMode(ReadingMode value) {
    _mode = value;
    _formError = null;
    notifyListeners();
  }

  /// Rekam buku fisik. Setiap sesi INDEPENDEN: tidak menjumlah progres sesi sebelumnya.
  Future<bool> submitPhysical({
    String title = '',
    required int pagesRead,
    required int totalPages,
    required int durationMinutes,
  }) async {
    if (pagesRead <= 0 || totalPages <= 0 || durationMinutes <= 0) {
      return _fail('Isi halaman dibaca, total halaman, dan durasi dengan angka lebih dari 0.');
    }
    if (pagesRead > totalPages) {
      return _fail('Halaman dibaca tidak boleh melebihi total halaman.');
    }
    return _save(
      ReadingSession(
        id: 'rs_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        durationMinutes: durationMinutes,
        startPage: 0,
        endPage: pagesRead,
        bookTitle: title.trim().isEmpty ? 'Buku fisik' : title.trim(),
        isPhysical: true,
        gestures: const [],
        totalPages: totalPages,
      ),
    );
  }

  /// Rekam ebook. [TAHAP 5] AKAN DIUBAH: nilai diisi otomatis dari pembaca (timer + gestur).
  Future<bool> submitEbook({
    required LibraryBook? book,
    required int startPage,
    required int endPage,
    required int durationMinutes,
    required List<String> gestures,
  }) async {
    if (book == null) return _fail('Pilih ebook dari Library terlebih dahulu.');
    if (startPage < 0 || endPage <= 0 || durationMinutes <= 0) {
      return _fail('Isi halaman awal, halaman akhir, dan durasi dengan angka yang valid.');
    }
    if (endPage <= startPage) {
      return _fail('Halaman akhir harus lebih besar dari halaman awal.');
    }
    if (endPage > book.totalPages) {
      return _fail('Halaman akhir melebihi total halaman (${book.totalPages}).');
    }
    return _save(
      ReadingSession(
        id: 'rs_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        durationMinutes: durationMinutes,
        startPage: startPage,
        endPage: endPage,
        bookTitle: book.title,
        isPhysical: false,
        gestures: List<String>.from(gestures),
        totalPages: book.totalPages,
      ),
      book: book,
    );
  }

  bool _fail(String message) {
    _formError = message;
    notifyListeners();
    return false;
  }

  Future<bool> _save(ReadingSession session, {LibraryBook? book}) async {
    _isSaving = true;
    _formError = null;
    notifyListeners();
    try {
      await _sessions.addSession(session);
      // Ebook: majukan halaman terakhir di Library (Beranda ikut berubah).
      if (book != null) _library.updateLastPage(book.id, session.endPage);
      return true;
    } catch (e) {
      _formError = 'Gagal menyimpan sesi: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sessions.removeListener(notifyListeners);
    _library.removeListener(notifyListeners);
    super.dispose();
  }
}
