// [TAHAP 2] BARU: halaman detail ebook (judul, penulis, sinopsis, tahun, buku serupa,
// tombol Baca : tombol + = 4 : 1). Jika sudah ada di Library, tombol + disembunyikan.
// [TAHAP 5] AKAN DIUBAH: tombol Baca membuka pembaca ebook.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/book_info_repository.dart';
import '../../data/repositories/library_book_repository.dart';
import '../../domain/models/book_info.dart';
import '../core/app_colors.dart';
import '../core/book_cover.dart';
import '../core/glass_background.dart';
import '../core/glass_card.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.book});

  final BookInfo book;

  /// Helper navigasi dipakai Beranda dan Search.
  static void open(BuildContext context, BookInfo book) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final library = context.read<LibraryBookRepository>();
    final similar = context.read<BookInfoRepository>().similarTo(book);

    // Route baru tidak mewarisi latar, jadi dibungkus GlassBackground lagi.
    return GlassBackground(
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail ebook')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(
                  title: book.title,
                  color: Color(book.coverColor),
                  width: 110,
                  height: 160,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(book.author, style: const TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Pill(book.genre),
                          _Pill('${book.year}'),
                          _Pill('${book.pages} hlm'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Sinopsis', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            GlassCard(
              child: Text(book.synopsis, style: const TextStyle(height: 1.5)),
            ),
            if (similar.isNotEmpty) ...[
              const SizedBox(height: 22),
              const Text(
                'Buku serupa',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 175,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: similar.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final b = similar[i];
                    return GestureDetector(
                      onTap: () => BookDetailScreen.open(context, b),
                      child: BookCover(
                        title: b.title,
                        color: Color(b.coverColor),
                        width: 105,
                        height: 165,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
        // Tombol bawah diamati terhadap LibraryBookRepository (ChangeNotifier)
        bottomNavigationBar: ListenableBuilder(
          listenable: library,
          builder: (context, _) {
            final inLibrary = library.isInLibrary(book.id);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    // Baca : tambah = 4 : 1
                    Expanded(
                      flex: 4,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
                        onPressed: () {
                          // [TAHAP 5] AKAN DIUBAH: buka pembaca ebook.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pembaca ebook dibuat di tahap berikutnya')),
                          );
                        },
                        icon: const Icon(Icons.menu_book_rounded),
                        label: const Text('Baca'),
                      ),
                    ),
                    if (!inLibrary) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: FilledButton.tonal(
                          style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
                          onPressed: () {
                            library.addFromBook(book);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ditambahkan ke Library')),
                            );
                          },
                          child: const Icon(Icons.add_rounded),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600),
      ),
    );
  }
}
