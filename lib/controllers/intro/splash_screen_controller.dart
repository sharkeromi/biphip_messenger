import 'dart:async';

import 'package:biphip_messenger/controllers/auth/authentication_controller.dart';
import 'package:biphip_messenger/controllers/common/global_controller.dart';
import 'package:biphip_messenger/controllers/common/socket_controller.dart';
import 'package:biphip_messenger/controllers/common/sp_controller.dart';
import 'package:biphip_messenger/utils/constants/routes.dart';
import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  final SpController spController = SpController();

  @override
  void onInit() async {
    await getRemember();
    startSplashScreen();
    super.onInit();
  }

  bool rememberStatus = false;
  Future<void> getRemember() async {
    bool? state = await spController.getRememberMe();
    if (state == null || state == false) {
      rememberStatus = false;
    } else {
      rememberStatus = true;
    }
  }

  Timer startSplashScreen() {
    var duration = const Duration(seconds: 3);
    return Timer(
      duration,
      () async {
        if (rememberStatus) {
          SocketController().socketInit();
          await Get.find<GlobalController>().getUserInfo();
          Get.offAllNamed(krHome);
        } else {
          Get.find<AuthenticationController>().resetLoginScreen();
          Get.offAllNamed(krLogin);
        }
      },
    );
  }
}
