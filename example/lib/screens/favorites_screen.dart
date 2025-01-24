import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/command_history_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandHistory = ref.watch(commandHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Commands'),
      ),
      body: commandHistory.when(
        data: (history) {
          final favorites = history.where((cmd) => cmd.isFavorite).toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (favorites.isEmpty) {
            return const Center(
              child: Text('No favorite commands yet'),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final command = favorites[index];
              return ListTile(
                title: Text(command.command),
                subtitle: Text(
                  command.timestamp.toLocal().toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        ref
                            .read(commandHistoryProvider.notifier)
                            .toggleFavorite(command.id!);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        // TODO: Implement command execution
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
