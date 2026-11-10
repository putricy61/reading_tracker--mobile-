// [TAHAP 1] BARU: halaman Beranda (placeholder).
import 'package:flutter/material.dart';

import '../core/placeholder_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // [TAHAP 1] Placeholder.
    // [TAHAP 2] AKAN DIUBAH: ganti dengan ListenableBuilder + HomeViewModel
    //           (kalender, rekomendasi ebook, daftar Sedang Dibaca, ikon profil).
    return const PlaceholderPage(
      title: 'Beranda',
      icon: Icons.home_rounded,
      note: 'Kalender aktivitas, rekomendasi ebook, dan daftar Sedang Dibaca akan tampil di sini.',
    );
  }
}
