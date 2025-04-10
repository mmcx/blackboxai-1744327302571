import 'dart:async';
import 'package:flutter/services.dart';

class AndroidBridge {
  static const MethodChannel _channel = MethodChannel('com.example.hello/bridge');
  static const EventChannel _eventChannel = EventChannel('com.example.hello/events');
  
  static Stream<String>? _resultStream;
  static StreamController<String>? _streamController;

  static Future<void> invokeSayHelloStream(int numMessages) async {
    try {
      await _channel.invokeMethod('sayHelloStream', {'numMessages': numMessages});
    } on PlatformException catch (e) {
      throw Exception('Failed to invoke sayHelloStream: ${e.message}');
    }
  }

  static Stream<String> registerResultCallback() {
    if (_streamController == null) {
      _streamController = StreamController<String>.broadcast();
      
      _resultStream = _eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => event.toString());
      
      _resultStream!.listen(
        (String message) {
          if (!_streamController!.isClosed) {
            _streamController!.add(message);
            if (message == 'Done') {
              _streamController!.close();
              _streamController = null;
            }
          }
        },
        onError: (error) {
          _streamController!.addError(error);
          _streamController!.close();
          _streamController = null;
        },
      );
    }
    
    return _streamController!.stream;
  }

  static void dispose() {
    _streamController?.close();
    _streamController = null;
  }
}
