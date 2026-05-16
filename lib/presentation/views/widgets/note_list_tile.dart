import 'package:flutter/material.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/note.dart';

class NoteListTile extends StatelessWidget {
  const NoteListTile({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = note.content.trim().isEmpty
        ? 'No additional text'
        : note.content.trim();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Row(
          children: [
            Expanded(
              child: Text(
                note.title.trim().isEmpty ? 'Untitled' : note.title,
                style: theme.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (note.isPinned)
              Icon(Icons.push_pin, size: 18, color: theme.colorScheme.primary),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatNoteDate(note.updatedAt),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
