// [TAHAP 2] BARU: ViewModel halaman Search (pencarian + filter kategori).
import 'package:flutter/foundation.dart';

import '../../data/repositories/book_info_repository.dart';
import '../../domain/models/book_info.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel({required BookInfoRepository bookRepository}) : _books = bookRepository;

  final BookInfoRepository _books;

  /// Kategori untuk SegmentedButton (minimal 3, syarat dosen no. 6).
  static const List<String> genres = ['Fiksi', 'Nonfiksi', 'Pendidikan'];

  bool _isLoading = false;
  String? _error;
  String _query = '';
  String? _genre; // null = semua kategori

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedGenre => _genre;
  List<BookInfo> get results => _books.search(query: _query, genre: _genre);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _books.getBooks();
    } catch (e) {
      _error = 'Gagal memuat katalog: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setGenre(String? value) {
    _genre = value;
    notifyListeners();
  }
}
