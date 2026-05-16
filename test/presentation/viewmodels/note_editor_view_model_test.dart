import 'package:flutter_test/flutter_test.dart';
import 'package:keep_notes/domain/entities/note.dart';
import 'package:keep_notes/presentation/viewmodels/note_editor_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/note_fixtures.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(NoteFixtures.newNote());
  });
  late MockNoteRepository mockRepository;
  late NoteEditorViewModel viewModel;

  setUp(() {
    mockRepository = MockNoteRepository();
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('NoteEditorViewModel — new note', () {
    setUp(() {
      viewModel = NoteEditorViewModel(mockRepository);
    });

    test('isEditing is false for new note', () {
      expect(viewModel.isEditing, isFalse);
      expect(viewModel.note.isNew, isTrue);
    });

    test('updateTitle and updateContent update note', () {
      viewModel.updateTitle('Hello');
      viewModel.updateContent('World');

      expect(viewModel.note.title, 'Hello');
      expect(viewModel.note.content, 'World');
    });

    test('togglePinned flips isPinned', () {
      expect(viewModel.note.isPinned, isFalse);
      viewModel.togglePinned();
      expect(viewModel.note.isPinned, isTrue);
      viewModel.togglePinned();
      expect(viewModel.note.isPinned, isFalse);
    });

    test('save returns false when note is empty', () async {
      final result = await viewModel.save();

      expect(result, isFalse);
      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, 'Note cannot be empty');
      verifyNever(() => mockRepository.saveNote(any()));
    });

    test('save persists new note and assigns id', () async {
      when(() => mockRepository.saveNote(any())).thenAnswer((_) async => 42);

      viewModel.updateTitle('My note');
      final result = await viewModel.save();

      expect(result, isTrue);
      expect(viewModel.note.id, 42);
      expect(viewModel.isLoading, isFalse);
      verify(() => mockRepository.saveNote(any())).called(1);
    });

    test('save sets error when repository throws', () async {
      when(() => mockRepository.saveNote(any()))
          .thenThrow(Exception('Write failed'));

      viewModel.updateContent('Body');
      final result = await viewModel.save();

      expect(result, isFalse);
      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, contains('Failed to save note'));
    });

    test('delete returns true without calling repository for new note', () async {
      final result = await viewModel.delete();

      expect(result, isTrue);
      verifyNever(() => mockRepository.deleteNote(any()));
    });
  });

  group('NoteEditorViewModel — existing note', () {
    setUp(() {
      viewModel = NoteEditorViewModel(
        mockRepository,
        initialNote: NoteFixtures.sample(id: 5),
      );
    });

    test('isEditing is true for existing note', () {
      expect(viewModel.isEditing, isTrue);
      expect(viewModel.note.id, 5);
    });

    test('save updates existing note via repository', () async {
      when(() => mockRepository.saveNote(any())).thenAnswer((_) async => 5);

      viewModel.updateTitle('Updated');
      final result = await viewModel.save();

      expect(result, isTrue);
      verify(() => mockRepository.saveNote(any())).called(1);
    });

    test('delete calls repository with note id', () async {
      when(() => mockRepository.deleteNote(5)).thenAnswer((_) async => true);

      final result = await viewModel.delete();

      expect(result, isTrue);
      verify(() => mockRepository.deleteNote(5)).called(1);
    });

    test('delete sets error when repository throws', () async {
      when(() => mockRepository.deleteNote(5))
          .thenThrow(Exception('Delete failed'));

      final result = await viewModel.delete();

      expect(result, isFalse);
      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, contains('Failed to delete note'));
    });
  });
}
