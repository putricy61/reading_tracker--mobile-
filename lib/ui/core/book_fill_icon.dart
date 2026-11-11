// [TAHAP 2] BARU: ikon buku untuk kalender. fraction 0.0-1.0 = seberapa penuh warna aplikasi
// (1.0 = 2 jam membaca), sisanya abu-abu. Angka tanggal tetap tampil di tengah.
// Jika fraction = 0 (tidak membaca), hanya angka tanggal biasa yang tampil.
import 'package:flutter/material.dart';

import 'app_colors.dart';

class BookFillIcon extends StatelessWidget {
  const BookFillIcon({
    super.key,
    required this.fraction,
    required this.label,
    this.isToday = false,
    this.size = 38,
  });

  final double fraction;
  final String label;
  final bool isToday;
  final double size;

  @override
  Widget build(BuildContext context) {
    final onFilled = fraction >= 0.55;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (fraction > 0)
            CustomPaint(size: Size.square(size), painter: _BookPainter(fraction)),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: (isToday || fraction > 0) ? FontWeight.w700 : FontWeight.w400,
              color: onFilled
                  ? Colors.white
                  : (isToday ? AppColors.accent : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookPainter extends CustomPainter {
  _BookPainter(this.fraction);

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(size.width * 0.12, size.height * 0.04, size.width * 0.76, size.height * 0.92);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));

    // bagian abu-abu (sisa)
    canvas.drawRRect(rrect, Paint()..color = AppColors.trackGrey.withValues(alpha: 0.45));

    // bagian berwarna, naik dari bawah sesuai fraction
    canvas.save();
    canvas.clipRRect(rrect);
    final top = rect.bottom - rect.height * fraction;
    canvas.drawRect(
      Rect.fromLTRB(rect.left, top, rect.right, rect.bottom),
      Paint()..color = AppColors.accent,
    );
    canvas.restore();

    // garis punggung buku
    final spineX = rect.left + rect.width * 0.16;
    canvas.drawLine(
      Offset(spineX, rect.top + 3),
      Offset(spineX, rect.bottom - 3),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _BookPainter oldDelegate) => oldDelegate.fraction != fraction;
}
