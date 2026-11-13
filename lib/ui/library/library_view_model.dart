// [TAHAP 3] BARU: ViewModel halaman Library (Sedang Dibaca / Tamat + checklist).
import 'package:flutter/foundation.dart';

import '../../data/repositories/book_info_repository.dart';
import '../../data/repositories/library_book_repository.dart';
import '../../domain/models/library_book.dart';

class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel({
    required LibraryBookRepository libraryRepository,
    required BookInfoRepository bookRepository,
  })  : _library = libraryRepository,
        _books = bookRepository {
    // Checklist di mana pun berubah -> halaman Library ikut diperbarui.
    _library.addListener(notifyListeners);
  }

  final LibraryBookRepository _library;
  final BookInfoRepository _books;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<LibraryBook> get inProgress => _library.inProgress;
  List<LibraryBook> get completed => _library.completed;

  /// Warna sampul diambil dari katalog; PDF (tanpa bookId) memakai warna default.
  int coverColorOf(LibraryBook item) {
    final book = item.bookId == null ? null : _books.findById(item.bookId!);
    return book?.coverColor ?? 0xFF1B6B45;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await Future.wait<Object?>([_library.load(), _books.getBooks()]);
    } catch (e) {
      _error = 'Gagal memuat Library: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dipanggil CheckboxListTile. Mengubah isCompleted lewat repository.
  void setCompleted(LibraryBook item, bool value) {
    _library.setCompleted(item.id, value);
  }

  @override
  void dispose() {
    _library.removeListener(notifyListeners);
    super.dispose();
  }
}
