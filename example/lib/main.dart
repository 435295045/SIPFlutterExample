import 'package:flutter/material.dart';
import 'package:sip_sdk_flutter_example/sip_manage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    //初始化SDK
    SIPManage.initialize();
  }

  void _onTestCall() {
    SIPManage().call("RM-1-1-1-1-1-1", {"test": "dddddddd"});
  }

  void _onSIPMessage() {
    SIPManage().sendMessage("RM-1-1-1-1-1-1", "这是测试消息");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: _onTestCall, child: const Text('测试呼叫')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onSIPMessage,
                child: const Text('测试发送sip消息'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
