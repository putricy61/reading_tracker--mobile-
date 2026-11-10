// [TAHAP 1] BARU: halaman Rekam (fitur buatan sendiri, placeholder).
import 'package:flutter/material.dart';

import '../core/placeholder_page.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // [TAHAP 1] Placeholder.
    // [TAHAP 4] AKAN DIUBAH: ReadingViewModel + daftar ReadingSession + form rekam sesi.
    // [TAHAP 5] AKAN DITAMBAH: visualisasi jalur buku & ekspor ke galeri.
    return const PlaceholderPage(
      title: 'Rekam',
      icon: Icons.fiber_manual_record_rounded,
      note: 'Rekam sesi buku fisik dan ebook, plus visualisasi jalur membaca, akan tampil di sini.',
    );
  }
}
