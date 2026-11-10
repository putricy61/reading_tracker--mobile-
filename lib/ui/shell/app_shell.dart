// [TAHAP 1] BARU: cangkang aplikasi = satu NavigationBar berisi 4 halaman (syarat dosen no. 4).
import 'dart:ui';

import 'package:flutter/material.dart';

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
        ),
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

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
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: onSelected,
                height: 68,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Beranda',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.search_rounded),
                    selectedIcon: Icon(Icons.search_rounded),
                    label: 'Search',
                  ),
                  // [TAHAP 1] Ikon Library polos.
                  // [TAHAP 3] AKAN DIUBAH: bungkus dengan Badge yang jumlahnya
                  //           dari LibraryBookRepository (item Sedang Dibaca).
                  NavigationDestination(
                    icon: Icon(Icons.local_library_outlined),
                    selectedIcon: Icon(Icons.local_library_rounded),
                    label: 'Library',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.fiber_manual_record_outlined),
                    selectedIcon: Icon(Icons.fiber_manual_record_rounded),
                    label: 'Rekam',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
