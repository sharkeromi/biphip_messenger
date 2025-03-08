import 'dart:async';

import 'package:biphip_messenger/controllers/common/sp_controller.dart';
import 'package:biphip_messenger/controllers/messenger/messenger_controller.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/utils/constants/strings.dart';
import 'package:biphip_messenger/widgets/common/button/custom_icon_button.dart';
import 'package:biphip_messenger/widgets/common/button/custom_text_button.dart';
import 'package:biphip_messenger/widgets/common/textfields/custom_textfield.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class GlobalController extends GetxController {
  final RxMap appLang = RxMap({'langCode': 'en', 'countryCode': 'US'});

  final Rx<String?> bearerToken = Rx<String?>(null);
  final RxList professionList = RxList([]);
  final RxList interestList = RxList([]);
  final RxList<int> interestIndex = RxList<int>([]);
  final RxInt professionIndex = RxInt(-1);
  RxString selectedProfession = RxString('');
  RxList selectedInterests = RxList([]);
  final RxList tapAbleButtonState = RxList([true, false, false]);
  final RxList tapAbleButtonText = RxList(["All", "Received", "Pending"]);
  final RxList languages = RxList([
    {'langCode': 'bn', 'countryCode': 'BD', 'langName': 'Bengali'},
    {'langCode': 'en', 'countryCode': 'US', 'langName': 'English'},
  ]);
  void resetChipSelection() {
    professionIndex.value = -1;
    interestIndex.clear();
  }

  //*For tapAble button
  void toggleType(int index) {
    switch (index) {
      case 0:
        tapAbleButtonState[0] = true;
        tapAbleButtonState[1] = false;
        tapAbleButtonState[2] = false;
        break;
      case 1:
        tapAbleButtonState[0] = false;
        tapAbleButtonState[1] = true;
        tapAbleButtonState[2] = false;
        break;
      case 2:
        tapAbleButtonState[0] = false;
        tapAbleButtonState[1] = false;
        tapAbleButtonState[2] = true;
        break;
    }
  }

  void resetTapButtonData() {
    tapAbleButtonState.clear();
    tapAbleButtonState.addAll([true, false, false]);
  }

  //* info:: show loading
  final isLoading = RxBool(false);

  void showLoading() {
    isLoading.value = true;
    Get.defaultDialog(
      radius: 2,
      backgroundColor: cWhiteColor,
      barrierDismissible: false,
      title: "",
      onWillPop: () async {
        if (isLoading.value) {
          return false;
        }
        return true;
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SpinKitFadingCircle(
            color: cPrimaryColor,
            size: 70.0,
          ),
          const SizedBox(height: k10Padding),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              ksLoading.tr,
              style: const TextStyle(color: cPrimaryColor, fontSize: h14),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void showSnackBar({required String title, required String message, required Color color, duration}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color,
      colorText: cWhiteColor,
      maxWidth: 400,
      duration: Duration(milliseconds: duration ?? 1500),
    );
  }

  Future<void> commonLogOutFunction() async {
    await SpController().onLogout();
  }

  //* info:: common bottom-sheet
  void commonBottomSheet(
      {required context,
      required Widget content,
      required onPressCloseButton,
      required onPressRightButton,
      required String rightText,
      required TextStyle rightTextStyle,
      required String title,
      required bool isRightButtonShow,
      double? bottomSheetHeight,
      bool? isScrollControlled,
      isSearchShow,
      RxBool? isBottomSheetRightButtonActive,
      bool? isDismissible}) {
    showModalBottomSheet<void>(
      isDismissible: isDismissible ?? true,
      isScrollControlled: isScrollControlled ?? false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(k16BorderRadius), topRight: Radius.circular(k16BorderRadius)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(k16BorderRadius), topRight: Radius.circular(k16BorderRadius)), color: cWhiteColor),
              width: width,
              height: MediaQuery.of(context).viewInsets.bottom > 0.0 ? height * .9 : bottomSheetHeight ?? height * .5,
              constraints: BoxConstraints(minHeight: bottomSheetHeight ?? height * .5, maxHeight: height * .9),
              child: Column(
                children: [
                  kH4sizedBox,
                  Container(
                    decoration: BoxDecoration(
                      color: cLineColor,
                      borderRadius: k4CircularBorderRadius,
                    ),
                    height: 5,
                    width: width * .1,
                  ),
                  kH40sizedBox,
                  const Divider(
                    thickness: 1,
                  ),
                  if (isSearchShow == true)
                    Padding(
                      padding: const EdgeInsets.only(left: k16Padding, right: k16Padding, top: k16Padding),
                      child: CustomModifiedTextField(
                        borderRadius: h8,
                        controller: searchController,
                        prefixIcon: BipHip.search,
                        suffixIcon: BipHip.voiceFill,
                        hint: ksSearch.tr,
                        contentPadding: const EdgeInsets.symmetric(horizontal: k16Padding),
                        textInputStyle: regular16TextStyle(cBlackColor),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: k16Padding, vertical: k8Padding),
                        child: content,
                      ),
                    ),
                  ),
                  kH4sizedBox,
                ],
              ),
            ),
            Positioned(
              top: h12,
              left: 5,
              child: CustomIconButton(
                onPress: onPressCloseButton,
                icon: BipHip.circleCrossNew,
                iconColor: cIconColor,
                size: screenWiseSize(kIconSize24, 4),
              ),
            ),
            Positioned(
              top: h20,
              child: Text(
                title,
                style: semiBold18TextStyle(cBlackColor),
              ),
            ),
            if (isRightButtonShow)
              Positioned(
                top: h20,
                right: 10,
                child: Obx(() => CustomTextButton(
                      onPressed: isBottomSheetRightButtonActive!.value ? onPressRightButton : null,
                      icon: BipHip.circleCross,
                      text: rightText,
                      textStyle: isBottomSheetRightButtonActive.value ? rightTextStyle : medium14TextStyle(cLineColor2),
                    )),
              ),
          ],
        );
      },
    );
  }

  void setKeyboardValue(value, keyValue) {
    keyValue.value = value;
    ll(value);
  }

  void blankBottomSheet({
    required context,
    required Widget content,
    double? bottomSheetHeight,
    bool? isScrollControlled,
  }) {
    showModalBottomSheet<void>(
      isScrollControlled: isScrollControlled ?? false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(k16BorderRadius), topRight: Radius.circular(k16BorderRadius)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(k16BorderRadius), topRight: Radius.circular(k16BorderRadius)), color: cWhiteColor),
              width: width,
              height: MediaQuery.of(context).viewInsets.bottom > 0.0 ? height * .9 : bottomSheetHeight ?? height * .5,
              constraints: BoxConstraints(minHeight: bottomSheetHeight ?? height * .5, maxHeight: height * .9),
              child: Column(
                children: [
                  kH4sizedBox,
                  Container(
                    decoration: BoxDecoration(
                      color: cLineColor,
                      borderRadius: k4CircularBorderRadius,
                    ),
                    height: 5,
                    width: width * .1,
                  ),
                  kH10sizedBox,
                  Expanded(
                    child: SingleChildScrollView(
                      child: content,
                    ),
                  ),
                  kH4sizedBox,
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  final searchController = TextEditingController();
  final recentSearch = RxList();

  final Rx<String?> userName = Rx<String?>(null);
  final Rx<String?> userFirstName = Rx<String?>(null);
  final Rx<String?> userLastName = Rx<String?>(null);
  final Rx<String?> userImage = Rx<String?>(null);
  final Rx<String?> userEmail = Rx<String?>(null);
  final Rx<int?> userId = Rx<int?>(null);
  final Rx<String?> userToken = Rx<String?>(null);

  Future<void> getUserInfo() async {
    SpController spController = SpController();
    userName.value = await spController.getUserName();
    userFirstName.value = await spController.getUserFirstName();
    userLastName.value = await spController.getUserLastName();
    userImage.value = await spController.getUserImage();
    userEmail.value = await spController.getUserEmail();
    userId.value = await spController.getUserId();
    userToken.value = await spController.getBearerToken();
    var userData = await spController.getUserData(userToken.value);
    ll("--- : $userData");
    if (userData != null) {
      userName.value = userData['name'];
      userFirstName.value = userData['first_name'];
      userLastName.value = userData['last_name'];
      userImage.value = userData['image_url'];
      userEmail.value = userData['email'];
      userId.value = userData['id'];
      userToken.value = userData['token'];
    }
  }

  RxList<Map<String, dynamic>> allOnlineUsers = RxList<Map<String, dynamic>>([]);
  void populatePeerList(newUserData) {
    //todo: for same user add restriction
    allOnlineUsers.add({"userID": newUserData});

    if (Get.find<MessengerController>().allRoomMessageList.isNotEmpty) {
      Get.find<MessengerController>().updateRoomListWithOnlineUsers();
    }
  }

  final RxDouble keyboardHeight = RxDouble(0.0);
  //! end
}
