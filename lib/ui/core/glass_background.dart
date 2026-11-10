// [TAHAP 1 - UBAH] Latar gradien kini TERANG (putih-mint) dengan bola cahaya hijau lembut,
// supaya kaca (frosted glass) tetap terlihat ala iOS.
import 'package:flutter/material.dart';

import 'app_colors.dart';

class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // [UBAH] Gradien dasar: warna gelap diganti warna terang
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
            ),
          ),
        ),
        // [UBAH] Bola cahaya: warna hijau, alpha disesuaikan untuk latar terang
        _blob(top: -80, left: -60, size: 280, color: AppColors.accentSoft, alpha: 0.35),
        _blob(top: 260, right: -90, size: 320, color: AppColors.accentLight, alpha: 0.7),
        _blob(bottom: -100, left: 20, size: 300, color: AppColors.accent, alpha: 0.14),
        child,
      ],
    );
  }

  Widget _blob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
    required double alpha,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}
