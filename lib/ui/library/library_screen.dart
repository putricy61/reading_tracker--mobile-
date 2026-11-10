// [TAHAP 1] BARU: halaman Library / Checklist (placeholder).
import 'package:flutter/material.dart';

import '../core/placeholder_page.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // [TAHAP 1] Placeholder.
    // [TAHAP 3] AKAN DIUBAH: CheckboxListTile (Sedang Dibaca -> Tamat) + LibraryViewModel.
    return const PlaceholderPage(
      title: 'Library',
      icon: Icons.local_library_rounded,
      note: 'Daftar ebook dengan checklist Sedang Dibaca dan Tamat akan tampil di sini.',
    );
  }
}
