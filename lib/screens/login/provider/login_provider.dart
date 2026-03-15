import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/user.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';
import '../../../core/routes/app_pages.dart';

class LoginProvider extends ChangeNotifier {
  final HttpService _httpService = HttpService();
  final DataProvider _dataProvider;
  final GetStorage _box = GetStorage();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool isReadOnly = false;

  LoginProvider(this._dataProvider);

  Future<void> login(BuildContext context) async {
    if (!loginFormKey.currentState!.validate()) return;

    isReadOnly = true;
    notifyListeners();

    try {
      final Map<String, dynamic> loginData = {
        "name": nameCtrl.text.trim(),
        "password": passwordCtrl.text,
      };

      print("Attempting login for: ${nameCtrl.text.trim()}");

      final response = await _httpService.addItem(
        endpointUrl: "users/login",
        itemData: loginData,
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.isOk && response.body != null) {
        final body = response.body;

        if (body["success"] == true && body["data"] != null) {
          final String token = body["data"]["token"];
          final userJson = body["data"]["user"];
          
          final loginUser = User.fromJson(userJson);

          if (loginUser.role != 'admin' && loginUser.role != 'superadmin') {
            SnackBarHelper.showErrorSnackBar("Access denied. Admin only.");
            return;
          }

          await _box.write("token", token);
          await _box.write("user", loginUser.toJson());

          SnackBarHelper.showSuccessSnackBar("Login successful");
          
          await _dataProvider.init();
          Get.offAllNamed(AppPages.HOME);
        } else {
          SnackBarHelper.showErrorSnackBar(body["message"] ?? "Login failed");
        }
      } else {
        String errorMsg = response.body?["message"] ?? "Server connection failed (CORS or Down)";
        SnackBarHelper.showErrorSnackBar(errorMsg);
      }
    } catch (e) {
      print("Login Error: $e");
      SnackBarHelper.showErrorSnackBar("An error occurred: $e");
    } finally {
      isReadOnly = false;
      notifyListeners();
    }
  }

  void logout() {
    _box.remove("token");
    _box.remove("user");
    Get.offAllNamed(AppPages.LOGIN);
  }
}
