//
//  Generated code. Do not modify.
//  source: command.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'command.pbenum.dart';

export 'command.pbenum.dart';

/// CommandRequest represents a command to be executed by the server.
/// It contains all necessary information to process any supported command type.
class CommandRequest extends $pb.GeneratedMessage {
  factory CommandRequest({
    $core.String? sessionId,
    $core.String? inputData,
    $core.bool? isInteractiveAnswer,
    $fixnum.Int64? timestamp,
    CommandType? commandType,
    $core.bool? streamingMode,
    $core.String? path,
    $core.String? content,
    $core.String? searchQuery,
  }) {
    final $result = create();
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    if (inputData != null) {
      $result.inputData = inputData;
    }
    if (isInteractiveAnswer != null) {
      $result.isInteractiveAnswer = isInteractiveAnswer;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (commandType != null) {
      $result.commandType = commandType;
    }
    if (streamingMode != null) {
      $result.streamingMode = streamingMode;
    }
    if (path != null) {
      $result.path = path;
    }
    if (content != null) {
      $result.content = content;
    }
    if (searchQuery != null) {
      $result.searchQuery = searchQuery;
    }
    return $result;
  }
  CommandRequest._() : super();
  factory CommandRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CommandRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CommandRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'command'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'inputData')
    ..aOB(3, _omitFieldNames ? '' : 'isInteractiveAnswer')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..e<CommandType>(5, _omitFieldNames ? '' : 'commandType', $pb.PbFieldType.OE, defaultOrMaker: CommandType.COMMAND_TYPE_UNSPECIFIED, valueOf: CommandType.valueOf, enumValues: CommandType.values)
    ..aOB(6, _omitFieldNames ? '' : 'streamingMode')
    ..aOS(7, _omitFieldNames ? '' : 'path')
    ..aOS(8, _omitFieldNames ? '' : 'content')
    ..aOS(9, _omitFieldNames ? '' : 'searchQuery')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CommandRequest clone() => CommandRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CommandRequest copyWith(void Function(CommandRequest) updates) => super.copyWith((message) => updates(message as CommandRequest)) as CommandRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommandRequest create() => CommandRequest._();
  CommandRequest createEmptyInstance() => create();
  static $pb.PbList<CommandRequest> createRepeated() => $pb.PbList<CommandRequest>();
  @$core.pragma('dart2js:noInline')
  static CommandRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommandRequest>(create);
  static CommandRequest? _defaultInstance;

  /// Unique identifier for the client session
  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => clearField(1);

  /// Raw command input or additional data
  @$pb.TagNumber(2)
  $core.String get inputData => $_getSZ(1);
  @$pb.TagNumber(2)
  set inputData($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasInputData() => $_has(1);
  @$pb.TagNumber(2)
  void clearInputData() => clearField(2);

  /// Indicates if this is a response to a prompt
  @$pb.TagNumber(3)
  $core.bool get isInteractiveAnswer => $_getBF(2);
  @$pb.TagNumber(3)
  set isInteractiveAnswer($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsInteractiveAnswer() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsInteractiveAnswer() => clearField(3);

  /// Request timestamp in milliseconds since epoch
  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => clearField(4);

  /// Type of command to execute
  @$pb.TagNumber(5)
  CommandType get commandType => $_getN(4);
  @$pb.TagNumber(5)
  set commandType(CommandType v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasCommandType() => $_has(4);
  @$pb.TagNumber(5)
  void clearCommandType() => clearField(5);

  /// Determines if command output should be streamed line by line
  @$pb.TagNumber(6)
  $core.bool get streamingMode => $_getBF(5);
  @$pb.TagNumber(6)
  set streamingMode($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasStreamingMode() => $_has(5);
  @$pb.TagNumber(6)
  void clearStreamingMode() => clearField(6);

  /// Command-specific fields
  /// Target path for file/directory operations
  @$pb.TagNumber(7)
  $core.String get path => $_getSZ(6);
  @$pb.TagNumber(7)
  set path($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasPath() => $_has(6);
  @$pb.TagNumber(7)
  void clearPath() => clearField(7);

  /// Content for write/create operations
  @$pb.TagNumber(8)
  $core.String get content => $_getSZ(7);
  @$pb.TagNumber(8)
  set content($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasContent() => $_has(7);
  @$pb.TagNumber(8)
  void clearContent() => clearField(8);

  /// Query string for search operations
  @$pb.TagNumber(9)
  $core.String get searchQuery => $_getSZ(8);
  @$pb.TagNumber(9)
  set searchQuery($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasSearchQuery() => $_has(8);
  @$pb.TagNumber(9)
  void clearSearchQuery() => clearField(9);
}

/// CommandResponse represents the server's response to a command request.
/// It includes the command result and any relevant metadata.
class CommandResponse extends $pb.GeneratedMessage {
  factory CommandResponse({
    $core.String? sessionId,
    $core.String? outputData,
    $core.bool? isPrompt,
    $fixnum.Int64? timestamp,
    $core.String? currentFolder,
    CommandType? commandType,
    $core.bool? isPartial,
    $core.bool? isComplete,
    $core.bool? success,
    $core.String? errorMessage,
    $core.Iterable<FileInfo>? fileList,
  }) {
    final $result = create();
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    if (outputData != null) {
      $result.outputData = outputData;
    }
    if (isPrompt != null) {
      $result.isPrompt = isPrompt;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (currentFolder != null) {
      $result.currentFolder = currentFolder;
    }
    if (commandType != null) {
      $result.commandType = commandType;
    }
    if (isPartial != null) {
      $result.isPartial = isPartial;
    }
    if (isComplete != null) {
      $result.isComplete = isComplete;
    }
    if (success != null) {
      $result.success = success;
    }
    if (errorMessage != null) {
      $result.errorMessage = errorMessage;
    }
    if (fileList != null) {
      $result.fileList.addAll(fileList);
    }
    return $result;
  }
  CommandResponse._() : super();
  factory CommandResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CommandResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CommandResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'command'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'outputData')
    ..aOB(3, _omitFieldNames ? '' : 'isPrompt')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..aOS(5, _omitFieldNames ? '' : 'currentFolder')
    ..e<CommandType>(6, _omitFieldNames ? '' : 'commandType', $pb.PbFieldType.OE, defaultOrMaker: CommandType.COMMAND_TYPE_UNSPECIFIED, valueOf: CommandType.valueOf, enumValues: CommandType.values)
    ..aOB(7, _omitFieldNames ? '' : 'isPartial')
    ..aOB(8, _omitFieldNames ? '' : 'isComplete')
    ..aOB(9, _omitFieldNames ? '' : 'success')
    ..aOS(10, _omitFieldNames ? '' : 'errorMessage')
    ..pc<FileInfo>(11, _omitFieldNames ? '' : 'fileList', $pb.PbFieldType.PM, subBuilder: FileInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CommandResponse clone() => CommandResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CommandResponse copyWith(void Function(CommandResponse) updates) => super.copyWith((message) => updates(message as CommandResponse)) as CommandResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommandResponse create() => CommandResponse._();
  CommandResponse createEmptyInstance() => create();
  static $pb.PbList<CommandResponse> createRepeated() => $pb.PbList<CommandResponse>();
  @$core.pragma('dart2js:noInline')
  static CommandResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommandResponse>(create);
  static CommandResponse? _defaultInstance;

  /// Session ID matching the request
  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => clearField(1);

  /// Command output or response data
  @$pb.TagNumber(2)
  $core.String get outputData => $_getSZ(1);
  @$pb.TagNumber(2)
  set outputData($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOutputData() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutputData() => clearField(2);

  /// Indicates if this response requires user input
  @$pb.TagNumber(3)
  $core.bool get isPrompt => $_getBF(2);
  @$pb.TagNumber(3)
  set isPrompt($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsPrompt() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsPrompt() => clearField(3);

  /// Response timestamp in milliseconds since epoch
  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => clearField(4);

  /// Current working directory after command execution
  @$pb.TagNumber(5)
  $core.String get currentFolder => $_getSZ(4);
  @$pb.TagNumber(5)
  set currentFolder($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCurrentFolder() => $_has(4);
  @$pb.TagNumber(5)
  void clearCurrentFolder() => clearField(5);

  /// Echo of the command type being processed
  @$pb.TagNumber(6)
  CommandType get commandType => $_getN(5);
  @$pb.TagNumber(6)
  set commandType(CommandType v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasCommandType() => $_has(5);
  @$pb.TagNumber(6)
  void clearCommandType() => clearField(6);

  /// Indicates if this is a partial response (for streaming mode)
  @$pb.TagNumber(7)
  $core.bool get isPartial => $_getBF(6);
  @$pb.TagNumber(7)
  set isPartial($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasIsPartial() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsPartial() => clearField(7);

  /// Indicates if this is the final response in a stream
  @$pb.TagNumber(8)
  $core.bool get isComplete => $_getBF(7);
  @$pb.TagNumber(8)
  set isComplete($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasIsComplete() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsComplete() => clearField(8);

  /// Response-specific fields
  /// Indicates if the command was successful
  @$pb.TagNumber(9)
  $core.bool get success => $_getBF(8);
  @$pb.TagNumber(9)
  set success($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasSuccess() => $_has(8);
  @$pb.TagNumber(9)
  void clearSuccess() => clearField(9);

  /// Error description if command failed
  @$pb.TagNumber(10)
  $core.String get errorMessage => $_getSZ(9);
  @$pb.TagNumber(10)
  set errorMessage($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasErrorMessage() => $_has(9);
  @$pb.TagNumber(10)
  void clearErrorMessage() => clearField(10);

  /// List of files/directories for LIST command
  @$pb.TagNumber(11)
  $core.List<FileInfo> get fileList => $_getList(10);
}

/// FileInfo contains metadata about a file or directory.
/// Used primarily in LIST command responses.
class FileInfo extends $pb.GeneratedMessage {
  factory FileInfo({
    $core.String? name,
    $core.bool? isDirectory,
    $fixnum.Int64? size,
    $fixnum.Int64? modifiedTime,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (isDirectory != null) {
      $result.isDirectory = isDirectory;
    }
    if (size != null) {
      $result.size = size;
    }
    if (modifiedTime != null) {
      $result.modifiedTime = modifiedTime;
    }
    return $result;
  }
  FileInfo._() : super();
  factory FileInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FileInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FileInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'command'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOB(2, _omitFieldNames ? '' : 'isDirectory')
    ..aInt64(3, _omitFieldNames ? '' : 'size')
    ..aInt64(4, _omitFieldNames ? '' : 'modifiedTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FileInfo clone() => FileInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FileInfo copyWith(void Function(FileInfo) updates) => super.copyWith((message) => updates(message as FileInfo)) as FileInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileInfo create() => FileInfo._();
  FileInfo createEmptyInstance() => create();
  static $pb.PbList<FileInfo> createRepeated() => $pb.PbList<FileInfo>();
  @$core.pragma('dart2js:noInline')
  static FileInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileInfo>(create);
  static FileInfo? _defaultInstance;

  /// Name of the file or directory
  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  /// True if entry is a directory
  @$pb.TagNumber(2)
  $core.bool get isDirectory => $_getBF(1);
  @$pb.TagNumber(2)
  set isDirectory($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIsDirectory() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsDirectory() => clearField(2);

  /// Size in bytes (0 for directories)
  @$pb.TagNumber(3)
  $fixnum.Int64 get size => $_getI64(2);
  @$pb.TagNumber(3)
  set size($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearSize() => clearField(3);

  /// Last modified time in milliseconds since epoch
  @$pb.TagNumber(4)
  $fixnum.Int64 get modifiedTime => $_getI64(3);
  @$pb.TagNumber(4)
  set modifiedTime($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasModifiedTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearModifiedTime() => clearField(4);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
