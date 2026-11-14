// [TAHAP 2] BARU: model DATA INFORMASI = riwayat sesi membaca (fitur Rekam).
// [TAHAP 4 - UBAH] Ditambah field totalPages (opsional), getter percentOfBook, dan toJson().
class ReadingSession {
  final String id;
  final DateTime date;
  final int durationMinutes;
  final int startPage;
  final int endPage;
  final String bookTitle;
  final bool isPhysical; // true = buku fisik, false = ebook
  final List<String> gestures; // gestur membaca: swipe / scroll
  final int? totalPages; // [TAHAP 4 - BARU] total halaman buku (untuk persentase)

  const ReadingSession({
    required this.id,
    required this.date,
    required this.durationMinutes,
    required this.startPage,
    required this.endPage,
    required this.bookTitle,
    required this.isPhysical,
    required this.gestures,
    this.totalPages,
  });

  int get pagesRead => endPage - startPage;

  /// [TAHAP 4 - BARU] Persentase buku yang dibaca pada sesi ini (0.0 - 1.0), null jika tidak diketahui.
  double? get percentOfBook {
    final total = totalPages;
    if (total == null || total <= 0) return null;
    return (pagesRead / total).clamp(0.0, 1.0).toDouble();
  }

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      durationMinutes: json['durationMinutes'] as int,
      startPage: json['startPage'] as int,
      endPage: json['endPage'] as int,
      bookTitle: json['bookTitle'] as String,
      isPhysical: json['isPhysical'] as bool,
      gestures: List<String>.from(json['gestures'] as List),
      totalPages: json['totalPages'] as int?,
    );
  }

  /// [TAHAP 4 - BARU] Dipakai Service saat menyimpan sesi baru.
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'durationMinutes': durationMinutes,
        'startPage': startPage,
        'endPage': endPage,
        'bookTitle': bookTitle,
        'isPhysical': isPhysical,
        'gestures': gestures,
        'totalPages': totalPages,
      };
}
