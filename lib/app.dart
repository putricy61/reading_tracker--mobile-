// [TAHAP 1] BARU: root widget aplikasi (MaterialApp + tema + dependency).
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'ui/core/app_theme.dart';
import 'ui/shell/app_shell.dart';

class ReadingTrackerApp extends StatelessWidget {
  const ReadingTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // [TAHAP 1] Semua provider dibungkus di sini supaya bisa diakses lewat context.read().
    // Daftar providers masih kosong; diisi bertahap mulai TAHAP 2.
    return MultiProvider(
      providers: buildProviders(),
      child: MaterialApp(
        title: 'Reading Tracker',
        debugShowCheckedModeBanner: false,
        // [TAHAP 1 - UBAH] AppTheme.dark() -> AppTheme.light()
        theme: AppTheme.light(),
        home: const AppShell(),
      ),
    );
  }
}
