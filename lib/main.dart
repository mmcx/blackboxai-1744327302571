import 'package:flutter/material.dart';
import 'src/grpc_server.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gRPC Server Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ServerManagerScreen(),
    );
  }
}

class ServerManagerScreen extends StatefulWidget {
  const ServerManagerScreen({Key? key}) : super(key: key);

  @override
  State<ServerManagerScreen> createState() => _ServerManagerScreenState();
}

class _ServerManagerScreenState extends State<ServerManagerScreen> {
  bool _isServerRunning = false;
  String _serverStatus = 'Server is stopped';
  final GrpcServer _server = GrpcServer();

  Future<void> _toggleServer() async {
    if (!_isServerRunning) {
      setState(() {
        _serverStatus = 'Starting server...';
      });
      try {
        await _server.start();
        setState(() {
          _isServerRunning = true;
          _serverStatus = 'Server is running on port 50051';
        });
      } catch (e) {
        setState(() {
          _serverStatus = 'Error starting server: $e';
        });
      }
    } else {
      setState(() {
        _serverStatus = 'Stopping server...';
      });
      try {
        await _server.stop();
        setState(() {
          _isServerRunning = false;
          _serverStatus = 'Server is stopped';
        });
      } catch (e) {
        setState(() {
          _serverStatus = 'Error stopping server: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('gRPC Server Manager'),
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isServerRunning ? Icons.cloud_done : Icons.cloud_off,
                          size: 64,
                          color: _isServerRunning ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _serverStatus,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _toggleServer,
                  icon: Icon(_isServerRunning ? Icons.stop : Icons.play_arrow),
                  label: Text(_isServerRunning ? 'Stop Server' : 'Start Server'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
