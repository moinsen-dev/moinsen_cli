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

class CommandRequest extends $pb.GeneratedMessage {
  factory CommandRequest({
    $core.String? sessionId,
    $core.String? inputData,
    $core.bool? isInteractiveAnswer,
    $fixnum.Int64? timestamp,
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

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get inputData => $_getSZ(1);
  @$pb.TagNumber(2)
  set inputData($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasInputData() => $_has(1);
  @$pb.TagNumber(2)
  void clearInputData() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isInteractiveAnswer => $_getBF(2);
  @$pb.TagNumber(3)
  set isInteractiveAnswer($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsInteractiveAnswer() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsInteractiveAnswer() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => clearField(4);
}

class CommandResponse extends $pb.GeneratedMessage {
  factory CommandResponse({
    $core.String? sessionId,
    $core.String? outputData,
    $core.bool? isPrompt,
    $fixnum.Int64? timestamp,
    $core.String? currentFolder,
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

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get outputData => $_getSZ(1);
  @$pb.TagNumber(2)
  set outputData($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOutputData() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutputData() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isPrompt => $_getBF(2);
  @$pb.TagNumber(3)
  set isPrompt($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsPrompt() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsPrompt() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get currentFolder => $_getSZ(4);
  @$pb.TagNumber(5)
  set currentFolder($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCurrentFolder() => $_has(4);
  @$pb.TagNumber(5)
  void clearCurrentFolder() => clearField(5);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
