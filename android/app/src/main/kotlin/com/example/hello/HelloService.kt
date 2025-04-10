package com.example.hello

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log
import kotlinx.coroutines.*

class HelloService : Service() {
    private val TAG = "HelloService"
    private val serviceScope = CoroutineScope(Dispatchers.IO + Job())

    private val binder = object : HelloAIDL.Stub() {
        override fun sayHello(numMessages: Int, callback: IHelloResultCallback) {
            serviceScope.launch {
                try {
                    // Simulate processing and sending multiple messages
                    for (i in 1..numMessages) {
                        delay(1000) // Simulate work
                        callback.onResult("Hello message $i")
                    }
                    // Signal completion
                    callback.onResult("Done")
                } catch (e: Exception) {
                    Log.e(TAG, "Error in sayHello", e)
                    callback.onResult("Error: ${e.message}")
                }
            }
        }
    }

    override fun onBind(intent: Intent): IBinder {
        return binder
    }

    override fun onDestroy() {
        super.onDestroy()
        serviceScope.cancel()
    }
}
