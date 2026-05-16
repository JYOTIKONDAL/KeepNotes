import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:keep_notes/data/datasources/local/isar_service.dart';
import 'package:keep_notes/data/repositories/note_repository_impl.dart';
import 'package:keep_notes/domain/entities/note.dart';

import '../../helpers/note_fixtures.dart';

void main() {
  late Directory tempDir;
  late IsarService isarService;
  late NoteRepositoryImpl repository;
  var instanceCounter = 0;

  setUp(() async {
    instanceCounter++;
    tempDir = await Directory.systemTemp.createTemp('keep_notes_test_$instanceCounter');
    isarService = IsarService(
      directoryPath: tempDir.path,
      instanceName: 'test_db_$instanceCounter',
    );
    repository = NoteRepositoryImpl(isarService);
  });

  tearDown(() async {
    await isarService.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('NoteRepositoryImpl', () {
    test('saveNote creates a new note with Untitled when title is blank', () async {
      final id = await repository.saveNote(
        NoteFixtures.newNote(title: '   ', content: 'Body only'),
      );

      final saved = await repository.getNoteById(id);
      expect(saved, isNotNull);
      expect(saved!.title, 'Untitled');
      expect(saved.content, 'Body only');
    });

    test('saveNote updates an existing note', () async {
      final id = await repository.saveNote(
        NoteFixtures.newNote(title: 'Original', content: 'v1'),
      );

      final updated = NoteFixtures.sample(
        id: id,
        title: 'Updated',
        content: 'v2',
        isPinned: true,
      );
      await repository.saveNote(updated);

      final saved = await repository.getNoteById(id);
      expect(saved!.title, 'Updated');
      expect(saved.content, 'v2');
      expect(saved.isPinned, isTrue);
    });

    test('saveNote throws when updating a missing note', () async {
      final missing = NoteFixtures.sample(id: 99999, title: 'Ghost');

      expect(
        () => repository.saveNote(missing),
        throwsA(isA<StateError>()),
      );
    });

    test('getAllNotes returns notes sorted by updatedAt descending', () async {
      await repository.saveNote(
        NoteFixtures.newNote(title: 'Older', content: 'a'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await repository.saveNote(
        NoteFixtures.newNote(title: 'Newer', content: 'b'),
      );

      final notes = await repository.getAllNotes();
      expect(notes.length, 2);
      expect(notes.first.title, 'Newer');
    });

    test('getNoteById returns null for unknown id', () async {
      final note = await repository.getNoteById(404);
      expect(note, isNull);
    });

    test('deleteNote removes a note', () async {
      final id = await repository.saveNote(
        NoteFixtures.newNote(title: 'To delete'),
      );

      final deleted = await repository.deleteNote(id);
      expect(deleted, isTrue);
      expect(await repository.getNoteById(id), isNull);
    });

    test('deleteAllNotes clears the database', () async {
      await repository.saveNote(NoteFixtures.newNote(title: 'One'));
      await repository.saveNote(NoteFixtures.newNote(title: 'Two'));

      await repository.deleteAllNotes();

      final notes = await repository.getAllNotes();
      expect(notes, isEmpty);
    });

    test('watchNotes emits updates when data changes', () async {
      final emissions = <List<Note>>[];
      final subscription = repository.watchNotes().listen(emissions.add);

      await Future<void>.delayed(Duration.zero);
      expect(emissions, isNotEmpty);
      expect(emissions.last, isEmpty);

      await repository.saveNote(NoteFixtures.newNote(title: 'Live'));
      await Future<void>.delayed(Duration.zero);

      expect(emissions.last.length, 1);
      expect(emissions.last.first.title, 'Live');

      await subscription.cancel();
    });
  });
}
