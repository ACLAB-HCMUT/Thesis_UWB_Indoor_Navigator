import 'package:flutter/material.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

class ViewMap3d extends StatefulWidget {
  const ViewMap3d({super.key});

  @override
  State<ViewMap3d> createState() => _ViewMap3dState();
}

class _ViewMap3dState extends State<ViewMap3d> {
  @override
  void initState() {
    super.initState();
    _openUnityApp();
  }

  Future<void> _openUnityApp() async {
    await LaunchApp.openApp(
      androidPackageName: 'com.DefaultCompany.DoAnUnity3D',
      openStore: false,
    );
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
