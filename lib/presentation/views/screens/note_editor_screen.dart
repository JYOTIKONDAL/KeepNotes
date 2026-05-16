import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/note_editor_view_model.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<NoteEditorViewModel>();
    _titleController = TextEditingController(text: viewModel.note.title);
    _contentController = TextEditingController(text: viewModel.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final viewModel = context.read<NoteEditorViewModel>();
    final saved = await viewModel.save();
    if (!context.mounted) return;

    if (saved) {
      Navigator.of(context).pop(true);
    } else if (viewModel.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage!)),
      );
    }
  }

  Future<void> _delete(BuildContext context) async {
    final viewModel = context.read<NoteEditorViewModel>();
    if (!viewModel.isEditing) {
      Navigator.of(context).pop();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This action cannot be undone.'),
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

    final deleted = await viewModel.delete();
    if (!context.mounted) return;

    if (deleted) {
      Navigator.of(context).pop(true);
    } else if (viewModel.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NoteEditorViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.isEditing ? 'Edit note' : 'New note'),
        actions: [
          IconButton(
            icon: Icon(
              viewModel.note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            ),
            onPressed: viewModel.togglePinned,
          ),
          if (viewModel.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: viewModel.isLoading ? null : () => _delete(context),
            ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: viewModel.isLoading ? null : () => _save(context),
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).textTheme.headlineSmall,
                    onChanged: viewModel.updateTitle,
                  ),
                  const Divider(),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        hintText: 'Take a note...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      onChanged: viewModel.updateContent,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
