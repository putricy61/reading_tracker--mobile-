// [TAHAP 1] BARU: tempat mendaftarkan Service + semua Repository (syarat dosen no. 7).
// [TAHAP 2 - UBAH] Provider placeholder dihapus, diganti Service + 3 Repository asli.
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/book_info_repository.dart';
import '../data/repositories/library_book_repository.dart';
import '../data/repositories/reading_session_repository.dart';
import '../data/services/reading_tracker_service.dart';

List<SingleChildWidget> buildProviders() {
  return [
    // [TAHAP 2 - BARU] Service didaftarkan lebih dulu karena dipakai repository.
    Provider<ReadingTrackerService>(create: (_) => ReadingTrackerService()),

    // [TAHAP 2 - BARU] Repository mengambil Service lewat context.read()
    Provider<BookInfoRepository>(
      create: (context) => BookInfoRepository(service: context.read()),
    ),
    // Repository data aksi = ChangeNotifier, jadi memakai ChangeNotifierProvider
    ChangeNotifierProvider<LibraryBookRepository>(
      create: (context) => LibraryBookRepository(service: context.read()),
    ),
    Provider<ReadingSessionRepository>(
      create: (context) => ReadingSessionRepository(service: context.read()),
    ),
  ];
}
