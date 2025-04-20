import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class ViewMap3d2 extends StatefulWidget {
  const ViewMap3d2({super.key});

  @override
  State<ViewMap3d2> createState() => _ViewMap3d2State();
}

class _ViewMap3d2State extends State<ViewMap3d2> {
  @override
  void initState() {
    super.initState();
    _openUnityApp();
  }

  Future<void> _openUnityApp() async {
    const intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      package: 'com.DefaultCompany.DoAnUnity3D',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      arguments: <String, dynamic>{
        'extra_key': 'your_value',
      },
    );
    await intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _openUnityApp,
        child: const Center(
          child: Text('Opening Unity App... Tap to try again.'),
        ),
      ),
    );
  }
}
