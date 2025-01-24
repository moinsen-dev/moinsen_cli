import 'package:flutter/material.dart';

import '../models/chat_message.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final TextStyle? style;
  final double? fontSize;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.style,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = (style ?? Theme.of(context).textTheme.bodyMedium!)
        .copyWith(fontSize: fontSize);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            message.isCommand ? Icons.keyboard_arrow_right : Icons.computer,
            color: message.isCommand ? Colors.blue : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: message.lines.isNotEmpty
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
          ),
        ],
      ),
    );
  }
}
