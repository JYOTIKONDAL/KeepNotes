import 'package:keep_notes/domain/repositories/note_repository.dart';
import 'package:mocktail/mocktail.dart';

/// Mock [NoteRepository] for ViewModel unit tests.
class MockNoteRepository extends Mock implements NoteRepository {}
