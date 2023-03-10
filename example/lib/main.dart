import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:screen_capture_assistant/screen_capture_assistant.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _screenCaptureAssistantPlugin = ScreenCaptureAssistant();
  bool bStart = false;
  
  @override
  void initState() {
    super.initState();
   ScreenCaptureAssistant.listenEvents((screenCaptureAssistantEvent, data){
      print('event-----------------------{$screenCaptureAssistantEvent} $data');
   });
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    // try {
    //   platformVersion =
    //       await _screenCaptureAssistantPlugin.getPlatformVersion() ?? 'Unknown platform version';
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }
    //
    // // If the widget was removed from the tree while the asynchronous platform
    // // message was in flight, we want to discard the reply rather than calling
    // // setState to update our non-existent appearance.
    // if (!mounted) return;
    //
    // setState(() {
    //   _platformVersion = platformVersion;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
        floatingActionButton: FloatingActionButton(onPressed: () async {
          if(!bStart){
            bStart = true;
            int windowId = 0x00;
            ScreenCaptureAssistant.startCheckWindowSize(windowId);
          }else{
            ScreenCaptureAssistant.endCheckWindowSize();
            bStart = false;
          }
        },child: const Icon(Icons.add_sharp),),
      ),
    );
  }
}
