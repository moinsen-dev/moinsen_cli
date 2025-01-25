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

@$core.Deprecated('Use commandRequestDescriptor instead')
const CommandRequest$json = {
  '1': 'CommandRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'input_data', '3': 2, '4': 1, '5': 9, '10': 'inputData'},
    {'1': 'is_interactive_answer', '3': 3, '4': 1, '5': 8, '10': 'isInteractiveAnswer'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `CommandRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandRequestDescriptor = $convert.base64Decode(
    'Cg5Db21tYW5kUmVxdWVzdBIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSWQSHQoKaW5wdX'
    'RfZGF0YRgCIAEoCVIJaW5wdXREYXRhEjIKFWlzX2ludGVyYWN0aXZlX2Fuc3dlchgDIAEoCFIT'
    'aXNJbnRlcmFjdGl2ZUFuc3dlchIcCgl0aW1lc3RhbXAYBCABKANSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use commandResponseDescriptor instead')
const CommandResponse$json = {
  '1': 'CommandResponse',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'output_data', '3': 2, '4': 1, '5': 9, '10': 'outputData'},
    {'1': 'is_prompt', '3': 3, '4': 1, '5': 8, '10': 'isPrompt'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'current_folder', '3': 5, '4': 1, '5': 9, '10': 'currentFolder'},
  ],
};

/// Descriptor for `CommandResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandResponseDescriptor = $convert.base64Decode(
    'Cg9Db21tYW5kUmVzcG9uc2USHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEh8KC291dH'
    'B1dF9kYXRhGAIgASgJUgpvdXRwdXREYXRhEhsKCWlzX3Byb21wdBgDIAEoCFIIaXNQcm9tcHQS'
    'HAoJdGltZXN0YW1wGAQgASgDUgl0aW1lc3RhbXASJQoOY3VycmVudF9mb2xkZXIYBSABKAlSDW'
    'N1cnJlbnRGb2xkZXI=');

