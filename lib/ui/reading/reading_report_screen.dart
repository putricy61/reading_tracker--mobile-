// [TAHAP 5] BARU: layar laporan sesi buku fisik.
// Terbuka otomatis setelah sesi disimpan. Isi: visualisasi jalur buku + kustomisasi
// (latar: palet / transparan / foto galeri, warna teks, orientasi, ukuran) + simpan ke galeri.
// [TAHAP 6] AKAN DITAMBAH: versi ebook (jejak gestur).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/models/reading_session.dart';
import '../core/app_colors.dart';
import '../core/glass_background.dart';
import '../core/glass_card.dart';
import 'book_path_visual.dart';

enum _BgMode { palette, transparent, photo }

class _Palette {
  const _Palette(this.colors);
  final List<Color> colors;
}

class _FontColor {
  const _FontColor(this.name, this.color);
  final String name;
  final Color color;
}

class ReadingReportScreen extends StatefulWidget {
  const ReadingReportScreen({super.key, required this.session});

  final ReadingSession session;

  static void open(BuildContext context, ReadingSession session) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReadingReportScreen(session: session)),
    );
  }

  @override
  State<ReadingReportScreen> createState() => _ReadingReportScreenState();
}

class _ReadingReportScreenState extends State<ReadingReportScreen> {
  static const _palettes = <_Palette>[
    _Palette([Color(0xFF0D2A1B), Color(0xFF1B6B45)]), // hutan
    _Palette([Color(0xFFE4F3EA), Color(0xFFCFE8D9)]), // mint
    _Palette([Color(0xFFFFF8E7), Color(0xFFF3E3C0)]), // krem
    _Palette([Color(0xFF111827), Color(0xFF1F2937)]), // malam
    _Palette([Color(0xFFFF9A62), Color(0xFFB5456B)]), // senja
  ];

  static const _fonts = <_FontColor>[
    _FontColor('Putih', Color(0xFFFFFFFF)),
    _FontColor('Krem', Color(0xFFFFF3D6)),
    _FontColor('Hijau tua', Color(0xFF0D2A1B)),
    _FontColor('Hitam', Color(0xFF111111)),
  ];

  final _captureKey = GlobalKey();

  _BgMode _bgMode = _BgMode.palette;
  int _paletteIndex = 0;
  String? _photoPath;
  int _fontIndex = 0;
  bool _vertical = true;
  double _scale = 0.85;
  int _replay = 0; // diubah untuk memutar ulang animasi
  bool _saving = false;

  ReadingSession get _s => widget.session;

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() {
      _bgMode = _BgMode.photo;
      _photoPath = picked.path;
    });
  }

  Future<void> _saveToGallery() async {
    setState(() => _saving = true);
    String message;
    try {
      final boundary =
          _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      await Gal.putImageBytes(data!.buffer.asUint8List());
      message = 'Visualisasi tersimpan ke galeri';
    } catch (e) {
      message = 'Gagal menyimpan: $e';
    }
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        appBar: AppBar(title: const Text('Laporan sesi')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _preview(),
            const SizedBox(height: 18),
            _options(),
            const SizedBox(height: 18),
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
              onPressed: _saving ? null : _saveToGallery,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.download_rounded),
              label: const Text('Simpan ke galeri'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Pratinjau (area yang diekspor) ----------

  Widget _preview() {
    return AspectRatio(
      aspectRatio: _vertical ? 4 / 5 : 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // papan catur penanda transparan (di luar area ekspor)
            if (_bgMode == _BgMode.transparent) const _Checker(),
            RepaintBoundary(key: _captureKey, child: _content()),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    final fontColor = _fonts[_fontIndex].color;
    final percent = _s.percentOfBook ?? 0;

    BoxDecoration? decoration;
    switch (_bgMode) {
      case _BgMode.palette:
        decoration = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _palettes[_paletteIndex].colors,
          ),
        );
      case _BgMode.photo:
        decoration = _photoPath == null
            ? null
            : BoxDecoration(
                image: DecorationImage(image: FileImage(File(_photoPath!)), fit: BoxFit.cover),
              );
      case _BgMode.transparent:
        decoration = null; // tanpa latar -> PNG transparan
    }

    return DecoratedBox(
      decoration: decoration ?? const BoxDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Text(
              _s.bookTitle,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: fontColor),
            ),
            Expanded(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: _scale,
                  heightFactor: _scale,
                  child: BookPathVisual(key: ValueKey(_replay), progress: percent),
                ),
              ),
            ),
            Text(
              '${(percent * 100).round()}%',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: fontColor),
            ),
            const SizedBox(height: 4),
            Text(
              '${_s.durationMinutes} menit · ${_s.pagesRead} hlm · '
              '${_s.date.day}/${_s.date.month}/${_s.date.year}',
              style: TextStyle(fontSize: 12, color: fontColor.withValues(alpha: 0.85)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Kustomisasi ----------

  Widget _options() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Latar'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (int i = 0; i < _palettes.length; i++)
                GestureDetector(
                  onTap: () => setState(() {
                    _bgMode = _BgMode.palette;
                    _paletteIndex = i;
                  }),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: _palettes[i].colors),
                      border: Border.all(
                        color: (_bgMode == _BgMode.palette && _paletteIndex == i)
                            ? AppColors.accent
                            : AppColors.glassBorder,
                        width: (_bgMode == _BgMode.palette && _paletteIndex == i) ? 3 : 1.5,
                      ),
                    ),
                  ),
                ),
              ChoiceChip(
                label: const Text('Transparan'),
                selected: _bgMode == _BgMode.transparent,
                onSelected: (_) => setState(() => _bgMode = _BgMode.transparent),
              ),
              ActionChip(
                avatar: const Icon(Icons.photo_library_rounded, size: 18),
                label: const Text('Foto galeri'),
                onPressed: _pickPhoto,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _label('Warna teks'),
          Wrap(
            spacing: 8,
            children: [
              for (int i = 0; i < _fonts.length; i++)
                ChoiceChip(
                  label: Text(_fonts[i].name),
                  avatar: CircleAvatar(backgroundColor: _fonts[i].color, radius: 8),
                  selected: _fontIndex == i,
                  onSelected: (_) => setState(() => _fontIndex = i),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _label('Orientasi'),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: true, label: Text('Vertikal')),
              ButtonSegment(value: false, label: Text('Horizontal')),
            ],
            selected: {_vertical},
            onSelectionChanged: (s) => setState(() => _vertical = s.first),
          ),
          const SizedBox(height: 16),
          _label('Ukuran visualisasi'),
          Slider(
            value: _scale,
            min: 0.4,
            max: 1.0,
            activeColor: AppColors.accent,
            onChanged: (v) => setState(() => _scale = v),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _replay++),
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Putar ulang animasi'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      );
}

/// Papan catur abu-abu: penanda bahwa latar transparan.
class _Checker extends StatelessWidget {
  const _Checker();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _CheckerPainter());
}

class _CheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cell = 14.0;
    final light = Paint()..color = const Color(0xFFFFFFFF);
    final dark = Paint()..color = const Color(0xFFE3E8E5);
    for (double y = 0; y < size.height; y += cell) {
      for (double x = 0; x < size.width; x += cell) {
        final isDark = ((x / cell).floor() + (y / cell).floor()).isEven;
        canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), isDark ? dark : light);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
