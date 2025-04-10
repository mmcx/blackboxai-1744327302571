package com.example.hello;

import com.example.hello.IHelloResultCallback;

interface HelloAIDL {
    void sayHello(int numMessages, IHelloResultCallback callback);
}
