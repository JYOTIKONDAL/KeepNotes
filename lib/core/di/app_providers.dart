import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/datasources/local/isar_service.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/repositories/note_repository.dart';
import '../../presentation/viewmodels/note_editor_view_model.dart';
import '../../presentation/viewmodels/notes_list_view_model.dart';

/// Registers app-wide dependencies and ViewModels.
class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<IsarService>(create: (_) => IsarService()),
        ProxyProvider<IsarService, NoteRepository>(
          update: (_, isarService, _) => NoteRepositoryImpl(isarService),
        ),
        ChangeNotifierProvider<NotesListViewModel>(
          create: (context) =>
              NotesListViewModel(context.read<NoteRepository>())..init(),
        ),
      ],
      child: child,
    );
  }

  /// Creates a [NoteEditorViewModel] for the note editor route.
  static Widget noteEditorProvider({
    required NoteEditorViewModel viewModel,
    required Widget child,
  }) {
    return ChangeNotifierProvider<NoteEditorViewModel>.value(
      value: viewModel,
      child: child,
    );
  }
}
