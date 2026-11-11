// [TAHAP 2] BARU: model DATA INFORMASI = riwayat sesi membaca (fitur Rekam).
// Di Tahap 2 dipakai untuk kalender Beranda; Tahap 4 dipakai fitur Rekam.
class ReadingSession {
  final String id;
  final DateTime date;
  final int durationMinutes;
  final int startPage;
  final int endPage;
  final String bookTitle;
  final bool isPhysical; // true = buku fisik, false = ebook
  final List<String> gestures; // gestur membaca: swipe / scroll

  const ReadingSession({
    required this.id,
    required this.date,
    required this.durationMinutes,
    required this.startPage,
    required this.endPage,
    required this.bookTitle,
    required this.isPhysical,
    required this.gestures,
  });

  int get pagesRead => endPage - startPage;

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
    );
  }
}
