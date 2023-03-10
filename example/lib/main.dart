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
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    ScreenCaptureAssistant.listenEvents((screenCaptureAssistantEvent, data) {
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          // ignore: sort_child_properties_last
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              TextField(
                decoration: const InputDecoration(
                  hintText: '请输入窗口ID',
                ),
                controller: _controller,
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (!bStart) {
              int windowID = 0x303EA;
              String? id = _controller?.text;
              if (id == null || id!.isEmpty) {
                return;
              }
              try {
                windowID = int.parse(id);
                bool? isOk = await ScreenCaptureAssistant.startCheckWindowSize(windowID).onError((error, stackTrace) {
                  print(error.toString());
                });
                if (isOk != null && isOk) {
                  bStart = true;
                  setState(() {});
                }
              } catch (_) {
                print('start error!');
              }
            } else {
              ScreenCaptureAssistant.endCheckWindowSize();
              bStart = false;
            }
          },
          child: bStart
              ? const Icon(Icons.stop_circle)
              : const Icon(Icons.start_rounded),
        ),
      ),
    );
  }
}
