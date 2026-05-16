import '../entities/note.dart';

/// Contract for note persistence operations.
abstract class NoteRepository {
  Stream<List<Note>> watchNotes();

  Future<List<Note>> getAllNotes();

  Future<Note?> getNoteById(int id);

  Future<int> saveNote(Note note);

  Future<bool> deleteNote(int id);

  Future<void> deleteAllNotes();
}
