import 'dart:async';

import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import 'base_view_model.dart';

/// ViewModel for the notes list screen.
class NotesListViewModel extends BaseViewModel {
  NotesListViewModel(this._repository);

  final NoteRepository _repository;

  List<Note> _notes = [];
  StreamSubscription<List<Note>>? _subscription;

  List<Note> get notes => List.unmodifiable(_notes);

  bool get isEmpty => _notes.isEmpty && !isLoading;

  Future<void> init() async {
    setLoading(true);
    clearError();

    await _subscription?.cancel();
    _subscription = _repository.watchNotes().listen(
      (notes) {
        _notes = notes;
        setLoading(false);
        notifyListeners();
      },
      onError: (Object error) {
        setLoading(false);
        setError(error.toString());
      },
    );
  }

  Future<void> deleteNote(int id) async {
    try {
      clearError();
      await _repository.deleteNote(id);
    } catch (e) {
      setError('Failed to delete note: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
