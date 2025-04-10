package com.example.hello

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class HelloBridge: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    private var helloService: HelloAIDL? = null
    private var eventSink: EventChannel.EventSink? = null

    private val connection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            helloService = HelloAIDL.Stub.asInterface(service)
            Log.d(TAG, "Service connected")
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            helloService = null
            Log.d(TAG, "Service disconnected")
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.example.hello/bridge")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "com.example.hello/events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        // Bind to the service
        val intent = Intent(context, HelloService::class.java)
        context.bindService(intent, connection, Context.BIND_AUTO_CREATE)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        context.unbindService(connection)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "sayHelloStream" -> {
                val numMessages = call.argument<Int>("numMessages") ?: 0
                if (numMessages <= 0) {
                    result.error("INVALID_ARGUMENT", "numMessages must be greater than 0", null)
                    return
                }

                val callback = object : IHelloResultCallback.Stub() {
                    override fun onResult(message: String) {
                        eventSink?.success(message)
                    }
                }

                try {
                    helloService?.sayHello(numMessages, callback)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("SERVICE_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        private const val TAG = "HelloBridge"
    }
}
