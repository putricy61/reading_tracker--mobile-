// [TAHAP 1 - UBAH] Kerangka halaman sementara.
// [UBAH] ListView diganti CustomScrollView + CollapsingTitleHeader agar judul bisa
//        mengecil dan pindah ke tengah saat di-scroll.
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'collapsing_title_header.dart';
import 'glass_card.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    required this.note,
  });

  final String title;
  final IconData icon;
  final String note;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // [BARU] header judul yang responsif terhadap scroll
        CollapsingTitleHeader(title: title),
        SliverPadding(
          // padding bawah besar supaya konten tidak tertutup NavigationBar kaca
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          sliver: SliverList.list(
            children: [
              GlassCard(
                child: Row(
                  children: [
                    Icon(icon, size: 36, color: AppColors.accent),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        note,
                        style: const TextStyle(color: AppColors.textMuted, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              // [BARU - SEMENTARA] kartu contoh supaya halaman bisa di-scroll
              // dan efek judul mengecil terlihat. HAPUS di tahap 2-4 saat konten asli ada.
              for (int i = 1; i <= 8; i++) ...[
                const SizedBox(height: 14),
                GlassCard(
                  child: SizedBox(
                    height: 72,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contoh konten $i',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
