// [TAHAP 4] BARU: pengujian ViewModel fitur khusus (ReadingViewModel), syarat dosen no. 10.
// Jalankan dengan: flutter test
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_tracker/data/repositories/library_book_repository.dart';
import 'package:reading_tracker/data/repositories/reading_session_repository.dart';
import 'package:reading_tracker/data/services/reading_tracker_service.dart';
import 'package:reading_tracker/ui/reading/reading_view_model.dart';

void main() {
  late ReadingViewModel vm;

  setUp(() async {
    final service = ReadingTrackerService();
    vm = ReadingViewModel(
      sessionRepository: ReadingSessionRepository(service: service),
      libraryRepository: LibraryBookRepository(service: service),
    );
    await vm.load();
  });

  tearDown(() => vm.dispose());

  test('load() mengisi riwayat sesi dan menyelesaikan loading', () {
    expect(vm.isLoading, false);
    expect(vm.error, isNull);
    expect(vm.sessions.length, 8);
    expect(vm.libraryBooks, isNotEmpty);
  });

  test('submitPhysical valid menambah sesi independen di urutan paling depan', () async {
    final ok = await vm.submitPhysical(
      title: 'Novel tes',
      pagesRead: 30,
      totalPages: 300,
      durationMinutes: 45,
    );

    expect(ok, true);
    expect(vm.sessions.length, 9);
    expect(vm.sessions.first.isPhysical, true);
    expect(vm.sessions.first.bookTitle, 'Novel tes');
    expect(vm.sessions.first.percentOfBook, closeTo(0.1, 0.0001));
    expect(vm.formError, isNull);
  });

  test('submitPhysical ditolak jika halaman dibaca melebihi total', () async {
    final ok = await vm.submitPhysical(pagesRead: 400, totalPages: 300, durationMinutes: 30);

    expect(ok, false);
    expect(vm.formError, isNotNull);
    expect(vm.sessions.length, 8);
  });

  test('submitEbook menambah sesi dan memajukan halaman terakhir di Library', () async {
    final book = vm.libraryBooks.firstWhere((b) => b.id == 'lb1'); // lastPage awal 238
    final ok = await vm.submitEbook(
      book: book,
      startPage: 238,
      endPage: 260,
      durationMinutes: 30,
      gestures: ['swipe'],
    );

    expect(ok, true);
    expect(vm.sessions.length, 9);
    expect(vm.sessions.first.isPhysical, false);
    expect(vm.sessions.first.pagesRead, 22);
    expect(vm.libraryBooks.firstWhere((b) => b.id == 'lb1').lastPage, 260);
  });

  test('submitEbook ditolak jika halaman akhir tidak lebih besar dari halaman awal', () async {
    final book = vm.libraryBooks.firstWhere((b) => b.id == 'lb1');
    final ok = await vm.submitEbook(
      book: book,
      startPage: 100,
      endPage: 100,
      durationMinutes: 10,
      gestures: const [],
    );

    expect(ok, false);
    expect(vm.formError, isNotNull);
    expect(vm.sessions.length, 8);
  });
}
