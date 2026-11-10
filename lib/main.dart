// [TAHAP 1] BARU: titik masuk aplikasi.
import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  // [TAHAP 1] Pastikan binding siap sebelum runApp (dibutuhkan plugin di tahap berikutnya).
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ReadingTrackerApp());
}
