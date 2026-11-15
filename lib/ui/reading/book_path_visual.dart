// [TAHAP 5] BARU: visualisasi jalur buku (ala Strava, tapi bentuknya buku terbuka).
// - Lapisan 1: seluruh jalur (100%) abu-abu putus-putus sebagai panduan.
// - Lapisan 2: jalur berpijar warna aplikasi, dipotong sesuai persentase (progress).
// - Animasi: garis tumbuh dari `from` ke `progress` selama 1,5 detik + titik pijar di ujungnya.
// - Jika 100%: efek kilau (completion glow flash).
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class BookPathVisual extends StatefulWidget {
  const BookPathVisual({
    super.key,
    required this.progress,
    this.from = 0,
    this.activeColor = AppColors.accentSoft,
    this.trackColor = AppColors.trackGrey,
    this.duration = const Duration(milliseconds: 1500),
  });

  /// Progres akhir 0.0 - 1.0
  final double progress;

  /// Progres awal animasi (0 untuk buku fisik karena tiap sesi independen)
  final double from;
  final Color activeColor;
  final Color trackColor;
  final Duration duration;

  @override
  State<BookPathVisual> createState() => _BookPathVisualState();
}

class _BookPathVisualState extends State<BookPathVisual> with TickerProviderStateMixin {
  late final AnimationController _grow;
  late final AnimationController _flash;
  late final Animation<double> _value;

  @override
  void initState() {
    super.initState();
    _grow = AnimationController(vsync: this, duration: widget.duration);
    _flash = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _value = Tween<double>(begin: widget.from, end: widget.progress)
        .animate(CurvedAnimation(parent: _grow, curve: Curves.easeInOut));
    _grow.addStatusListener((status) {
      // Buku tamat -> kilauan
      if (status == AnimationStatus.completed && widget.progress >= 1.0) {
        _flash.forward(from: 0);
      }
    });
    _grow.forward();
  }

  @override
  void dispose() {
    _grow.dispose();
    _flash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_grow, _flash]),
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: BookPathPainter(
            value: _value.value,
            flash: math.sin(_flash.value * math.pi), // 0 -> 1 -> 0
            activeColor: widget.activeColor,
            trackColor: widget.trackColor,
          ),
        );
      },
    );
  }
}

class BookPathPainter extends CustomPainter {
  BookPathPainter({
    required this.value,
    required this.flash,
    required this.activeColor,
    required this.trackColor,
  });

  final double value; // 0.0 - 1.0
  final double flash; // 0.0 - 1.0
  final Color activeColor;
  final Color trackColor;

  static const double _w = 200;
  static const double _h = 140;

  /// Buku terbuka, digambar bagian demi bagian secara berurutan:
  /// sampul kiri -> halaman kiri -> halaman kanan -> sampul kanan.
  /// Titik awal (0%) ada di sudut kiri bawah alas buku.
  static Path buildPath() {
    final p = Path();

    // 1) Sampul kiri: alas, naik membentuk punggung (spine), atas sampul, sisi luar kiri
    p.moveTo(6, 116);
    p.cubicTo(36, 114, 70, 120, 100, 126); // alas
    p.cubicTo(96, 100, 104, 60, 100, 28); // punggung (meliuk)
    p.cubicTo(70, 14, 34, 12, 6, 24); // sisi atas sampul kiri
    p.lineTo(6, 116); // sisi luar kiri turun

    // 2) Tumpukan halaman kiri (sisi dalam + atas menuju lipatan tengah)
    p.moveTo(14, 108);
    p.lineTo(14, 30);
    p.cubicTo(50, 20, 80, 30, 100, 42);

    // 3) Bawah tumpukan halaman kiri menuju lipatan tengah
    p.moveTo(14, 108);
    p.cubicTo(40, 100, 80, 118, 100, 120);

    // 4) Halaman kanan: atas, sisi dalam kanan turun, bawah kembali ke lipatan
    p.moveTo(100, 42);
    p.cubicTo(120, 30, 150, 20, 186, 30);
    p.lineTo(186, 108);
    p.cubicTo(150, 100, 120, 118, 100, 120);

    // 5) Sampul kanan / penutup belakang: atas, sisi luar kanan, alas kembali ke tengah
    p.moveTo(100, 28);
    p.cubicTo(130, 14, 164, 12, 194, 24);
    p.lineTo(194, 116);
    p.cubicTo(164, 114, 130, 120, 100, 126);

    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / _w, size.height / _h) * 0.92;
    final dx = (size.width - _w * scale) / 2;
    final dy = (size.height - _h * scale) / 2;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final metrics = buildPath().computeMetrics().toList();
    final total = metrics.fold<double>(0, (sum, m) => sum + m.length);

    // --- Lapisan 1: abu-abu putus-putus (template 100%) ---
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = trackColor.withValues(alpha: 0.85);
    for (final m in metrics) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + 6, m.length)), trackPaint);
        d += 11;
      }
    }

    // --- Lapisan 2: jalur berpijar yang dipotong sesuai persentase ---
    var remain = total * value.clamp(0.0, 1.0);
    final active = Path();
    Offset head = const Offset(6, 116); // titik awal (0%)
    for (final m in metrics) {
      if (remain <= 0) break;
      final len = math.min(remain, m.length);
      active.addPath(m.extractPath(0, len), Offset.zero);
      head = m.getTangentForOffset(len)?.position ?? head;
      remain -= len;
    }

    if (value > 0) {
      // pijaran (glow)
      canvas.drawPath(
        active,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 7 + flash * 6
          ..color = activeColor.withValues(alpha: 0.35 + flash * 0.4)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + flash * 4),
      );
      // garis utama
      canvas.drawPath(
        active,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 3.4
          ..color = activeColor,
      );
    }

    // titik pijar di ujung garis (juga titik awal saat 0%)
    canvas.drawCircle(
      head,
      9 + flash * 4,
      Paint()
        ..color = activeColor.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(head, 4.2, Paint()..color = Colors.white);
    canvas.drawCircle(
      head,
      4.2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = activeColor,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BookPathPainter old) =>
      old.value != value ||
      old.flash != flash ||
      old.activeColor != activeColor ||
      old.trackColor != trackColor;
}
