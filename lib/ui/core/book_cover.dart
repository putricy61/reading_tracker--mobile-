// [TAHAP 2] BARU: sampul buku sederhana (gradien warna + judul), dipakai di banyak halaman.
import 'package:flutter/material.dart';

class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.title,
    required this.color,
    this.width = 100,
    this.height = 140,
  });

  final String title;
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    final dark = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x330F4A2F), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, dark],
            ),
          ),
          child: Stack(
            children: [
              // garis punggung buku
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                width: 2,
                child: ColoredBox(color: Colors.white.withValues(alpha: 0.25)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    title,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: (width * 0.12).clamp(9.0, 16.0).toDouble(),
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
