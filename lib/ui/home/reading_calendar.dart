// [TAHAP 2] BARU: kalender bulan ini. Tanggal yang ada aktivitas membaca berubah
// menjadi ikon buku; 2 jam membaca = buku penuh, kurang dari itu terisi sebagian.
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/book_fill_icon.dart';
import '../core/glass_card.dart';

class ReadingCalendar extends StatelessWidget {
  const ReadingCalendar({super.key, required this.month, required this.minutesOf});

  final DateTime month;
  final int Function(DateTime day) minutesOf;

  static const int _fullMinutes = 120; // 2 jam = buku penuh
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  static const _weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    final offset = DateTime(month.year, month.month, 1).weekday - 1; // Senin = 0
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final rowCount = ((offset + daysInMonth) / 7).ceil();
    final today = DateTime.now();

    Widget cell(int day) {
      if (day < 1 || day > daysInMonth) return const SizedBox(height: 40);
      final date = DateTime(month.year, month.month, day);
      final fraction = (minutesOf(date) / _fullMinutes).clamp(0.0, 1.0).toDouble();
      final isToday =
          date.year == today.year && date.month == today.month && date.day == today.day;
      return SizedBox(
        height: 40,
        child: Center(
          child: BookFillIcon(fraction: fraction, label: '$day', isToday: isToday),
        ),
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_months[month.month - 1]} ${month.year}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final d in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (int r = 0; r < rowCount; r++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  for (int c = 0; c < 7; c++) Expanded(child: cell(r * 7 + c - offset + 1)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Buku penuh = membaca 2 jam atau lebih dalam sehari',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
