class ChatMessage {
  final String text;
  final bool isCommand;
  final DateTime timestamp;
  final List<String> lines;

  ChatMessage({
    required this.text,
    required this.isCommand,
    DateTime? timestamp,
    List<String>? lines,
  })  : timestamp = timestamp ?? DateTime.now(),
        lines = lines ?? [text];
}
