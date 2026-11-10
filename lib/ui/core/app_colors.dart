// [TAHAP 1 - UBAH] Palet diganti dari tema gelap ke tema TERANG "Deep Green Forest":
// latar putih-mint, teks dan aksen hijau hutan tua.
// Nama konstanta yang dipakai file lain (accent, textMuted, glassFill, dst.) sengaja dipertahankan.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // [UBAH] Latar belakang (gradien terang)
  static const Color bgTop = Color(0xFFF6FBF8);
  static const Color bgMid = Color(0xFFE4F3EA);
  static const Color bgBottom = Color(0xFFCFE8D9);

  // [UBAH] Aksen utama = hijau hutan tua (warna "apk" untuk garis progres)
  static const Color accent = Color(0xFF1B6B45);      // forest green
  static const Color accentSoft = Color(0xFF3FA774);  // hijau medium
  static const Color accentDeep = Color(0xFF0F4A2F);  // hijau sangat tua
  static const Color accentLight = Color(0xFFA8DCC0); // mint

  // [UBAH] Teks: hijau hampir hitam (kontras di atas latar terang)
  static const Color textPrimary = Color(0xFF0D2A1B);
  static const Color textMuted = Color(0xFF5B7A68);

  // [UBAH] Garis abu-abu putus-putus (template buku 100%)
  static const Color trackGrey = Color(0xFFB5C7BB);

  // [UBAH] Efek kaca di latar terang: putih semi-transparan + tepi putih + bayangan hijau tipis
  static const Color glassFillStrong = Color(0xB3FFFFFF); // putih ~70%
  static const Color glassFill = Color(0x66FFFFFF);       // putih ~40%
  static const Color glassBorder = Color(0xCCFFFFFF);     // putih ~80%
  static const Color glassShadow = Color(0x1A0F4A2F);     // BARU: bayangan lembut

  static const Color danger = Color(0xFFD64545);
}
