import 'dart:io';

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
              ),
              const SizedBox(height: 80),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(
                      bStart ? Colors.red : Colors.blue),
                ),
                onPressed: listenWindowSizeChange,
                child: Text(bStart ? '停止监听窗口变化' : '开始监听窗口变化'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: getWindowSize, child: const Text('单次获取窗口大小')),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: checkScreenRecordPermission, child: const Text('检查屏幕录制权限')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: openScreenCaptureSetting, child: const Text('打开屏幕录制权限设置页面')),
            ],
          ),
        ),
      ),
    );
  }

  int getTestWindowID() {
    int windowID = 0x303EA;
    String? id = _controller?.text;
    if (id == null || id.isEmpty) return windowID;
    try {
      windowID = int.parse(id);
    } catch (_) {}
    return windowID;
  }

  Future<void> getWindowSize() async {
    final windowID = getTestWindowID();
    final size = await ScreenCaptureAssistant.getWindowSize(windowID);
    print('windowID: $windowID size: $size');
  }

  Future<void> listenWindowSizeChange() async {
    if (!bStart) {
      final windowID = getTestWindowID();
      bool? isOk =
          await ScreenCaptureAssistant.startCheckWindowSize(windowID).onError(
        (error, stackTrace) {
          print(error.toString());
          ScreenCaptureAssistant.endCheckWindowSize();
        },
      );
      if (isOk != null && isOk) {
        bStart = true;
        setState(() {});
      }
    } else {
      ScreenCaptureAssistant.endCheckWindowSize();
      bStart = false;
      setState(() {});
    }
  }

  Future<void> checkScreenRecordPermission() async {
      if(Platform.isMacOS){
        final hasPermission = await ScreenCaptureAssistant.checkScreenRecordPermission();
        print('==== hasPermission: $hasPermission');
      }
  }

  Future<void> openScreenCaptureSetting() async {
    if(Platform.isMacOS){
      await ScreenCaptureAssistant.openScreenCaptureSetting();
    }
  }
}
