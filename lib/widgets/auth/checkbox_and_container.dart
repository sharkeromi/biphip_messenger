

import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/utils/constants/strings.dart';
import 'package:biphip_messenger/widgets/common/button/custom_checkbox.dart';
import 'package:biphip_messenger/widgets/common/button/custom_text_button.dart';

class CheckBoxAndContainer extends StatelessWidget {
  const CheckBoxAndContainer({
    Key? key,
    required this.onTapCheckBox,
    required this.onPressForgetButton,
    required this.isChecked,
  }) : super(key: key);

  final Function(bool?) onTapCheckBox;
  final VoidCallback onPressForgetButton;
  final RxBool isChecked;

  @override
  Widget build(BuildContext context) {
    var textStyle = regular14TextStyle(cPrimaryColor);
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IntrinsicWidth(
            child: CustomCheckBox(
              value: isChecked.value,
              onChanged: onTapCheckBox,
              label: ksRememberMe.tr,
              textStyle: regular14TextStyle(cBlackColor),
            ),
          ),
          CustomTextButton(
            onPressed: onPressForgetButton,
            textStyle: textStyle,
            text: ksForgotPassword.tr,
          ),
        ],
      ),
    );
  }
}
