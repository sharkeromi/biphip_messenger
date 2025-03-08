import 'package:biphip_messenger/controllers/auth/authentication_controller.dart';
import 'package:biphip_messenger/controllers/common/global_controller.dart';
import 'package:biphip_messenger/controllers/messenger/messenger_controller.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/utils/constants/routes.dart';
import 'package:biphip_messenger/utils/constants/strings.dart';
import 'package:biphip_messenger/widgets/common/button/custom_button.dart';
import 'package:biphip_messenger/widgets/common/utils/custom_app_bar.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final GlobalController globalController = Get.find<GlobalController>();
  final AuthenticationController authController = Get.find<AuthenticationController>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: cWhiteColor,
          child: SafeArea(
            top: false,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: cBackgroundColor,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kAppBarSize),
                //* info:: appBar
                child: CustomAppBar(
                  appBarColor: cWhiteColor,
                  title: ksBipHip.tr,
                  titleColor: cPrimaryColor,
                  hasBackButton: false,
                  isCenterTitle: false,
                  onBack: () {
                    Get.back();
                  },
                  action: [
                    Padding(
                      padding: const EdgeInsets.only(right: h20),
                      child: TextButton(
                        style: kTextButtonStyle,
                        onPressed: () async {
                          Get.toNamed(krInbox);
                          await Get.find<MessengerController>().getRoomList();
                        },
                        child: Icon(
                          BipHip.chatOutline,
                          color: cIconColor,
                          size: isDeviceScreenLarge() ? 24 : 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomElevatedButton(
                    label: "Logout",
                    onPressed: () async {
                      await authController.logout();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
