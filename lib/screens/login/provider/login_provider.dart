import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/auth_session.dart';
import '../../../models/user.dart';
import '../../../services/auth_session_service.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';
import '../../../core/routes/app_pages.dart';
import '../../../utility/constants.dart';

class LoginProvider extends ChangeNotifier {
  final HttpService _httpService = HttpService();
  final AuthSessionService _authSessionService = AuthSessionService.instance;
  final DataProvider _dataProvider;
  final GetStorage _box = GetStorage();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool isReadOnly = false;

  LoginProvider(this._dataProvider);

  User? get currentUser {
    final userData = _box.read(USER_KEY);
    if (userData is Map<String, dynamic>) {
      return User.fromJson(userData);
    }
    if (userData is Map) {
      return User.fromJson(userData.cast<String, dynamic>());
    }
    return null;
  }

  Future<void> login(BuildContext context) async {
    if (!loginFormKey.currentState!.validate()) return;

    isReadOnly = true;
    notifyListeners();

    try {
      final Map<String, dynamic> loginData = {
        "email": emailCtrl.text.trim().toLowerCase(),
        "password": passwordCtrl.text,
      };

      final response = await _httpService.addItem(
        endpointUrl: "users/login",
        itemData: loginData,
      );

      if (response.isOk && response.body != null) {
        final body = response.body;

        if (body["success"] == true && body["data"] != null) {
          final data = body["data"];
          if (data is! Map<String, dynamic>) {
            SnackBarHelper.showErrorSnackBar("Invalid login response");
            return;
          }

          final authSession = AuthSession.fromJson(data);
          final loginUser = authSession.user;

          if (loginUser == null || !authSession.hasAccessToken) {
            SnackBarHelper.showErrorSnackBar("Invalid authentication data");
            return;
          }

          if (!authSession.hasRefreshToken) {
            SnackBarHelper.showErrorSnackBar("Refresh token not found in response");
            return;
          }

          if (loginUser.role != 'admin' && loginUser.role != 'superadmin') {
            SnackBarHelper.showErrorSnackBar("Access denied. Admin only.");
            return;
          }

          await _authSessionService.saveSession(authSession);

          SnackBarHelper.showSuccessSnackBar("Login successful");
          
          await _dataProvider.init();
          Get.offAllNamed(AppPages.HOME);
        } else {
          SnackBarHelper.showErrorSnackBar(body["message"] ?? "Login failed");
        }
      } else {
        String errorMsg = response.body?["message"] ?? "Server error: ${response.statusCode}";
        SnackBarHelper.showErrorSnackBar(errorMsg);
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar("An error occurred: $e");
    } finally {
      isReadOnly = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authSessionService.logout();
    emailCtrl.clear();
    passwordCtrl.clear();
    notifyListeners();
  }
}
