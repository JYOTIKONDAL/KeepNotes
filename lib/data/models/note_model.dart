import 'package:isar/isar.dart';

import '../../domain/entities/note.dart';

part 'note_model.g.dart';

@collection
class NoteModel {
  Id id = Isar.autoIncrement;

  late String title;

  late String content;

  late DateTime createdAt;

  late DateTime updatedAt;

  bool isPinned = false;
}

extension NoteModelMapper on NoteModel {
  Note toEntity() {
    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPinned: isPinned,
    );
  }

  static NoteModel fromEntity(Note note) {
    return NoteModel()
      ..id = note.id ?? Isar.autoIncrement
      ..title = note.title
      ..content = note.content
      ..createdAt = note.createdAt
      ..updatedAt = note.updatedAt
      ..isPinned = note.isPinned;
  }
}
