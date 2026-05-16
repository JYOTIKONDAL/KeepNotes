import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../di/app_providers.dart';
import '../../presentation/viewmodels/note_editor_view_model.dart';
import '../../presentation/views/screens/note_editor_screen.dart';

/// Central navigation helpers for the app.
class AppRouter {
  AppRouter._();

  /// Opens the note editor for a new or existing note.
  /// Returns `true` if the note list should refresh (save/delete succeeded).
  static Future<bool?> openNoteEditor(
    BuildContext context, {
    Note? note,
  }) {
    final repository = context.read<NoteRepository>();
    final viewModel = NoteEditorViewModel(
      repository,
      initialNote: note,
    );

    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AppProviders.noteEditorProvider(
          viewModel: viewModel,
          child: const NoteEditorScreen(),
        ),
      ),
    );
  }
}
