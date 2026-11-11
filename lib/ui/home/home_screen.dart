// [TAHAP 1] BARU: halaman Beranda (placeholder).
// [TAHAP 2 - UBAH] Placeholder diganti isi asli: kalender, rekomendasi ebook,
// daftar Sedang Dibaca, dan ikon profil. Memakai ListenableBuilder + HomeViewModel.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/book_info_repository.dart';
import '../../data/repositories/library_book_repository.dart';
import '../../data/repositories/reading_session_repository.dart';
import '../../domain/models/library_book.dart';
import '../book_detail/book_detail_screen.dart';
import '../core/app_colors.dart';
import '../core/book_cover.dart';
import '../core/collapsing_title_header.dart';
import '../core/glass_card.dart';
import 'home_view_model.dart';
import 'reading_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _vm;

  @override
  void initState() {
    super.initState();
    // Dependency diambil dengan context.read() (syarat dosen no. 8)
    _vm = HomeViewModel(
      bookRepository: context.read<BookInfoRepository>(),
      libraryRepository: context.read<LibraryBookRepository>(),
      sessionRepository: context.read<ReadingSessionRepository>(),
    )..load();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder mengamati perubahan ViewModel (syarat dosen no. 2)
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return CustomScrollView(
          slivers: [
            CollapsingTitleHeader(
              title: 'Beranda',
              trailing: IconButton(
                icon: const Icon(Icons.account_circle_rounded, size: 30),
                color: AppColors.accent,
                onPressed: () {
                  // [TAHAP 2] Halaman profil belum dibuat.
                  // [TAHAP 6] AKAN DIUBAH: Navigator.push ke ProfileScreen.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Halaman profil dibuat di tahap berikutnya')),
                  );
                },
              ),
            ),
            if (_vm.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_vm.error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_vm.error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: _vm.load, child: const Text('Coba lagi')),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                sliver: SliverList.list(children: _buildContent()),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildContent() {
    final inProgress = _vm.inProgress;
    return [
      ReadingCalendar(month: DateTime.now(), minutesOf: _vm.minutesOn),
      const SizedBox(height: 24),
      const _SectionTitle('Rekomendasi ebook'),
      const SizedBox(height: 12),
      SizedBox(
        height: 215,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _vm.recommendations.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, i) {
            final book = _vm.recommendations[i];
            return GestureDetector(
              onTap: () => BookDetailScreen.open(context, book),
              child: SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookCover(
                      title: book.title,
                      color: Color(book.coverColor),
                      width: 120,
                      height: 150,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 24),
      const _SectionTitle('Sedang Dibaca'),
      const SizedBox(height: 12),
      if (inProgress.isEmpty)
        const GlassCard(
          child: Text(
            'Belum ada ebook yang sedang dibaca.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        )
      else
        for (final item in inProgress) ...[
          _ReadingTile(
            item: item,
            color: Color(_vm.findBook(item.bookId)?.coverColor ?? 0xFF1B6B45),
            onTap: () {
              final book = _vm.findBook(item.bookId);
              if (book != null) BookDetailScreen.open(context, book);
            },
          ),
          const SizedBox(height: 12),
        ],
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700));
  }
}

class _ReadingTile extends StatelessWidget {
  const _ReadingTile({required this.item, required this.color, required this.onTap});

  final LibraryBook item;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          BookCover(title: item.title, color: color, width: 48, height: 66),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  item.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    minHeight: 6,
                    color: AppColors.accent,
                    backgroundColor: AppColors.trackGrey.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hlm ${item.lastPage} dari ${item.totalPages}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
