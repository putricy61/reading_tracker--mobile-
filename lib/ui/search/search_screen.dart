// [TAHAP 1] BARU: halaman Search (placeholder).
// [TAHAP 2 - UBAH] Placeholder diganti: kolom pencarian, SegmentedButton kategori
// (3 pilihan), dan daftar hasil. Memakai ListenableBuilder + SearchViewModel.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/book_info_repository.dart';
import '../../domain/models/book_info.dart';
import '../book_detail/book_detail_screen.dart';
import '../core/app_colors.dart';
import '../core/book_cover.dart';
import '../core/collapsing_title_header.dart';
import '../core/glass_card.dart';
import 'search_view_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = SearchViewModel(bookRepository: context.read<BookInfoRepository>())..load();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final results = _vm.results;
        return CustomScrollView(
          slivers: [
            const CollapsingTitleHeader(title: 'Search'),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverList.list(
                children: [
                  // Kolom pencarian (judul / penulis)
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    radius: 20,
                    child: TextField(
                      onChanged: _vm.setQuery,
                      cursorColor: AppColors.accent,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.search_rounded, color: AppColors.textMuted),
                        hintText: 'Cari judul atau penulis',
                        hintStyle: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Kategori memakai SegmentedButton (syarat dosen no. 6)
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      emptySelectionAllowed: true, // tidak dipilih = tampilkan semua
                      showSelectedIcon: false,
                      segments: [
                        for (final g in SearchViewModel.genres)
                          ButtonSegment<String>(value: g, label: Text(g)),
                      ],
                      selected: {if (_vm.selectedGenre != null) _vm.selectedGenre!},
                      onSelectionChanged: (s) => _vm.setGenre(s.isEmpty ? null : s.first),
                      style: SegmentedButton.styleFrom(
                        backgroundColor: AppColors.glassFill,
                        foregroundColor: AppColors.textMuted,
                        selectedBackgroundColor: AppColors.accent.withValues(alpha: 0.16),
                        selectedForegroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.glassBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: results.isEmpty
                    ? const SliverToBoxAdapter(
                        child: GlassCard(
                          child: Text(
                            'Tidak ada ebook yang cocok.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      )
                    : SliverList.separated(
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _BookTile(book: results[i]),
                      ),
              ),
          ],
        );
      },
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book});

  final BookInfo book;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      onTap: () => BookDetailScreen.open(context, book),
      child: Row(
        children: [
          BookCover(title: book.title, color: Color(book.coverColor), width: 56, height: 78),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(book.author, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Text(
                  '${book.genre} · ${book.year}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
