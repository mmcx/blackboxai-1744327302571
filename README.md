# gRPC Dart Server with Android AIDL Integration

This project demonstrates a gRPC server implementation in Dart that integrates with Android's AIDL interface. The server provides a streaming method `sayHelloStream` that forwards requests to an Android service and streams back multiple responses.

## Project Structure

```
.
├── lib/
│   └── src/
│       ├── android_bridge.dart    # Flutter-Android communication bridge
│       ├── grpc_server.dart       # gRPC server implementation
│       └── grpc_client.dart       # Test client implementation
├── android/
│   └── app/
│       └── src/
│           ├── main/
│           │   ├── aidl/
│           │   │   └── com/example/hello/
│           │   │       ├── HelloAIDL.aidl           # AIDL interface
│           │   │       └── IHelloResultCallback.aidl # Callback interface
│           │   └── kotlin/
│           │       └── com/example/hello/
│           │           ├── HelloService.kt  # AIDL service implementation
│           │           └── HelloBridge.kt   # Flutter plugin implementation
├── hello.proto    # Protocol buffer definition
└── pubspec.yaml   # Dart/Flutter project configuration
```

## Setup Instructions

1. Install required dependencies:
   ```bash
   flutter pub get
   ```

2. Generate the protocol buffer code:
   ```bash
   protoc --dart_out=grpc:lib/generated -Iprotos hello.proto
   ```

3. Build and run the Flutter application:
   ```bash
   flutter run
   ```

The Flutter application provides a user-friendly interface to:
- Start/Stop the gRPC server
- Monitor server status
- View server logs

4. (Optional) Run the test client in a separate terminal:
   ```bash
   dart run lib/src/grpc_client.dart
   ```

## Implementation Details

### Flutter UI
The application includes a modern Material Design UI that allows users to:
- Control the gRPC server with start/stop functionality
- View the current server status with visual indicators
- Monitor server operations in real-time

### gRPC Service
The service defines a streaming RPC method `sayHelloStream` that accepts a number of messages to generate and returns a stream of responses.

### Android Integration
- Uses AIDL for IPC communication
- Implements a service that generates multiple responses
- Provides a callback mechanism to stream results back to Dart

### Flutter/Dart Bridge
- Uses platform channels for Flutter-Android communication
- Manages bidirectional streaming of data
- Handles proper resource cleanup

## Testing

1. Start the server:
   ```bash
   dart run lib/src/grpc_server.dart
   ```

2. In a separate terminal, run the test client:
   ```bash
   dart run lib/src/grpc_client.dart
   ```

The client will request 5 messages, and you should see the responses streaming back from the Android service through the gRPC server.

## Error Handling

- Input validation for numMessages (must be > 0)
- Proper error propagation from Android to Dart
- Resource cleanup in all components
- Graceful handling of service disconnections

## Notes

- The server runs on port 50051 by default
- Uses insecure connections for demonstration purposes
- Implements proper resource management and cleanup
- Provides detailed error reporting

## Requirements

- Flutter SDK
- Dart SDK >=2.17.0
- Android SDK
- Protocol Buffers compiler
