import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/user.dart';
import '../../utility/constants.dart';
import '../../screens/main/main_screen.dart';
import '../../screens/login/login_screen.dart';

class AuthGuard extends GetMiddleware {
  final GetStorage _box = GetStorage();

  bool get _isAuthenticatedAdmin {
    final token = _box.read(TOKEN)?.toString();
    final rawUser = _box.read(USER_KEY);

    if (token == null || token.isEmpty) {
      return false;
    }

    if (rawUser is Map<String, dynamic>) {
      final user = User.fromJson(rawUser);
      return user.role == 'admin' || user.role == 'superadmin';
    }

    if (rawUser is Map) {
      final user = User.fromJson(rawUser.cast<String, dynamic>());
      return user.role == 'admin' || user.role == 'superadmin';
    }

    return false;
  }

  @override
  RouteSettings? redirect(String? route) {
    final loggedIn = _isAuthenticatedAdmin;

    if (route == AppPages.LOGIN && loggedIn) {
      return const RouteSettings(name: AppPages.HOME);
    }

    if (route == AppPages.HOME && !loggedIn) {
      return const RouteSettings(name: AppPages.LOGIN);
    }

    return null;
  }
}

class AppPages {
  static const HOME = '/';
  static const LOGIN = '/login';

  static final routes = [
    GetPage(name: HOME, page: () => MainScreen(), middlewares: [AuthGuard()]),
    GetPage(
      name: LOGIN,
      page: () => const LoginScreen(),
      middlewares: [AuthGuard()],
    ),
  ];
}
