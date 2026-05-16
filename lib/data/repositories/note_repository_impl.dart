import 'package:isar/isar.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/local/isar_service.dart';
import '../models/note_model.dart';

/// Isar-backed implementation of [NoteRepository].
class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl(this._isarService);

  final IsarService _isarService;

  Future<Isar> get _db => _isarService.database;

  @override
  Stream<List<Note>> watchNotes() async* {
    final isar = await _db;
    yield* isar.noteModels
        .where()
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<List<Note>> getAllNotes() async {
    final isar = await _db;
    final models =
        await isar.noteModels.where().sortByUpdatedAtDesc().findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Note?> getNoteById(int id) async {
    final isar = await _db;
    final model = await isar.noteModels.get(id);
    return model?.toEntity();
  }

  @override
  Future<int> saveNote(Note note) async {
    final isar = await _db;
    final now = DateTime.now();

    if (note.isNew) {
      final model = NoteModel()
        ..title = note.title.trim().isEmpty ? 'Untitled' : note.title.trim()
        ..content = note.content
        ..createdAt = now
        ..updatedAt = now
        ..isPinned = note.isPinned;

      return await isar.writeTxn(() => isar.noteModels.put(model));
    }

    final existing = await isar.noteModels.get(note.id!);
    if (existing == null) {
      throw StateError('Note with id ${note.id} not found');
    }

    existing
      ..title = note.title.trim().isEmpty ? 'Untitled' : note.title.trim()
      ..content = note.content
      ..updatedAt = now
      ..isPinned = note.isPinned;

    await isar.writeTxn(() => isar.noteModels.put(existing));
    return existing.id;
  }

  @override
  Future<bool> deleteNote(int id) async {
    final isar = await _db;
    return isar.writeTxn(() => isar.noteModels.delete(id));
  }

  @override
  Future<void> deleteAllNotes() async {
    final isar = await _db;
    await isar.writeTxn(() => isar.noteModels.clear());
  }
}
