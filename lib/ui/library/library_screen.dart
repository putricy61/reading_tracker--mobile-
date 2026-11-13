// [TAHAP 1] BARU: halaman Library (placeholder).
// [TAHAP 3 - UBAH] Placeholder diganti isi asli: dua bagian (Sedang Dibaca, Tamat)
// dengan CheckboxListTile. Mencentang ebook memindahkannya ke Tamat.
// [TAHAP 5] AKAN DITAMBAH: tombol impor PDF dari penyimpanan hp.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/book_info_repository.dart';
import '../../data/repositories/library_book_repository.dart';
import '../../domain/models/library_book.dart';
import '../core/app_colors.dart';
import '../core/book_cover.dart';
import '../core/collapsing_title_header.dart';
import '../core/glass_card.dart';
import 'library_view_model.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late final LibraryViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = LibraryViewModel(
      libraryRepository: context.read<LibraryBookRepository>(),
      bookRepository: context.read<BookInfoRepository>(),
    )..load();
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
        return CustomScrollView(
          slivers: [
            const CollapsingTitleHeader(title: 'Library'),
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
                sliver: SliverList.list(children: _buildSections()),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildSections() {
    return [
      _SectionHeader(title: 'Sedang Dibaca', count: _vm.inProgress.length),
      const SizedBox(height: 12),
      if (_vm.inProgress.isEmpty)
        const _EmptyCard('Tidak ada ebook yang sedang dibaca.')
      else
        for (final item in _vm.inProgress) ...[
          _LibraryTile(
            item: item,
            color: Color(_vm.coverColorOf(item)),
            onChanged: (v) => _vm.setCompleted(item, v),
          ),
          const SizedBox(height: 12),
        ],
      const SizedBox(height: 12),
      _SectionHeader(title: 'Tamat', count: _vm.completed.length),
      const SizedBox(height: 12),
      if (_vm.completed.isEmpty)
        const _EmptyCard('Centang ebook yang sudah selesai dibaca agar pindah ke sini.')
      else
        for (final item in _vm.completed) ...[
          _LibraryTile(
            item: item,
            color: Color(_vm.coverColorOf(item)),
            onChanged: (v) => _vm.setCompleted(item, v),
          ),
          const SizedBox(height: 12),
        ],
    ];
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Text(text, style: const TextStyle(color: AppColors.textMuted)),
    );
  }
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({required this.item, required this.color, required this.onChanged});

  final LibraryBook item;
  final Color color;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isPdf = item.source == LibraryBook.sourcePdf;
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      // Checklist memakai CheckboxListTile (syarat dosen no. 6)
      child: CheckboxListTile(
        value: item.isCompleted,
        onChanged: (v) => onChanged(v ?? false),
        activeColor: AppColors.accent,
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        secondary: BookCover(title: item.title, color: color, width: 48, height: 66),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: AppColors.textMuted,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 6),
            if (item.isCompleted)
              const Text(
                'Tamat',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              )
            else ...[
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
                '${isPdf ? 'PDF · ' : ''}Hlm ${item.lastPage} dari ${item.totalPages}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
