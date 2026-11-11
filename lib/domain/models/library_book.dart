// [TAHAP 2] BARU: model DATA AKSI = ebook yang tersimpan di Library.
// Status checklist disimpan di isCompleted (dipakai CheckboxListTile di Tahap 3).
class LibraryBook {
  static const String sourceCatalog = 'catalog'; // dari katalog aplikasi
  static const String sourcePdf = 'pdf'; // PDF dari penyimpanan hp

  final String id;
  final String? bookId; // id BookInfo; null jika berasal dari PDF
  final String title;
  final String author;
  final String source;
  final int lastPage;
  final int totalPages;
  final bool isCompleted;

  const LibraryBook({
    required this.id,
    required this.bookId,
    required this.title,
    required this.author,
    required this.source,
    required this.lastPage,
    required this.totalPages,
    required this.isCompleted,
  });

  /// Progres membaca 0.0 - 1.0
  double get progress =>
      totalPages == 0 ? 0 : (lastPage / totalPages).clamp(0.0, 1.0).toDouble();

  factory LibraryBook.fromJson(Map<String, dynamic> json) {
    return LibraryBook(
      id: json['id'] as String,
      bookId: json['bookId'] as String?,
      title: json['title'] as String,
      author: json['author'] as String,
      source: json['source'] as String,
      lastPage: json['lastPage'] as int,
      totalPages: json['totalPages'] as int,
      isCompleted: json['isCompleted'] as bool,
    );
  }

  // Model data aksi wajib punya copyWith() (syarat dosen no. 9)
  LibraryBook copyWith({
    String? id,
    String? bookId,
    String? title,
    String? author,
    String? source,
    int? lastPage,
    int? totalPages,
    bool? isCompleted,
  }) {
    return LibraryBook(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      source: source ?? this.source,
      lastPage: lastPage ?? this.lastPage,
      totalPages: totalPages ?? this.totalPages,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
