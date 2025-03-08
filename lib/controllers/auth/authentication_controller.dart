import 'dart:io';

import 'package:biphip_messenger/controllers/common/api_controller.dart';
import 'package:biphip_messenger/controllers/common/global_controller.dart';
import 'package:biphip_messenger/controllers/common/sp_controller.dart';
import 'package:biphip_messenger/models/auth/login_model.dart';
import 'package:biphip_messenger/models/common/common_data_model.dart';
import 'package:biphip_messenger/models/common/common_error_model.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/utils/constants/routes.dart';
import 'package:biphip_messenger/utils/constants/strings.dart';
import 'package:biphip_messenger/utils/constants/urls.dart';
import 'package:get/get.dart';


class AuthenticationController extends GetxController {
  final TextEditingController twoFactorTextfieldController = TextEditingController();

  final RxString profileLink = RxString('');
  final Rx<File> profileFile = File('').obs;
  final RxBool isProfileImageChanged = RxBool(false);
  final RxBool isImageUploadLoading = RxBool(false);
  final RxList users = RxList([]);
  final RxBool isTwoFactorLoading =  RxBool(false);
  final RxBool isDeleteAccountLoading =  RxBool(false);
  final RxBool isDeactivateAccountLoading =  RxBool(false);
  final ApiController apiController = ApiController();
  final SpController spController = SpController();
  final GlobalController globalController = Get.find<GlobalController>();

  final RxString parentRoute = RxString("register");
  final RxString verificationToken = RxString('');

  Future<void> getSavedUsers() async {
    List userList = await spController.getUserList();
    users.clear();
    users.addAll(userList);
    ll("user list length : ${users.length}");
  }

  void onIntroDone() async {
    Get.offAllNamed(krLogin);
  }

  void resetProfileImage() {
    profileLink.value = '';
    profileFile.value = File('');
    isProfileImageChanged.value = false;
  }

  Widget errorTextWiseResponsiveSizedBox(errorText) {
    if (errorText != null) {
      return isDeviceScreenLarge() ? kH10sizedBox : kH8sizedBox;
    } else {
      return isDeviceScreenLarge() ? kH24sizedBox : kH20sizedBox;
    }
  }

  /*
  |--------------------------------------------------------------------------
  | //! info:: login
  |--------------------------------------------------------------------------
  */

  final TextEditingController loginEmailTextEditingController = TextEditingController();
  final TextEditingController loginPasswordTextEditingController = TextEditingController();
  final RxBool isLoginPasswordToggleObscure = RxBool(true);
  final RxBool isLoginRememberCheck = RxBool(false);
  final Rx<String?> loginEmailErrorText = Rx<String?>(null);
  final Rx<String?> loginPasswordErrorText = Rx<String?>(null);

  void resetLoginScreen() {
    loginEmailTextEditingController.clear();
    loginPasswordTextEditingController.clear();
    isLoginPasswordToggleObscure.value = true;
    isLoginRememberCheck.value = false;
    loginEmailErrorText.value = null;
    loginPasswordErrorText.value = null;
    canLogin.value = false;
  }

  final RxBool canLogin = RxBool(false);

  final RxBool isLoginLoading = RxBool(false);
  Future<void> userLogin() async {
    try {
      isLoginLoading.value = true;
      Map<String, dynamic> body = {
        'email': loginEmailTextEditingController.text.toString(),
        "password": loginPasswordTextEditingController.text.toString(),
      };
      ll("body : $body");
      var response = await apiController.commonApiCall(
        url: kuLogin,
        body: body,
        requestMethod: kPost,
      ) as CommonDM;

      if (response.success == true) {
        LoginModel loginData = LoginModel.fromJson(response.data);
        await spController.saveBearerToken(loginData.token);
        await spController.saveRememberMe(isLoginRememberCheck.value);
        await spController.saveUserName(loginData.user.fullName.toString());
        await spController.saveUserFirstName(loginData.user.firstName.toString());
        await spController.saveUserLastName(loginData.user.lastName.toString());
        await spController.saveUserImage(loginData.user.profilePicture.toString());
        await spController.saveUserEmail(loginData.user.email.toString());
        await spController.saveUserId(loginData.user.id);
        if (isLoginRememberCheck.value) {
          await spController.saveUserList({
            "id": loginData.user.id,
            "email": loginData.user.email.toString(),
            "name": loginData.user.fullName.toString(),
            "first_name": loginData.user.firstName.toString(),
            "last_name": loginData.user.lastName.toString(),
            "image_url": loginData.user.profilePicture,
            "token": loginData.token.toString(),
          });
        }
        await globalController.getUserInfo();
        isLoginLoading.value = false;
        Get.offAllNamed(krHome);
        globalController.showSnackBar(title: ksSuccess.tr, message: response.message, color: cGreenColor, duration: 1000);
      } else {
        if (response.code == 410) {
        
          globalController.showSnackBar(title: ksError.tr, message: response.message, color: cRedColor);
        } else {
          ErrorModel errorModel = ErrorModel.fromJson(response.data);
          isLoginLoading.value = false;
          if (errorModel.errors.isEmpty) {
            globalController.showSnackBar(title: ksError.tr, message: response.message, color: cRedColor);
          } else {
            globalController.showSnackBar(title: ksError.tr, message: errorModel.errors[0].message, color: cRedColor);
          }
        }
      }
    } catch (e) {
      isLoginLoading.value = false;
      ll('userLogin error: $e');
    }
  }

  
  /*
  |--------------------------------------------------------------------------
  | //! info:: logout
  |--------------------------------------------------------------------------
  */
  final RxBool isLogoutLoading = RxBool(false);
  Future<void> logout() async {
    try {
      isLogoutLoading.value = true;
      String? token = await spController.getBearerToken();
      Map<String, dynamic> body = {
        "all_devices": 0.toString(),
      };
      var response = await apiController.commonApiCall(
        requestMethod: kPost,
        token: token,
        url: kuLogOut,
        body: body,
      ) as CommonDM;

      if (response.success == true) {
        await SpController().onLogout();
        resetLoginScreen();
        isLogoutLoading.value = false;
        Get.offAllNamed(krLogin);
        globalController.showSnackBar(title: ksSuccess.tr, message: response.message, color: cGreenColor, duration: 1000);
      } else {
        ErrorModel errorModel = ErrorModel.fromJson(response.data);
        isLogoutLoading.value = false;
        if (errorModel.errors.isEmpty) {
          globalController.showSnackBar(title: ksError.tr, message: response.message, color: cRedColor);
        } else {
          globalController.showSnackBar(title: ksError.tr, message: errorModel.errors[0].message, color: cRedColor);
        }
      }
    } catch (e) {
      isLogoutLoading.value = false;
      ll('logout error: $e');
    }
  }
}
