import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../domain/entities/note.dart';
import '../../viewmodels/notes_list_view_model.dart';
import '../widgets/empty_notes_view.dart';
import '../widgets/note_list_tile.dart';

/// Home screen: lists all notes and navigates to the editor.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openEditor(BuildContext context, {Note? note}) async {
    await AppRouter.openNoteEditor(context, note: note);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    NotesListViewModel viewModel,
    Note note,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note?'),
        content: Text(
          'Delete "${note.title.trim().isEmpty ? 'Untitled' : note.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await viewModel.deleteNote(note.id!);

    if (context.mounted && viewModel.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotesListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: _buildBody(context, viewModel),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
        tooltip: 'New note',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotesListViewModel viewModel) {
    if (viewModel.isLoading && viewModel.notes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError && viewModel.notes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                viewModel.errorMessage ?? 'Something went wrong',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: viewModel.init,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.isEmpty) {
      return const EmptyNotesView();
    }

    final notes = _sortedNotes(viewModel.notes);

    return RefreshIndicator(
      onRefresh: viewModel.init,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteListTile(
            note: note,
            onTap: () => _openEditor(context, note: note),
            onDelete: () => _confirmDelete(context, viewModel, note),
          );
        },
      ),
    );
  }

  /// Pinned notes first, then by most recently updated.
  List<Note> _sortedNotes(List<Note> notes) {
    final copy = List<Note>.from(notes);
    copy.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return copy;
  }
}
