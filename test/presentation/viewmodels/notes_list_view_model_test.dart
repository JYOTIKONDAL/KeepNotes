import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:keep_notes/domain/entities/note.dart';
import 'package:keep_notes/presentation/viewmodels/notes_list_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/note_fixtures.dart';

void main() {
  late MockNoteRepository mockRepository;
  late NotesListViewModel viewModel;

  setUp(() {
    mockRepository = MockNoteRepository();
    viewModel = NotesListViewModel(mockRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('NotesListViewModel', () {
    test('initial state is empty and not loading', () {
      expect(viewModel.notes, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.isEmpty, isTrue);
      expect(viewModel.hasError, isFalse);
    });

    test('init subscribes to watchNotes and updates notes', () async {
      final controller = StreamController<List<Note>>.broadcast();
      when(() => mockRepository.watchNotes()).thenAnswer(
        (_) => controller.stream,
      );

      await viewModel.init();
      expect(viewModel.isLoading, isTrue);

      final notes = NoteFixtures.sampleList();
      controller.add(notes);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.notes, notes);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.isEmpty, isFalse);

      await controller.close();
    });

    test('init sets error when stream emits error', () async {
      final controller = StreamController<List<Note>>.broadcast();
      when(() => mockRepository.watchNotes()).thenAnswer(
        (_) => controller.stream,
      );

      await viewModel.init();
      controller.addError(Exception('Stream failed'));
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, contains('Stream failed'));
      expect(viewModel.isLoading, isFalse);

      await controller.close();
    });

    test('init cancels previous subscription when called again', () async {
      final firstController = StreamController<List<Note>>.broadcast();
      final secondController = StreamController<List<Note>>.broadcast();
      var callCount = 0;

      when(() => mockRepository.watchNotes()).thenAnswer((_) {
        callCount++;
        return callCount == 1
            ? firstController.stream
            : secondController.stream;
      });

      await viewModel.init();
      firstController.add([NoteFixtures.sample(id: 1)]);
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.notes.length, 1);

      await viewModel.init();
      secondController.add(NoteFixtures.sampleList());
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.notes.length, 2);

      await firstController.close();
      await secondController.close();
    });

    test('deleteNote calls repository and clears error on success', () async {
      when(() => mockRepository.deleteNote(1)).thenAnswer((_) async => true);

      await viewModel.deleteNote(1);

      verify(() => mockRepository.deleteNote(1)).called(1);
      expect(viewModel.hasError, isFalse);
    });

    test('deleteNote sets error when repository throws', () async {
      when(() => mockRepository.deleteNote(1)).thenThrow(Exception('DB error'));

      await viewModel.deleteNote(1);

      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, contains('Failed to delete note'));
    });

    test('dispose cancels stream subscription', () async {
      final controller = StreamController<List<Note>>.broadcast();
      when(() => mockRepository.watchNotes()).thenAnswer(
        (_) => controller.stream,
      );

      await viewModel.init();
      viewModel.dispose();

      controller.add(NoteFixtures.sampleList());
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.notes, isEmpty);
      await controller.close();
    });
  });
}
