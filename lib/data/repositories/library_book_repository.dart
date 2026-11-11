// [TAHAP 2] BARU: Repository data aksi. Memakai ChangeNotifier supaya perubahan
// (tambah ke Library / checklist) langsung memperbarui Beranda dan badge Library
// (syarat dosen no. 5). Dibuat di Tahap 2 karena Beranda butuh daftar "Sedang Dibaca".
import 'package:flutter/foundation.dart';

import '../../domain/models/book_info.dart';
import '../../domain/models/library_book.dart';
import '../services/reading_tracker_service.dart';

class LibraryBookRepository extends ChangeNotifier {
  LibraryBookRepository({required ReadingTrackerService service}) : _service = service;

  final ReadingTrackerService _service;
  List<LibraryBook> _items = const [];
  bool _loaded = false;

  List<LibraryBook> get items => _items;
  List<LibraryBook> get inProgress => _items.where((b) => !b.isCompleted).toList();
  List<LibraryBook> get completed => _items.where((b) => b.isCompleted).toList();

  /// Untuk badge di tab Library (dipakai di Tahap 3).
  int get inProgressCount => inProgress.length;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await _service.fetchLibraryBooks();
    _items = raw.map(LibraryBook.fromJson).toList();
    _loaded = true;
    notifyListeners();
  }

  bool isInLibrary(String bookId) => _items.any((b) => b.bookId == bookId);

  /// Tambah buku katalog ke Library.
  void addFromBook(BookInfo book) {
    if (isInLibrary(book.id)) return;
    _items = [
      ..._items,
      LibraryBook(
        id: 'lb_${DateTime.now().millisecondsSinceEpoch}',
        bookId: book.id,
        title: book.title,
        author: book.author,
        source: LibraryBook.sourceCatalog,
        lastPage: 0,
        totalPages: book.pages,
        isCompleted: false,
      ),
    ];
    notifyListeners();
  }

  /// Dipakai checklist di Tahap 3. Memakai copyWith() lalu memberi tahu pendengar.
  void setCompleted(String id, bool value) {
    _items = [
      for (final b in _items) b.id == id ? b.copyWith(isCompleted: value) : b,
    ];
    notifyListeners();
  }
}
