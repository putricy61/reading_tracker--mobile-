// [TAHAP 1 - UBAH] Kartu kaca disesuaikan untuk latar terang: ditambah bayangan lembut.
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_colors.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.blur = 22,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    // [BARU] DecoratedBox terluar untuk bayangan (bayangan tidak bisa di dalam ClipRRect)
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            color: AppColors.glassShadow,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(color: AppColors.glassBorder, width: 1),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.glassFillStrong, AppColors.glassFill],
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
