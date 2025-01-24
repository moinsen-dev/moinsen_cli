import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/command_history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _showOnlyFavorites = false;
  bool _favoritesFirst = true;

  @override
  Widget build(BuildContext context) {
    final commandHistory = ref.watch(commandHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Command History'),
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyFavorites ? Icons.star : Icons.star_border,
              color: _showOnlyFavorites ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() {
                _showOnlyFavorites = !_showOnlyFavorites;
              });
            },
            tooltip: 'Show only favorites',
          ),
          IconButton(
            icon: Icon(
              Icons.sort,
              color: _favoritesFirst ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() {
                _favoritesFirst = !_favoritesFirst;
              });
            },
            tooltip: 'Sort favorites first',
          ),
        ],
      ),
      body: commandHistory.when(
        data: (history) {
          var filteredHistory = _showOnlyFavorites
              ? history.where((cmd) => cmd.isFavorite).toList()
              : List.from(history);

          if (_favoritesFirst) {
            filteredHistory.sort((a, b) {
              if (a.isFavorite == b.isFavorite) {
                return b.timestamp.compareTo(a.timestamp);
              }
              return b.isFavorite ? 1 : -1;
            });
          }

          if (filteredHistory.isEmpty) {
            return Center(
              child: Text(
                _showOnlyFavorites
                    ? 'No favorite commands yet'
                    : 'No command history yet',
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredHistory.length,
            itemBuilder: (context, index) {
              final command = filteredHistory[index];
              return ListTile(
                title: Text(command.command),
                subtitle: Text(
                  command.timestamp.toLocal().toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: IconButton(
                  icon: Icon(
                    command.isFavorite ? Icons.star : Icons.star_border,
                    color: command.isFavorite ? Colors.amber : null,
                  ),
                  onPressed: () {
                    ref
                        .read(commandHistoryProvider.notifier)
                        .toggleFavorite(command.id!);
                  },
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
