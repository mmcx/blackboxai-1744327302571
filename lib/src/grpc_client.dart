import 'package:grpc/grpc.dart';
import '../generated/hello.pbgrpc.dart';

class HelloClient {
  late final HelloServiceClient stub;
  late final ClientChannel channel;

  HelloClient() {
    channel = ClientChannel(
      'localhost',
      port: 50051,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    stub = HelloServiceClient(channel);
  }

  Future<void> sayHelloStream(int numMessages) async {
    try {
      print('Starting stream request with numMessages: $numMessages');
      final request = HelloRequest()..numMessages = numMessages;
      
      await for (var response in stub.sayHelloStream(request)) {
        print('Received: ${response.message}');
      }
      print('Stream completed');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> shutdown() async {
    await channel.shutdown();
  }
}

// Example usage
void main() async {
  final client = HelloClient();
  try {
    await client.sayHelloStream(5); // Request 5 messages
  } finally {
    await client.shutdown();
  }
}
