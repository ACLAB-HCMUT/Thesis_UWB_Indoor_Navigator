import 'package:flutter/material.dart';
import 'package:uwb_app/navigation/app_navigation.dart';
import 'package:uwb_app/views/view_devices.dart';
import 'package:uwb_app/views/view_map.dart';
import 'package:uwb_app/views/wrapper/main_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppNavigation.router,
    );
  }
}