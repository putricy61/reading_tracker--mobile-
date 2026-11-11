// [TAHAP 1] BARU: header halaman dengan judul besar di kiri.
// Saat halaman di-scroll, judul MENGECIL dan PINDAH KE TENGAH, dan latar header
// berubah menjadi kaca buram (seperti large title di iOS).
// Dipakai sebagai sliver pertama di CustomScrollView tiap halaman.
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_colors.dart';

class CollapsingTitleHeader extends StatelessWidget {
  const CollapsingTitleHeader({
    super.key,
    required this.title,
    this.expandedHeight = 112,
    this.trailing, // [TAHAP 2 - BARU] widget aksi di kanan header
  });

  final String title;

  /// [TAHAP 2 - BARU] Mis. ikon profil di Beranda.
  final Widget? trailing;

  /// Tinggi header saat belum di-scroll (di luar tinggi status bar).
  final double expandedHeight;

  static const double _bigFont = 34;
  static const double _smallFont = 17;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true, // tetap menempel di atas setelah mengecil
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: kToolbarHeight,
      expandedHeight: expandedHeight,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final topPad = MediaQuery.paddingOf(context).top;
          final minH = kToolbarHeight + topPad;
          final maxH = expandedHeight + topPad;
          // t = 1 saat header terbuka penuh, t = 0 saat sudah mengecil penuh
          final t = ((constraints.maxHeight - minH) / (maxH - minH)).clamp(0.0, 1.0);
          final collapse = 1 - t;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Latar kaca: makin pekat seiring header mengecil
              if (collapse > 0.02)
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24 * collapse, sigmaY: 24 * collapse),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.glassFillStrong.withValues(alpha: 0.7 * collapse),
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.glassBorder.withValues(alpha: collapse),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Judul: ukuran 34 -> 17, posisi kiri (-1) -> tengah (0)
              Positioned(
                left: 0,
                right: 0,
                bottom: lerpDouble(0, 6, t)!,
                height: kToolbarHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment(-t, 0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: lerpDouble(_smallFont, _bigFont, t),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                ),
              ),
              // [TAHAP 2 - BARU] aksi di kanan, sejajar dengan judul
              if (trailing != null)
                Positioned(
                  right: 8,
                  bottom: lerpDouble(0, 6, t)!,
                  height: kToolbarHeight,
                  child: Center(child: trailing),
                ),
            ],
          );
        },
      ),
    );
  }
}
