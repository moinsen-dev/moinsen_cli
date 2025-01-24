class ChatMessage {
  final String text;
  final bool isCommand;
  final DateTime timestamp;
  final List<String> lines;
  final int? executionTimeMs; // Execution time in milliseconds

  ChatMessage({
    required this.text,
    required this.isCommand,
    DateTime? timestamp,
    List<String>? lines,
    this.executionTimeMs,
  })  : timestamp = timestamp ?? DateTime.now(),
        lines = lines ?? [text];
}
