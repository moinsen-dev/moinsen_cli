# Moinsen CLI Client Implementation Guide

This guide provides detailed information about implementing a client for the Moinsen CLI gRPC service. It includes explanations of all available commands and example code for implementation.

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Connection Setup](#connection-setup)
- [Command Types](#command-types)
- [Implementation Examples](#implementation-examples)
- [Response Handling](#response-handling)
- [Error Handling](#error-handling)

## Overview

The Moinsen CLI provides a gRPC-based service for executing various file system and shell commands. It supports bidirectional streaming, allowing for interactive command execution and real-time feedback.

## Prerequisites

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  grpc: ^3.0.0
  protobuf: ^3.0.0
  fixnum: ^1.0.0  # For Int64 support
```

## Connection Setup

Here's how to establish a connection to the Moinsen CLI service:

```dart
import 'package:grpc/grpc.dart';
import 'package:moinsen_cli/src/generated/command.pbgrpc.dart';

class MoinsenClient {
  late final ClientChannel channel;
  late final CommandServiceClient stub;

  Future<void> connect(String host, int port, {String? secret}) async {
    channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    // Create the stub with optional authentication
    final metadata = secret != null ? {'secret': secret} : {};
    stub = CommandServiceClient(
      channel,
      options: CallOptions(metadata: metadata),
    );
  }

  Future<void> disconnect() async {
    await channel.shutdown();
  }
}
```

## Command Types

### 1. Shell Command Execution
Execute shell commands with real-time output streaming.

```dart
Future<void> executeCommand(String command) async {
  final request = CommandRequest()
    ..sessionId = 'your-session-id'
    ..inputData = command
    ..commandType = CommandType.COMMAND
    ..streamingMode = true
    ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);

  try {
    final response = stub.streamCommand(Stream.value(request));
    await for (final result in response) {
      if (result.outputData.isNotEmpty) {
        print(result.outputData);
      }
      if (result.isComplete) break;
    }
  } catch (e) {
    print('Error executing command: $e');
  }
}
```

### 2. Directory Operations

#### List Directory Contents
```dart
Future<List<FileInfo>> listDirectory(String path) async {
  final request = CommandRequest()
    ..sessionId = 'your-session-id'
    ..commandType = CommandType.LIST
    ..path = path
    ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);

  try {
    final response = await stub.streamCommand(Stream.value(request)).first;
    return response.fileList;
  } catch (e) {
    print('Error listing directory: $e');
    return [];
  }
}
```

#### Change Directory
```dart
Future<bool> changeDirectory(String path) async {
  final request = CommandRequest()
    ..sessionId = 'your-session-id'
    ..commandType = CommandType.CD
    ..path = path
    ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);

  try {
    final response = await stub.streamCommand(Stream.value(request)).first;
    return response.success;
  } catch (e) {
    print('Error changing directory: $e');
    return false;
  }
}
```

### 3. File Operations

#### Read File
```dart
Future<String> readFile(String path) async {
  final request = CommandRequest()
    ..sessionId = 'your-session-id'
    ..commandType = CommandType.READ_FILE
    ..path = path
    ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);

  try {
    final response = await stub.streamCommand(Stream.value(request)).first;
    return response.outputData;
  } catch (e) {
    print('Error reading file: $e');
    return '';
  }
}
```

#### Write File
```dart
Future<bool> writeFile(String path, String content) async {
  final request = CommandRequest()
    ..sessionId = 'your-session-id'
    ..commandType = CommandType.WRITE_FILE
    ..path = path
    ..content = content
    ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);

  try {
    final response = await stub.streamCommand(Stream.value(request)).first;
    return response.success;
  } catch (e) {
    print('Error writing file: $e');
    return false;
  }
}
```

#### Create File
```dart
Future<bool> createFile(String path, [String content = '']) async {
  final request = CommandRequest()
    ..sessionId = 'your-session-id'
    ..commandType = CommandType.CREATE_FILE
    ..path = path
    ..content = content
    ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);

  try {
    final response = await stub.streamCommand(Stream.value(request)).first;
    return response.success;
  } catch (e) {
    print('Error creating file: $e');
    return false;
  }
}
```

#### Delete File
```dart
Future<bool> deleteFile(String path) async {
  final request = CommandRequest()
    ..sessionId = 'your-session-id'
    ..commandType = CommandType.DELETE_FILE
    ..path = path
    ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);

  try {
    final response = await stub.streamCommand(Stream.value(request)).first;
    return response.success;
  } catch (e) {
    print('Error deleting file: $e');
    return false;
  }
}
```

### 4. Directory Management

#### Create Directory
```dart
Future<bool> createDirectory(String path) async {
  final request = CommandRequest()
    ..sessionId = 'your-session-id'
    ..commandType = CommandType.CREATE_DIR
    ..path = path
    ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);

  try {
    final response = await stub.streamCommand(Stream.value(request)).first;
    return response.success;
  } catch (e) {
    print('Error creating directory: $e');
    return false;
  }
}
```

#### Delete Directory
```dart
Future<bool> deleteDirectory(String path) async {
  final request = CommandRequest()
    ..sessionId = 'your-session-id'
    ..commandType = CommandType.DELETE_DIR
    ..path = path
    ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);

  try {
    final response = await stub.streamCommand(Stream.value(request)).first;
    return response.success;
  } catch (e) {
    print('Error deleting directory: $e');
    return false;
  }
}
```

### 5. Search Operations
```dart
Future<List<FileInfo>> searchFiles(String query) async {
  final request = CommandRequest()
    ..sessionId = 'your-session-id'
    ..commandType = CommandType.SEARCH
    ..searchQuery = query
    ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);

  try {
    final response = await stub.streamCommand(Stream.value(request)).first;
    return response.fileList;
  } catch (e) {
    print('Error searching files: $e');
    return [];
  }
}
```

## Response Handling

All commands return a `CommandResponse` object with the following fields:

```dart
class CommandResponse {
  String sessionId;        // Session identifier
  String outputData;       // Command output or response data
  bool isPrompt;          // Indicates if user input is required
  Int64 timestamp;        // Response timestamp
  String currentFolder;   // Current working directory
  CommandType commandType; // Echo of the command type
  bool isPartial;         // Indicates partial response (streaming)
  bool isComplete;        // Indicates final response
  bool success;           // Operation success status
  String errorMessage;    // Error description if failed
  List<FileInfo> fileList; // File/directory listing results
}
```

## Error Handling

Implement proper error handling for gRPC-specific errors:

```dart
Future<void> handleGrpcError(dynamic error) async {
  if (error is GrpcError) {
    switch (error.code) {
      case StatusCode.unavailable:
        print('Service unavailable. Please check your connection.');
        break;
      case StatusCode.unauthenticated:
        print('Authentication failed. Please check your credentials.');
        break;
      case StatusCode.permissionDenied:
        print('Permission denied for the requested operation.');
        break;
      default:
        print('gRPC error: ${error.message}');
    }
  } else {
    print('Unexpected error: $error');
  }
}
```

## Complete Client Example

Here's a complete example of a client implementation:

```dart
class MoinsenClient {
  late final ClientChannel channel;
  late final CommandServiceClient stub;
  final String sessionId;

  MoinsenClient() : sessionId = 'session-${DateTime.now().millisecondsSinceEpoch}';

  Future<void> connect(String host, int port, {String? secret}) async {
    channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    final metadata = secret != null ? {'secret': secret} : {};
    stub = CommandServiceClient(
      channel,
      options: CallOptions(metadata: metadata),
    );
  }

  CommandRequest _createRequest(
    CommandType type, {
    String? path,
    String? content,
    String? searchQuery,
    bool streamingMode = false,
  }) {
    return CommandRequest()
      ..sessionId = sessionId
      ..commandType = type
      ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch)
      ..path = path ?? ''
      ..content = content ?? ''
      ..searchQuery = searchQuery ?? ''
      ..streamingMode = streamingMode;
  }

  Future<Stream<CommandResponse>> executeCommand(String command) async {
    final request = _createRequest(
      CommandType.COMMAND,
      content: command,
      streamingMode: true,
    );
    return stub.streamCommand(Stream.value(request));
  }

  Future<List<FileInfo>> listDirectory(String path) async {
    final request = _createRequest(CommandType.LIST, path: path);
    final response = await stub.streamCommand(Stream.value(request)).first;
    return response.fileList;
  }

  Future<void> disconnect() async {
    final request = _createRequest(CommandType.EXIT);
    try {
      await stub.streamCommand(Stream.value(request)).first;
    } finally {
      await channel.shutdown();
    }
  }

  // Add other methods for file operations, directory management, etc.
}

// Usage example:
void main() async {
  final client = MoinsenClient();

  try {
    await client.connect('localhost', 50051);

    // List directory contents
    final files = await client.listDirectory('.');
    for (final file in files) {
      print('${file.name} (${file.isDirectory ? "DIR" : "FILE"})');
    }

    // Execute a shell command
    final cmdStream = await client.executeCommand('ls -la');
    await for (final response in cmdStream) {
      if (response.outputData.isNotEmpty) {
        print(response.outputData);
      }
      if (response.isComplete) break;
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    await client.disconnect();
  }
}
```

This guide covers the basic implementation of a Moinsen CLI client. For more specific use cases or advanced features, please refer to the API documentation or contact the maintainers.