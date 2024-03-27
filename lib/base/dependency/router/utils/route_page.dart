import 'package:flutter/material.dart';
import 'package:task_manager/base/dependency/router/utils/route_name.dart';
import 'package:task_manager/base/dependency/router/utils/route_screen.dart';

class RoutePage {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.login:
        return RouteScreen.loginPageRoute(settings);
    }
    return RouteScreen.unknownPageRoute(settings);
  }
}
