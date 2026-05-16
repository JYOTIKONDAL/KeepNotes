import 'package:flutter/material.dart';

class EmptyNotesView extends StatelessWidget {
  const EmptyNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 72,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first note',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
