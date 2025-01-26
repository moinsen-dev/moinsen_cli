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

import 'package:protobuf/protobuf.dart' as $pb;

/// CommandType defines all available command operations that can be performed
/// through the service.
class CommandType extends $pb.ProtobufEnum {
  static const CommandType COMMAND_TYPE_UNSPECIFIED = CommandType._(0, _omitEnumNames ? '' : 'COMMAND_TYPE_UNSPECIFIED');
  static const CommandType COMMAND = CommandType._(1, _omitEnumNames ? '' : 'COMMAND');
  static const CommandType INIT = CommandType._(2, _omitEnumNames ? '' : 'INIT');
  static const CommandType LIST = CommandType._(3, _omitEnumNames ? '' : 'LIST');
  static const CommandType CD = CommandType._(4, _omitEnumNames ? '' : 'CD');
  static const CommandType EXIT = CommandType._(5, _omitEnumNames ? '' : 'EXIT');
  static const CommandType READ_FILE = CommandType._(6, _omitEnumNames ? '' : 'READ_FILE');
  static const CommandType WRITE_FILE = CommandType._(7, _omitEnumNames ? '' : 'WRITE_FILE');
  static const CommandType DELETE_FILE = CommandType._(8, _omitEnumNames ? '' : 'DELETE_FILE');
  static const CommandType CREATE_FILE = CommandType._(9, _omitEnumNames ? '' : 'CREATE_FILE');
  static const CommandType CREATE_DIR = CommandType._(10, _omitEnumNames ? '' : 'CREATE_DIR');
  static const CommandType DELETE_DIR = CommandType._(11, _omitEnumNames ? '' : 'DELETE_DIR');
  static const CommandType SEARCH = CommandType._(12, _omitEnumNames ? '' : 'SEARCH');

  static const $core.List<CommandType> values = <CommandType> [
    COMMAND_TYPE_UNSPECIFIED,
    COMMAND,
    INIT,
    LIST,
    CD,
    EXIT,
    READ_FILE,
    WRITE_FILE,
    DELETE_FILE,
    CREATE_FILE,
    CREATE_DIR,
    DELETE_DIR,
    SEARCH,
  ];

  static final $core.Map<$core.int, CommandType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CommandType? valueOf($core.int value) => _byValue[value];

  const CommandType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
