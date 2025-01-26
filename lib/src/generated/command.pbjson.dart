//
//  Generated code. Do not modify.
//  source: command.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use commandTypeDescriptor instead')
const CommandType$json = {
  '1': 'CommandType',
  '2': [
    {'1': 'COMMAND_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'COMMAND', '2': 1},
    {'1': 'INIT', '2': 2},
    {'1': 'LIST', '2': 3},
    {'1': 'CD', '2': 4},
    {'1': 'EXIT', '2': 5},
    {'1': 'READ_FILE', '2': 6},
    {'1': 'WRITE_FILE', '2': 7},
    {'1': 'DELETE_FILE', '2': 8},
    {'1': 'CREATE_FILE', '2': 9},
    {'1': 'CREATE_DIR', '2': 10},
    {'1': 'DELETE_DIR', '2': 11},
    {'1': 'SEARCH', '2': 12},
  ],
};

/// Descriptor for `CommandType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List commandTypeDescriptor = $convert.base64Decode(
    'CgtDb21tYW5kVHlwZRIcChhDT01NQU5EX1RZUEVfVU5TUEVDSUZJRUQQABILCgdDT01NQU5EEA'
    'ESCAoESU5JVBACEggKBExJU1QQAxIGCgJDRBAEEggKBEVYSVQQBRINCglSRUFEX0ZJTEUQBhIO'
    'CgpXUklURV9GSUxFEAcSDwoLREVMRVRFX0ZJTEUQCBIPCgtDUkVBVEVfRklMRRAJEg4KCkNSRU'
    'FURV9ESVIQChIOCgpERUxFVEVfRElSEAsSCgoGU0VBUkNIEAw=');

@$core.Deprecated('Use commandRequestDescriptor instead')
const CommandRequest$json = {
  '1': 'CommandRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'input_data', '3': 2, '4': 1, '5': 9, '10': 'inputData'},
    {'1': 'is_interactive_answer', '3': 3, '4': 1, '5': 8, '10': 'isInteractiveAnswer'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'command_type', '3': 5, '4': 1, '5': 14, '6': '.command.CommandType', '10': 'commandType'},
    {'1': 'streaming_mode', '3': 6, '4': 1, '5': 8, '10': 'streamingMode'},
    {'1': 'path', '3': 7, '4': 1, '5': 9, '10': 'path'},
    {'1': 'content', '3': 8, '4': 1, '5': 9, '10': 'content'},
    {'1': 'search_query', '3': 9, '4': 1, '5': 9, '10': 'searchQuery'},
  ],
};

/// Descriptor for `CommandRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandRequestDescriptor = $convert.base64Decode(
    'Cg5Db21tYW5kUmVxdWVzdBIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSWQSHQoKaW5wdX'
    'RfZGF0YRgCIAEoCVIJaW5wdXREYXRhEjIKFWlzX2ludGVyYWN0aXZlX2Fuc3dlchgDIAEoCFIT'
    'aXNJbnRlcmFjdGl2ZUFuc3dlchIcCgl0aW1lc3RhbXAYBCABKANSCXRpbWVzdGFtcBI3Cgxjb2'
    '1tYW5kX3R5cGUYBSABKA4yFC5jb21tYW5kLkNvbW1hbmRUeXBlUgtjb21tYW5kVHlwZRIlCg5z'
    'dHJlYW1pbmdfbW9kZRgGIAEoCFINc3RyZWFtaW5nTW9kZRISCgRwYXRoGAcgASgJUgRwYXRoEh'
    'gKB2NvbnRlbnQYCCABKAlSB2NvbnRlbnQSIQoMc2VhcmNoX3F1ZXJ5GAkgASgJUgtzZWFyY2hR'
    'dWVyeQ==');

@$core.Deprecated('Use commandResponseDescriptor instead')
const CommandResponse$json = {
  '1': 'CommandResponse',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'output_data', '3': 2, '4': 1, '5': 9, '10': 'outputData'},
    {'1': 'is_prompt', '3': 3, '4': 1, '5': 8, '10': 'isPrompt'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'current_folder', '3': 5, '4': 1, '5': 9, '10': 'currentFolder'},
    {'1': 'command_type', '3': 6, '4': 1, '5': 14, '6': '.command.CommandType', '10': 'commandType'},
    {'1': 'is_partial', '3': 7, '4': 1, '5': 8, '10': 'isPartial'},
    {'1': 'is_complete', '3': 8, '4': 1, '5': 8, '10': 'isComplete'},
    {'1': 'success', '3': 9, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 10, '4': 1, '5': 9, '10': 'errorMessage'},
    {'1': 'file_list', '3': 11, '4': 3, '5': 11, '6': '.command.FileInfo', '10': 'fileList'},
  ],
};

/// Descriptor for `CommandResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandResponseDescriptor = $convert.base64Decode(
    'Cg9Db21tYW5kUmVzcG9uc2USHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEh8KC291dH'
    'B1dF9kYXRhGAIgASgJUgpvdXRwdXREYXRhEhsKCWlzX3Byb21wdBgDIAEoCFIIaXNQcm9tcHQS'
    'HAoJdGltZXN0YW1wGAQgASgDUgl0aW1lc3RhbXASJQoOY3VycmVudF9mb2xkZXIYBSABKAlSDW'
    'N1cnJlbnRGb2xkZXISNwoMY29tbWFuZF90eXBlGAYgASgOMhQuY29tbWFuZC5Db21tYW5kVHlw'
    'ZVILY29tbWFuZFR5cGUSHQoKaXNfcGFydGlhbBgHIAEoCFIJaXNQYXJ0aWFsEh8KC2lzX2NvbX'
    'BsZXRlGAggASgIUgppc0NvbXBsZXRlEhgKB3N1Y2Nlc3MYCSABKAhSB3N1Y2Nlc3MSIwoNZXJy'
    'b3JfbWVzc2FnZRgKIAEoCVIMZXJyb3JNZXNzYWdlEi4KCWZpbGVfbGlzdBgLIAMoCzIRLmNvbW'
    '1hbmQuRmlsZUluZm9SCGZpbGVMaXN0');

@$core.Deprecated('Use fileInfoDescriptor instead')
const FileInfo$json = {
  '1': 'FileInfo',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'is_directory', '3': 2, '4': 1, '5': 8, '10': 'isDirectory'},
    {'1': 'size', '3': 3, '4': 1, '5': 3, '10': 'size'},
    {'1': 'modified_time', '3': 4, '4': 1, '5': 3, '10': 'modifiedTime'},
  ],
};

/// Descriptor for `FileInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileInfoDescriptor = $convert.base64Decode(
    'CghGaWxlSW5mbxISCgRuYW1lGAEgASgJUgRuYW1lEiEKDGlzX2RpcmVjdG9yeRgCIAEoCFILaX'
    'NEaXJlY3RvcnkSEgoEc2l6ZRgDIAEoA1IEc2l6ZRIjCg1tb2RpZmllZF90aW1lGAQgASgDUgxt'
    'b2RpZmllZFRpbWU=');

