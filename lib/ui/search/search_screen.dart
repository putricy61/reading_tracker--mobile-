// [TAHAP 1] BARU: halaman Search (placeholder).
import 'package:flutter/material.dart';

import '../core/placeholder_page.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // [TAHAP 1] Placeholder.
    // [TAHAP 2] AKAN DIUBAH: SearchBar + SegmentedButton (min. 3 kategori) + SearchViewModel.
    return const PlaceholderPage(
      title: 'Search',
      icon: Icons.search_rounded,
      note: 'Pencarian judul/penulis dan SegmentedButton kategori akan tampil di sini.',
    );
  }
}
