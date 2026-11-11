// [TAHAP 2] BARU: Service = sumber data SIMULASI memakai Future.delayed()
// (syarat dosen no. 3). Minimal 5 data per jenis (no. 4).
// Service hanya mengembalikan JSON (Map); parsing ke model dilakukan Repository.
class ReadingTrackerService {
  static const Duration _delay = Duration(milliseconds: 700);

  // ---------- DATA UTAMA: katalog ebook (10 buku) ----------
  Future<List<Map<String, dynamic>>> fetchBooks() async {
    await Future.delayed(_delay);
    return _books;
  }

  // ---------- DATA AKSI: isi Library (6 item) ----------
  Future<List<Map<String, dynamic>>> fetchLibraryBooks() async {
    await Future.delayed(_delay);
    return _libraryBooks;
  }

  // ---------- DATA INFORMASI: sesi membaca (8 sesi) ----------
  Future<List<Map<String, dynamic>>> fetchSessions() async {
    await Future.delayed(_delay);

    // Tanggal dibuat relatif terhadap hari ini supaya kalender Beranda selalu terisi.
    String day(int daysAgo) {
      final n = DateTime.now();
      return DateTime(n.year, n.month, n.day - daysAgo, 20).toIso8601String();
    }

    return [
      {
        'id': 's1', 'date': day(0), 'durationMinutes': 45,
        'startPage': 210, 'endPage': 238, 'bookTitle': 'Laskar Pelangi',
        'isPhysical': false, 'gestures': ['scroll', 'swipe'],
      },
      {
        'id': 's2', 'date': day(1), 'durationMinutes': 120,
        'startPage': 100, 'endPage': 160, 'bookTitle': 'Filosofi Teras',
        'isPhysical': false, 'gestures': ['swipe'],
      },
      {
        'id': 's3', 'date': day(2), 'durationMinutes': 60,
        'startPage': 30, 'endPage': 52, 'bookTitle': 'Novel pinjaman perpustakaan',
        'isPhysical': true, 'gestures': <String>[],
      },
      {
        'id': 's4', 'date': day(3), 'durationMinutes': 30,
        'startPage': 60, 'endPage': 75, 'bookTitle': 'Belajar Flutter dari Nol',
        'isPhysical': false, 'gestures': ['scroll'],
      },
      {
        'id': 's5', 'date': day(5), 'durationMinutes': 90,
        'startPage': 1, 'endPage': 70, 'bookTitle': 'Atomic Habits',
        'isPhysical': false, 'gestures': ['swipe', 'scroll'],
      },
      {
        'id': 's6', 'date': day(6), 'durationMinutes': 20,
        'startPage': 12, 'endPage': 20, 'bookTitle': 'Catatan Kuliah PPM',
        'isPhysical': false, 'gestures': ['scroll'],
      },
      {
        'id': 's7', 'date': day(8), 'durationMinutes': 75,
        'startPage': 52, 'endPage': 90, 'bookTitle': 'Novel pinjaman perpustakaan',
        'isPhysical': true, 'gestures': <String>[],
      },
      {
        'id': 's8', 'date': day(9), 'durationMinutes': 110,
        'startPage': 140, 'endPage': 210, 'bookTitle': 'Laskar Pelangi',
        'isPhysical': false, 'gestures': ['swipe'],
      },
    ];
  }

  static const List<Map<String, dynamic>> _books = [
    {
      'id': 'b1', 'title': 'Laskar Pelangi', 'author': 'Andrea Hirata',
      'genre': 'Fiksi', 'year': 2005, 'pages': 529, 'coverColor': 0xFF2E7D5B,
      'synopsis': 'Kisah sepuluh anak di sebuah desa di Belitung yang bersekolah '
          'di gedung reyot, tetapi tidak pernah berhenti bermimpi dan belajar.',
    },
    {
      'id': 'b2', 'title': 'Bumi Manusia', 'author': 'Pramoedya Ananta Toer',
      'genre': 'Fiksi', 'year': 1980, 'pages': 535, 'coverColor': 0xFF8A5A3C,
      'synopsis': 'Seorang pemuda pribumi terpelajar pada masa kolonial jatuh cinta '
          'dan berhadapan dengan ketidakadilan hukum serta adat zamannya.',
    },
    {
      'id': 'b3', 'title': 'Hujan di Hutan Pinus', 'author': 'Nadia Prameswari',
      'genre': 'Fiksi', 'year': 2021, 'pages': 280, 'coverColor': 0xFF2F7F86,
      'synopsis': 'Cerita fiksi tentang seorang penulis yang menyepi di vila hutan '
          'pinus dan menemukan surat-surat lama yang mengubah rencananya.',
    },
    {
      'id': 'b4', 'title': 'Atomic Habits', 'author': 'James Clear',
      'genre': 'Nonfiksi', 'year': 2018, 'pages': 320, 'coverColor': 0xFFB5663A,
      'synopsis': 'Panduan membangun kebiasaan baik lewat perubahan kecil yang '
          'konsisten dan sistem yang mendukungnya.',
    },
    {
      'id': 'b5', 'title': 'Sapiens', 'author': 'Yuval Noah Harari',
      'genre': 'Nonfiksi', 'year': 2011, 'pages': 443, 'coverColor': 0xFF3F6FA8,
      'synopsis': 'Ringkasan sejarah umat manusia, dari masa berburu dan meramu '
          'hingga era sains dan teknologi modern.',
    },
    {
      'id': 'b6', 'title': 'Filosofi Teras', 'author': 'Henry Manampiring',
      'genre': 'Nonfiksi', 'year': 2018, 'pages': 346, 'coverColor': 0xFF5B7A2E,
      'synopsis': 'Pengantar filosofi Stoa untuk menghadapi emosi negatif dan '
          'tekanan hidup sehari-hari.',
    },
    {
      'id': 'b7', 'title': 'Belajar Flutter dari Nol', 'author': 'Tim Liesen',
      'genre': 'Pendidikan', 'year': 2023, 'pages': 260, 'coverColor': 0xFF3B5A8C,
      'synopsis': 'Buku pengantar membuat aplikasi mobile dengan Flutter, dari '
          'widget dasar sampai arsitektur berlapis.',
    },
    {
      'id': 'b8', 'title': 'Dasar Statistika untuk Pemula', 'author': 'Rina Kusuma',
      'genre': 'Pendidikan', 'year': 2020, 'pages': 300, 'coverColor': 0xFF6B4E9B,
      'synopsis': 'Penjelasan konsep statistika deskriptif dan inferensial dengan '
          'contoh sederhana yang dekat dengan kehidupan mahasiswa.',
    },
    {
      'id': 'b9', 'title': 'Pemrograman Dart Praktis', 'author': 'Bayu Anggara',
      'genre': 'Pendidikan', 'year': 2022, 'pages': 240, 'coverColor': 0xFF9A3F52,
      'synopsis': 'Latihan bertahap bahasa Dart: tipe data, kelas, async, hingga '
          'pengelolaan state.',
    },
    {
      'id': 'b10', 'title': 'Menulis Ilmiah dengan Mudah', 'author': 'Sari Wulandari',
      'genre': 'Pendidikan', 'year': 2019, 'pages': 180, 'coverColor': 0xFF7A6A2C,
      'synopsis': 'Langkah praktis menyusun tulisan ilmiah, mulai dari topik, '
          'kerangka, sitasi, sampai penyuntingan akhir.',
    },
  ];

  static const List<Map<String, dynamic>> _libraryBooks = [
    {
      'id': 'lb1', 'bookId': 'b1', 'title': 'Laskar Pelangi',
      'author': 'Andrea Hirata', 'source': 'catalog',
      'lastPage': 238, 'totalPages': 529, 'isCompleted': false,
    },
    {
      'id': 'lb2', 'bookId': 'b4', 'title': 'Atomic Habits',
      'author': 'James Clear', 'source': 'catalog',
      'lastPage': 320, 'totalPages': 320, 'isCompleted': true,
    },
    {
      'id': 'lb3', 'bookId': 'b6', 'title': 'Filosofi Teras',
      'author': 'Henry Manampiring', 'source': 'catalog',
      'lastPage': 160, 'totalPages': 346, 'isCompleted': false,
    },
    {
      'id': 'lb4', 'bookId': 'b7', 'title': 'Belajar Flutter dari Nol',
      'author': 'Tim Liesen', 'source': 'catalog',
      'lastPage': 75, 'totalPages': 260, 'isCompleted': false,
    },
    {
      'id': 'lb5', 'bookId': 'b9', 'title': 'Pemrograman Dart Praktis',
      'author': 'Bayu Anggara', 'source': 'catalog',
      'lastPage': 240, 'totalPages': 240, 'isCompleted': true,
    },
    {
      'id': 'lb6', 'bookId': null, 'title': 'Catatan Kuliah PPM',
      'author': 'Dokumen pribadi', 'source': 'pdf',
      'lastPage': 20, 'totalPages': 48, 'isCompleted': false,
    },
  ];
}
