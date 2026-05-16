import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import 'base_view_model.dart';

/// ViewModel for creating and editing a single note.
class NoteEditorViewModel extends BaseViewModel {
  NoteEditorViewModel(this._repository, {Note? initialNote})
      : _note = initialNote ??
            Note(
              title: '',
              content: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

  final NoteRepository _repository;
  Note _note;

  Note get note => _note;
  bool get isEditing => !_note.isNew;

  void updateTitle(String title) {
    _note = _note.copyWith(title: title);
    notifyListeners();
  }

  void updateContent(String content) {
    _note = _note.copyWith(content: content);
    notifyListeners();
  }

  void togglePinned() {
    _note = _note.copyWith(isPinned: !_note.isPinned);
    notifyListeners();
  }

  Future<bool> save() async {
    if (_note.title.trim().isEmpty && _note.content.trim().isEmpty) {
      setError('Note cannot be empty');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      final id = await _repository.saveNote(_note);
      _note = _note.copyWith(id: id);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError('Failed to save note: $e');
      return false;
    }
  }

  Future<bool> delete() async {
    if (_note.isNew) return true;

    setLoading(true);
    clearError();

    try {
      await _repository.deleteNote(_note.id!);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError('Failed to delete note: $e');
      return false;
    }
  }
}
