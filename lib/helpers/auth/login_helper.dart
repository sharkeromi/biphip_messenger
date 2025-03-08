

import 'package:biphip_messenger/controllers/auth/authentication_controller.dart';
import 'package:biphip_messenger/controllers/common/global_controller.dart';
import 'package:biphip_messenger/controllers/common/sp_controller.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/utils/constants/routes.dart';
import 'package:biphip_messenger/utils/constants/strings.dart';
import 'package:get/get.dart';

class LoginHelper {
  final AuthenticationController authenticationController = Get.find<AuthenticationController>();

  void checkCanLogin() {
    if (authenticationController.loginEmailTextEditingController.text.trim().isNotEmpty &&
        authenticationController.loginPasswordTextEditingController.text.trim().isNotEmpty &&
        authenticationController.loginPasswordTextEditingController.text.length >= kMinPasswordLength) {
      authenticationController.canLogin.value = true;
    } else {
      authenticationController.canLogin.value = false;
    }
  }

  void loginEmailEditorOnChanged() {
    checkCanLogin();
    if (authenticationController.loginEmailTextEditingController.text.trim() == '') {
      authenticationController.loginEmailErrorText.value = ksEmptyEmailErrorMessage.tr;
    } else if (!authenticationController.loginEmailTextEditingController.text.trim().isValidEmail) {
      authenticationController.loginEmailErrorText.value = ksInvalidEmailErrorMessage.tr;
    } else {
      authenticationController.loginEmailErrorText.value = null;
    }
  }

  void loginPasswordEditorOnChanger() {
    checkCanLogin();
    if (authenticationController.loginPasswordTextEditingController.text.trim() == '') {
      authenticationController.loginPasswordErrorText.value = ksEmptyPasswordErrorMessage.tr;
    } else if (authenticationController.loginPasswordTextEditingController.text.length < kMinPasswordLength) {
      authenticationController.loginPasswordErrorText.value = ksPasswordLengthErrorMessage.tr;
    } else {
      authenticationController.loginPasswordErrorText.value = null;
    }
  }

  void getSaveUserDetails(item) async {
    final SpController spController = SpController();
    await spController.saveBearerToken(item['token']);
    await spController.saveRememberMe(true);
    await spController.saveUserName(item['name'].toString());
    await spController.saveUserFirstName(item['first_name'].toString());
    await spController.saveUserLastName(item['last_name'].toString());
    await spController.saveUserImage(item['image_url'].toString());
    await spController.saveUserEmail(item['email'].toString());
    await spController.saveUserId(item['id']);
    await Get.find<GlobalController>().getUserInfo();
    Get.offAllNamed(krHome);
  }
}
