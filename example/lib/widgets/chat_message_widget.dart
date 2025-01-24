import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/chat_message.dart';
import '../models/command_history.dart';
import '../providers/command_history_provider.dart';

class ChatMessageWidget extends ConsumerStatefulWidget {
  final ChatMessage message;
  final TextStyle? style;
  final double? fontSize;
  final VoidCallback? onDelete;
  final Function(String)? onEdit;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.style,
    this.fontSize,
    this.onDelete,
    this.onEdit,
  });

  @override
  ConsumerState<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends ConsumerState<ChatMessageWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _favoriteAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _favoriteAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _copyToClipboard() {
    final textToCopy = widget.message.lines.isNotEmpty
        ? widget.message.lines.join('\n')
        : widget.message.text;
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = (widget.style ?? Theme.of(context).textTheme.bodyMedium!)
        .copyWith(fontSize: widget.fontSize);
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MMM dd');
    final isToday = widget.message.timestamp.day == DateTime.now().day;
    final formattedTime = timeFormat.format(widget.message.timestamp);
    final formattedDate =
        isToday ? 'Today' : dateFormat.format(widget.message.timestamp);
    final messageLength = widget.message.text.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Align(
        alignment: widget.message.isCommand
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Card(
            color: widget.message.isCommand
                ? Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.9)
                : Theme.of(context).brightness == Brightness.light
                    ? Color(0xFFE8E5F0)
                    : Theme.of(context).colorScheme.secondaryContainer,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.message.isCommand
                            ? Icons.keyboard_arrow_right
                            : Icons.computer,
                        size: 16,
                        color: widget.message.isCommand
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.message.isCommand
                            ? 'Command'
                            : 'Response${widget.message.lines.isNotEmpty ? ' (${widget.message.lines.length} lines)' : ''}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.message.isCommand
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const Spacer(),
                      if (widget.message.isCommand) ...[
                        Consumer(
                          builder: (context, ref, child) {
                            final historyAsync =
                                ref.watch(commandHistoryProvider);

                            return historyAsync.when(
                              data: (history) {
                                final existingCmd = history.firstWhere(
                                  (cmd) => cmd.command == widget.message.text,
                                  orElse: () => CommandHistory(
                                    command: widget.message.text,
                                    timestamp: DateTime.now(),
                                  ),
                                );
                                final isFavorite = existingCmd.isFavorite;

                                return ScaleTransition(
                                  scale: Tween<double>(
                                    begin: 1.0,
                                    end: 0.8,
                                  ).animate(_favoriteAnimation),
                                  child: IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.star
                                          : Icons.star_border_outlined,
                                      size: 16,
                                      color: isFavorite ? Colors.amber : null,
                                    ),
                                    onPressed: () async {
                                      _animationController.forward(from: 0.0);
                                      if (existingCmd.id != null) {
                                        await ref
                                            .read(
                                                commandHistoryProvider.notifier)
                                            .toggleFavorite(existingCmd.id!);
                                      } else {
                                        await ref
                                            .read(
                                                commandHistoryProvider.notifier)
                                            .addCommand(widget.message.text);
                                      }
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    splashRadius: 16,
                                    tooltip: isFavorite
                                        ? 'Remove from favorites'
                                        : 'Add to favorites',
                                  ),
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          },
                        ),
                      ],
                      if (widget.message.isCommand && widget.onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          onPressed: () => widget.onEdit!(widget.message.text),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 16,
                          tooltip: 'Edit command',
                        ),
                      IconButton(
                        icon: const Icon(Icons.copy_outlined, size: 16),
                        onPressed: _copyToClipboard,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 16,
                        tooltip: 'Copy to clipboard',
                      ),
                      if (widget.onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16),
                          onPressed: widget.onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 16,
                          tooltip: 'Delete message',
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (!widget.message.isCommand &&
                      widget.message.lines.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: widget.message.lines
                              .take(
                                  _isExpanded ? widget.message.lines.length : 3)
                              .map((line) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                line,
                                style: baseStyle.copyWith(
                                  fontFamily: 'monospace',
                                ),
                                textAlign: TextAlign.left,
                              ),
                            );
                          }).toList(),
                        ),
                        if (widget.message.lines.length > 3)
                          InkWell(
                            onTap: _toggleExpand,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? const Color(0xFFEEEEEE)
                                    : Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isExpanded ? 'Show less' : 'Show more',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      RotationTransition(
                                        turns: Tween(begin: 0.0, end: 0.5)
                                            .animate(_expandAnimation),
                                        child: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message.text,
                          style: baseStyle.copyWith(
                            fontFamily:
                                widget.message.isCommand ? 'monospace' : null,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFFEEEEEE)
                                    : Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  '$formattedDate $formattedTime',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$messageLength chars',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (!widget.message.isCommand &&
                                    widget.message.executionTimeMs != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '${widget.message.executionTimeMs}ms',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
