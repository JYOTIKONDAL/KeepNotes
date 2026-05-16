import 'package:keep_notes/domain/entities/note.dart';

/// Factory helpers for note test data.
class NoteFixtures {
  NoteFixtures._();

  static final DateTime _baseTime = DateTime(2026, 5, 16, 12, 0);

  static Note sample({
    int? id,
    String title = 'Test title',
    String content = 'Test content',
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isPinned = false,
  }) {
    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt ?? _baseTime,
      updatedAt: updatedAt ?? _baseTime,
      isPinned: isPinned,
    );
  }

  static Note newNote({
    String title = '',
    String content = '',
    bool isPinned = false,
  }) {
    return Note(
      title: title,
      content: content,
      createdAt: _baseTime,
      updatedAt: _baseTime,
      isPinned: isPinned,
    );
  }

  static List<Note> sampleList() => [
        sample(id: 1, title: 'First'),
        sample(id: 2, title: 'Second', isPinned: true),
      ];
}
