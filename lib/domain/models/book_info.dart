// [TAHAP 2] BARU: model DATA UTAMA = informasi ebook di katalog aplikasi.
class BookInfo {
  // Semua field final (syarat dosen no. 9)
  final String id;
  final String title;
  final String author;
  final String genre; // Fiksi / Nonfiksi / Pendidikan
  final String synopsis;
  final int year;
  final int pages;
  final int coverColor; // warna sampul (nilai ARGB) karena belum memakai gambar

  const BookInfo({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.synopsis,
    required this.year,
    required this.pages,
    required this.coverColor,
  });

  // Wajib ada fromJson() (syarat dosen no. 9)
  factory BookInfo.fromJson(Map<String, dynamic> json) {
    return BookInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      genre: json['genre'] as String,
      synopsis: json['synopsis'] as String,
      year: json['year'] as int,
      pages: json['pages'] as int,
      coverColor: json['coverColor'] as int,
    );
  }
}
