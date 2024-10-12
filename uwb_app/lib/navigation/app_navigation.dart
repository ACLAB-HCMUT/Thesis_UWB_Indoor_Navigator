import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:uwb_app/views/view_devices.dart';
import 'package:uwb_app/views/view_map.dart';
import 'package:uwb_app/views/wrapper/main_wrapper.dart';

class AppNavigation {
  AppNavigation._();
  static String initRoute = '/devices';

  static final GoRouter router = GoRouter(
    initialLocation: initRoute,
    routes: <RouteBase> [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(
            navigationShell: navigationShell,
          );
        },
        branches: <StatefulShellBranch> [
          StatefulShellBranch(
            routes: <RouteBase> [
              GoRoute(
                path: '/devices',
                name: 'Devices',
                builder: (context, state) => const ViewDevices(),
              )
            ]
          ),
          StatefulShellBranch(
              routes: <RouteBase> [
                GoRoute(
                  path: '/map-of-room',
                  name: 'MapOfRoom',
                  builder: (context, state) => const ViewMap(),
                )
              ]
          )
        ]
      ),
    ]
  );
}

