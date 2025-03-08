

import 'package:biphip_messenger/utils/constants/imports.dart';

class CustomCheckBox extends StatelessWidget {
  final bool value;
  final String label;
  final ValueChanged<bool?> onChanged;
  final TextStyle textStyle;

  const CustomCheckBox({
    required this.value,
    required this.label,
    required this.onChanged,
    required this.textStyle,
    Key? key,
  }) : super(key: key);

  Widget buildCheckBox() {
    return Container(
      width: isDeviceScreenLarge() ? h18 : h14,
      height: isDeviceScreenLarge() ? h18 : h14,
      decoration: BoxDecoration(
        border: Border.all(color: value ? cPrimaryColor : cIconColor, width: 1),
        borderRadius: BorderRadius.circular(k4BorderRadius),
        color: value ? cPrimaryColor : cWhiteColor,
      ),
      child: value
          ? Icon(
              Icons.check,
              color: cWhiteColor,
              size: isDeviceScreenLarge() ? kIconSize14 : kIconSize12,
            )
          : null,
    );
  }

  Widget buildLabel() {
    return Expanded(
      child: Text(
        label.toString(),
        textAlign: TextAlign.justify,
        style: textStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        color: cTransparentColor,
        child: Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildCheckBox(),
              const SizedBox(width: 10),
              buildLabel(),
              kEmptySizedBox,
            ],
          ),
        ),
      ),
    );
  }
}
