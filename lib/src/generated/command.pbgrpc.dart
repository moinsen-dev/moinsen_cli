//
//  Generated code. Do not modify.
//  source: command.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'command.pb.dart' as $0;

export 'command.pb.dart';

@$pb.GrpcServiceName('command.CommandService')
class CommandServiceClient extends $grpc.Client {
  static final _$streamCommand = $grpc.ClientMethod<$0.CommandRequest, $0.CommandResponse>(
      '/command.CommandService/StreamCommand',
      ($0.CommandRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.CommandResponse.fromBuffer(value));

  CommandServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseStream<$0.CommandResponse> streamCommand($async.Stream<$0.CommandRequest> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$streamCommand, request, options: options);
  }
}

@$pb.GrpcServiceName('command.CommandService')
abstract class CommandServiceBase extends $grpc.Service {
  $core.String get $name => 'command.CommandService';

  CommandServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CommandRequest, $0.CommandResponse>(
        'StreamCommand',
        streamCommand,
        true,
        true,
        ($core.List<$core.int> value) => $0.CommandRequest.fromBuffer(value),
        ($0.CommandResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.CommandResponse> streamCommand($grpc.ServiceCall call, $async.Stream<$0.CommandRequest> request);
}
