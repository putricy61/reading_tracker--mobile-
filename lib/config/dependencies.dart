// [TAHAP 1] BARU: tempat mendaftarkan Service + semua Repository (syarat dosen no. 7).
// [TAHAP 1 - PERBAIKAN] import provider.dart dipasang lagi karena sekarang dipakai
// oleh provider placeholder di bawah.
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> buildProviders() {
  return [
    // [TAHAP 1 - PERBAIKAN] MultiProvider TIDAK boleh menerima list kosong
    // (error: 'children.isNotEmpty' is not true). Provider placeholder ini hanya
    // supaya list tidak kosong. [TAHAP 2] AKAN DIHAPUS saat provider asli ditambahkan.
    Provider<String>.value(value: 'reading_tracker'),

    // [TAHAP 2] AKAN DITAMBAH: Provider(create: (_) => ReadingTrackerService()),
    // [TAHAP 2] AKAN DITAMBAH: Provider(create: (c) => BookInfoRepository(service: c.read())),
    // [TAHAP 3] AKAN DITAMBAH: ChangeNotifierProvider(create: (c) => LibraryBookRepository(...)),
    // [TAHAP 4] AKAN DITAMBAH: Provider(create: (c) => ReadingSessionRepository(...)),
  ];
}