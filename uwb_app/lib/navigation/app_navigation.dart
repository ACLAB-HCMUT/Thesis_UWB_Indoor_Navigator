import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:uwb_app/views/view_devices.dart';
import 'package:uwb_app/views/view_map.dart';
import 'package:uwb_app/views/wrapper/main_wrapper.dart';
import 'package:uwb_app/views/view_device_info.dart';
import 'package:uwb_app/network/mqtt.dart';

class AppNavigation {
  AppNavigation._();
  static String initRoute = '/devices';

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorDevice =
      GlobalKey<NavigatorState>(debugLabel: 'Devices');
  static final _shellNavigatorMap =
      GlobalKey<NavigatorState>(debugLabel: 'Map');

  static final GoRouter router = GoRouter(
      initialLocation: initRoute,
      debugLogDiagnostics: true,
      navigatorKey: _rootNavigatorKey,
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return MainWrapper(
                navigationShell: navigationShell,
              );
            },
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                  navigatorKey: _shellNavigatorDevice,
                  routes: <RouteBase>[
                    GoRoute(
                        path: '/devices',
                        name: 'Devices',
                        builder: (context, state) => const ViewDevices(),
                        routes: [
                          GoRoute(
                            path: 'device-info',
                            name: 'DeviceInfo',
                            pageBuilder: (context, state) =>
                                CustomTransitionPage(
                              key: state.pageKey,
                              child: ViewDeviceInfo(id: state.extra as String),
                              transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) =>
                                  FadeTransition(
                                      opacity: animation, child: child),
                            ),
                          )
                        ])
                  ]),
              StatefulShellBranch(
                  navigatorKey: _shellNavigatorMap,
                  routes: <RouteBase>[
                    GoRoute(
                      path: '/map-of-room',
                      name: 'MapOfRoom',
                      builder: (context, state) => ViewMap(),
                      // builder: (context, state) => ViewMap(id: state.uri.queryParameters['id']),
                    )
                  ])
            ]),
      ]);
}
