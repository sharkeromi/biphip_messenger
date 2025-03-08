import 'package:biphip_messenger/controllers/auth/authentication_controller.dart';
import 'package:biphip_messenger/helpers/auth/login_helper.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/utils/constants/strings.dart';
import 'package:biphip_messenger/widgets/auth/checkbox_and_container.dart';
import 'package:biphip_messenger/widgets/common/button/custom_button.dart';
import 'package:biphip_messenger/widgets/common/textfields/custom_textfield.dart';
import 'package:biphip_messenger/widgets/common/utils/common_loading_animation.dart';

class Login extends StatelessWidget {
  Login({Key? key}) : super(key: key);

  final AuthenticationController authenticationController = Get.find<AuthenticationController>();
  final LoginHelper loginHelper = LoginHelper();

  @override
  Widget build(BuildContext context) {
    heightWidthKeyboardValue(context);
    return Container(
      decoration: const BoxDecoration(
        color: cWhiteColor,
      ),
      child: Obx(
        () => Stack(
          children: [
            SafeArea(
              top: false,
              child: Scaffold(
                backgroundColor: cTransparentColor,
                body: SizedBox(
                  height: height,
                  width: width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        kH30sizedBox,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: h20),
                          child: CustomModifiedTextField(
                            errorText: authenticationController.loginEmailErrorText.value,
                            controller: authenticationController.loginEmailTextEditingController,
                            hint: ksEmailOrPhone.tr,
                            textHintStyle: regular16TextStyle(cPlaceHolderColor2),
                            fillColor: cWhiteColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(k4BorderRadius),
                              borderSide: const BorderSide(width: 1, color: cLineColor2),
                            ),
                            onChanged: (text) {
                              loginHelper.loginEmailEditorOnChanged();
                            },
                            onSubmit: (text) {},
                            inputAction: TextInputAction.next,
                            inputType: TextInputType.emailAddress,
                          ),
                        ),
                        authenticationController.errorTextWiseResponsiveSizedBox(authenticationController.loginEmailErrorText.value),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: h20),
                          child: CustomModifiedTextField(
                            errorText: authenticationController.loginPasswordErrorText.value,
                            controller: authenticationController.loginPasswordTextEditingController,
                            hint: ksPassword.tr,
                            textHintStyle: regular16TextStyle(cPlaceHolderColor2),
                            fillColor: cWhiteColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(k4BorderRadius),
                              borderSide: const BorderSide(width: 1, color: cLineColor2),
                            ),
                            suffixIcon: authenticationController.isLoginPasswordToggleObscure.value ? BipHip.passwordHide : Icons.visibility_outlined,
                            onSuffixPress: () {
                              authenticationController.isLoginPasswordToggleObscure.value = !authenticationController.isLoginPasswordToggleObscure.value;
                            },
                            onChanged: (text) {
                              loginHelper.loginPasswordEditorOnChanger();
                            },
                            onSubmit: (text) {},
                            obscureText: authenticationController.isLoginPasswordToggleObscure.value,
                            inputAction: TextInputAction.done,
                            inputType: TextInputType.visiblePassword,
                          ),
                        ),
                        authenticationController.errorTextWiseResponsiveSizedBox(authenticationController.loginPasswordErrorText.value),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: h20),
                          child: CheckBoxAndContainer(
                            isChecked: authenticationController.isLoginRememberCheck,
                            onTapCheckBox: (v) {
                              authenticationController.isLoginRememberCheck.value = !authenticationController.isLoginRememberCheck.value;
                            },
                            onPressForgetButton: () {},
                          ),
                        ),
                        kH24sizedBox,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: h20),
                          child: CustomElevatedButton(
                            label: ksLogin.tr,
                            onPressed: authenticationController.canLogin.value
                                ? () async {
                                    unFocus(context);
                                    await authenticationController.userLogin();
                                  }
                                : null,
                            buttonWidth: width - 40,
                            textStyle:
                                authenticationController.canLogin.value ? semiBold16TextStyle(cWhiteColor) : semiBold16TextStyle(cWhiteColor.withOpacity(.7)),
                          ),
                        ),
                        kH28sizedBox,
                        kH40sizedBox,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (authenticationController.isLoginLoading.value == true)
              Positioned(
                child: CommonLoadingAnimation(
                  onWillPop: () async {
                    if (authenticationController.isLoginLoading.value) {
                      return false;
                    }
                    return true;
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
