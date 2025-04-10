import 'dart:async';
import 'package:grpc/grpc.dart';
import '../generated/hello.pbgrpc.dart';
import 'android_bridge.dart';

class HelloServiceImpl extends HelloServiceBase {
  @override
  Stream<HelloResponse> sayHelloStream(ServiceCall call, HelloRequest request) async* {
    if (request.numMessages <= 0) {
      throw GrpcError.invalidArgument('numMessages must be greater than 0');
    }

    try {
      // Start the Android service call
      await AndroidBridge.invokeSayHelloStream(request.numMessages);
      
      // Register for callbacks and forward them to the gRPC stream
      await for (final message in AndroidBridge.registerResultCallback()) {
        if (message == 'Done') {
          break;
        }
        yield HelloResponse()..message = message;
      }
    } catch (e) {
      throw GrpcError.internal('Error processing request: $e');
    } finally {
      AndroidBridge.dispose();
    }
  }
}

class GrpcServer {
  Server? _server;

  Future<void> start() async {
    if (_server != null) {
      throw Exception('Server is already running');
    }
    _server = Server([HelloServiceImpl()]);
    await _server!.serve(port: 50051);
    print('Server listening on port ${_server!.port}...');
  }

  Future<void> stop() async {
    if (_server == null) {
      throw Exception('Server is not running');
    }
    await _server!.shutdown();
    _server = null;
    print('Server stopped');
  }

  bool get isRunning => _server != null;
}
