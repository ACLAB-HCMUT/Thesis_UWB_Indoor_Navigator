import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uwb_app/navigation/app_navigation.dart';
import 'package:uwb_app/network/mqtt.dart';
import 'package:uwb_app/network/device.dart';
import 'package:uwb_app/views/scatter_chart.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;
  runApp(
    MultiProvider(
      providers: [
        Provider<MqttService>(
          create: (_) => MqttService(),
        ),
        ValueListenableProvider<ValueNotifier<List<Device>>>.value(
          value: ValueNotifier<ValueNotifier<List<Device>>>(ValueNotifier<List<Device>>(
              [])),
        ),
        ValueListenableProvider<ValueNotifier<Map<String, Point>>>.value(
          value: ValueNotifier<ValueNotifier<Map<String, Point>>>(
              ValueNotifier<Map<String, Point>>({})),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppNavigation.router,
    );
  }
}
