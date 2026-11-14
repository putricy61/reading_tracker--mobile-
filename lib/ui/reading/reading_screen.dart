// [TAHAP 1] BARU: halaman Rekam (fitur buatan sendiri, placeholder).
// [TAHAP 4 - UBAH] Placeholder diganti: pilihan mode (Buku fisik / Ebook), form pencatatan,
// dan riwayat sesi. Memakai ListenableBuilder + ReadingViewModel.
// [TAHAP 5] AKAN DITAMBAH: visualisasi jalur buku/jejak gestur, animasi, kustomisasi, ekspor.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/library_book_repository.dart';
import '../../data/repositories/reading_session_repository.dart';
import '../../domain/models/library_book.dart';
import '../../domain/models/reading_session.dart';
import '../core/app_colors.dart';
import '../core/collapsing_title_header.dart';
import '../core/glass_card.dart';
import 'reading_view_model.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  late final ReadingViewModel _vm;

  // Form buku fisik
  final _titleC = TextEditingController();
  final _pagesC = TextEditingController();
  final _totalC = TextEditingController();
  final _durationC = TextEditingController();

  // Form ebook
  final _startC = TextEditingController();
  final _endC = TextEditingController();
  final _ebookDurationC = TextEditingController();
  LibraryBook? _selectedBook;
  final Set<String> _gestures = {'swipe'};

  @override
  void initState() {
    super.initState();
    _vm = ReadingViewModel(
      sessionRepository: context.read<ReadingSessionRepository>(),
      libraryRepository: context.read<LibraryBookRepository>(),
    )..load();
  }

  @override
  void dispose() {
    _vm.dispose();
    for (final c in [_titleC, _pagesC, _totalC, _durationC, _startC, _endC, _ebookDurationC]) {
      c.dispose();
    }
    super.dispose();
  }

  int _num(TextEditingController c) => int.tryParse(c.text.trim()) ?? -1;

  InputDecoration _dec(String label, {String? hint}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.glassBorder),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.5),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
      ),
    );
  }

  Future<void> _savePhysical() async {
    final ok = await _vm.submitPhysical(
      title: _titleC.text,
      pagesRead: _num(_pagesC),
      totalPages: _num(_totalC),
      durationMinutes: _num(_durationC),
    );
    if (!mounted || !ok) return;
    for (final c in [_titleC, _pagesC, _totalC, _durationC]) {
      c.clear();
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesi buku fisik tersimpan')),
    );
  }

  Future<void> _saveEbook() async {
    final ok = await _vm.submitEbook(
      book: _selectedBook,
      startPage: _num(_startC),
      endPage: _num(_endC),
      durationMinutes: _num(_ebookDurationC),
      gestures: _gestures.toList(),
    );
    if (!mounted || !ok) return;
    for (final c in [_startC, _endC, _ebookDurationC]) {
      c.clear();
    }
    setState(() => _selectedBook = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesi ebook tersimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return CustomScrollView(
          slivers: [
            const CollapsingTitleHeader(title: 'Rekam'),
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
    final isPhysical = _vm.mode == ReadingMode.physical;
    return [
      SizedBox(
        width: double.infinity,
        child: SegmentedButton<ReadingMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: ReadingMode.physical,
              icon: Icon(Icons.menu_book_rounded),
              label: Text('Buku fisik'),
            ),
            ButtonSegment(
              value: ReadingMode.ebook,
              icon: Icon(Icons.tablet_mac_rounded),
              label: Text('Ebook'),
            ),
          ],
          selected: {_vm.mode},
          onSelectionChanged: (s) => _vm.setMode(s.first),
          style: SegmentedButton.styleFrom(
            backgroundColor: AppColors.glassFill,
            foregroundColor: AppColors.textMuted,
            selectedBackgroundColor: AppColors.accent.withValues(alpha: 0.16),
            selectedForegroundColor: AppColors.accent,
            side: const BorderSide(color: AppColors.glassBorder),
          ),
        ),
      ),
      const SizedBox(height: 16),
      GlassCard(child: isPhysical ? _physicalForm() : _ebookForm()),
      const SizedBox(height: 28),
      Text(
        'Riwayat sesi (${_vm.sessions.length})',
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 12),
      if (_vm.sessions.isEmpty)
        const GlassCard(
          child: Text('Belum ada sesi.', style: TextStyle(color: AppColors.textMuted)),
        )
      else
        for (final s in _vm.sessions) ...[
          _SessionTile(session: s),
          const SizedBox(height: 10),
        ],
    ];
  }

  Widget _physicalForm() {
    final pages = int.tryParse(_pagesC.text.trim()) ?? 0;
    final total = int.tryParse(_totalC.text.trim()) ?? 0;
    final fraction = (pages > 0 && total > 0) ? (pages / total).clamp(0.0, 1.0).toDouble() : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rekam buku fisik', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 4),
        const Text(
          'Setiap sesi dicatat tersendiri dan tidak menjumlah sesi sebelumnya.',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        TextField(controller: _titleC, decoration: _dec('Judul buku (opsional)')),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _pagesC,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: _dec('Halaman dibaca'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _totalC,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: _dec('Total halaman'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _durationC,
          keyboardType: TextInputType.number,
          decoration: _dec('Durasi membaca (menit)'),
        ),
        const SizedBox(height: 14),
        // Pratinjau persentase. [TAHAP 5] AKAN DIUBAH: diganti visualisasi jalur buku.
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            color: AppColors.accent,
            backgroundColor: AppColors.trackGrey.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(fraction * 100).round()}% dari buku dibaca pada sesi ini',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        ..._formFooter(onSave: _savePhysical),
      ],
    );
  }

  Widget _ebookForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rekam ebook', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 4),
        const Text(
          'Pencatatan otomatis (timer dan gestur) akan tersedia di pembaca ebook. '
          'Untuk saat ini isi manual.',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: DropdownButton<LibraryBook>(
            value: _selectedBook,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            hint: const Text('Pilih ebook dari Library'),
            items: [
              for (final b in _vm.libraryBooks)
                DropdownMenuItem(
                  value: b,
                  child: Text(b.title, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (b) => setState(() => _selectedBook = b),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _startC,
                keyboardType: TextInputType.number,
                decoration: _dec('Halaman awal'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _endC,
                keyboardType: TextInputType.number,
                decoration: _dec('Halaman akhir'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ebookDurationC,
          keyboardType: TextInputType.number,
          decoration: _dec('Durasi membaca (menit)'),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final g in const ['swipe', 'scroll'])
              FilterChip(
                label: Text(g),
                selected: _gestures.contains(g),
                selectedColor: AppColors.accent.withValues(alpha: 0.2),
                checkmarkColor: AppColors.accent,
                onSelected: (v) => setState(() {
                  v ? _gestures.add(g) : _gestures.remove(g);
                }),
              ),
          ],
        ),
        ..._formFooter(onSave: _saveEbook),
      ],
    );
  }

  List<Widget> _formFooter({required VoidCallback onSave}) {
    return [
      if (_vm.formError != null) ...[
        const SizedBox(height: 12),
        Text(_vm.formError!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
      ],
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 50)),
          onPressed: _vm.isSaving ? null : onSave,
          icon: _vm.isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save_rounded),
          label: const Text('Simpan sesi'),
        ),
      ),
    ];
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final ReadingSession session;

  @override
  Widget build(BuildContext context) {
    final percent = session.percentOfBook;
    final d = session.date;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              session.isPhysical ? Icons.menu_book_rounded : Icons.tablet_mac_rounded,
              color: AppColors.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.bookTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${d.day}/${d.month}/${d.year} · ${session.durationMinutes} menit · '
                  '${session.pagesRead} hlm',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (percent != null)
            Text(
              '${(percent * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent),
            ),
        ],
      ),
    );
  }
}
