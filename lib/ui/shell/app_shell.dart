// [TAHAP 1] BARU: cangkang aplikasi = satu NavigationBar berisi 4 halaman (syarat dosen no. 4).
// [TAHAP 3 - UBAH] Ikon Library kini punya Badge jumlah ebook "Sedang Dibaca" yang
// ikut berubah saat checklist dicentang (syarat dosen no. 5).
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/library_book_repository.dart';
import '../core/app_colors.dart';
import '../core/glass_background.dart';
import '../home/home_screen.dart';
import '../library/library_screen.dart';
import '../reading/reading_screen.dart';
import '../search/search_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  // IndexedStack mempertahankan state tiap tab saat berpindah.
  static const _pages = <Widget>[
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    ReadingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        // extendBody: konten berjalan di bawah bar kaca (efek blur terlihat)
        extendBody: true,
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: _GlassNavBar(
          selectedIndex: _index,
          onSelected: (i) => setState(() => _index = i),
          // [TAHAP 3 - BARU] repository dikirim agar badge bisa diamati
          libraryRepository: context.read<LibraryBookRepository>(),
        ),
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({
    required this.selectedIndex,
    required this.onSelected,
    required this.libraryRepository,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final LibraryBookRepository libraryRepository;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        // bar "melayang" ala iOS
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.glassBorder),
              ),
              // [TAHAP 3 - BARU] ListenableBuilder: bar dibangun ulang tiap Library berubah
              child: ListenableBuilder(
                listenable: libraryRepository,
                builder: (context, _) {
                  final count = libraryRepository.inProgressCount;
                  return NavigationBar(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onSelected,
                    height: 68,
                    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                    destinations: [
                      const NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home_rounded),
                        label: 'Beranda',
                      ),
                      const NavigationDestination(
                        icon: Icon(Icons.search_rounded),
                        selectedIcon: Icon(Icons.search_rounded),
                        label: 'Search',
                      ),
                      // [TAHAP 3 - UBAH] ikon Library dibungkus Badge
                      NavigationDestination(
                        icon: Badge(
                          isLabelVisible: count > 0,
                          label: Text('$count'),
                          backgroundColor: AppColors.accent,
                          child: const Icon(Icons.local_library_outlined),
                        ),
                        selectedIcon: Badge(
                          isLabelVisible: count > 0,
                          label: Text('$count'),
                          backgroundColor: AppColors.accent,
                          child: const Icon(Icons.local_library_rounded),
                        ),
                        label: 'Library',
                      ),
                      const NavigationDestination(
                        icon: Icon(Icons.fiber_manual_record_outlined),
                        selectedIcon: Icon(Icons.fiber_manual_record_rounded),
                        label: 'Rekam',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
