import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/chat_message.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final TextStyle? style;
  final double? fontSize;
  final VoidCallback? onDelete;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.style,
    this.fontSize,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = (style ?? Theme.of(context).textTheme.bodyMedium!)
        .copyWith(fontSize: fontSize);
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MMM dd');
    final isToday = message.timestamp.day == DateTime.now().day;
    final formattedTime = timeFormat.format(message.timestamp);
    final formattedDate =
        isToday ? 'Today' : dateFormat.format(message.timestamp);
    final messageLength = message.text.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Align(
        alignment:
            message.isCommand ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Card(
            color: message.isCommand
                ? Theme.of(context).colorScheme.primaryContainer
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
                        message.isCommand
                            ? Icons.keyboard_arrow_right
                            : Icons.computer,
                        size: 16,
                        color: message.isCommand
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        message.isCommand ? 'Command' : 'Response',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: message.isCommand
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const Spacer(),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 16,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  message.lines.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: message.lines.map((line) {
                            return Text(
                              line,
                              style: baseStyle.copyWith(
                                fontFamily: 'monospace',
                              ),
                            );
                          }).toList(),
                        )
                      : Text(
                          message.text,
                          style: baseStyle.copyWith(
                            fontFamily: message.isCommand ? 'monospace' : null,
                          ),
                        ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                      if (!message.isCommand &&
                          message.executionTimeMs != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${message.executionTimeMs}ms',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ],
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
