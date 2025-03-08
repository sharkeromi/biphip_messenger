

import 'package:biphip_messenger/utils/constants/imports.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final GestureTapCallback? onPressed;
  final double? buttonWidth, prefixIconSize;
  final double? buttonHeight;
  final Color? buttonColor, borderColor, prefixIconColor, suffixIconColor;
  final bool isCircularHead;
  final IconData? prefixIcon, suffixIcon;
  final TextStyle? textStyle;
  final bool? isCustomButton;
  final Color? disableColor;

  const CustomElevatedButton({
    Key? key,
    this.buttonColor = cPrimaryColor,
    this.borderColor,
    required this.label,
    required this.onPressed,
    this.buttonWidth,
    this.prefixIcon,
    this.buttonHeight,
    this.isCircularHead = false,
    this.textStyle,
    this.prefixIconColor,
    this.suffixIconColor,
    this.suffixIcon,
    this.isCustomButton,
    this.prefixIconSize, this.disableColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            minimumSize: MaterialStateProperty.all(Size.zero),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: isCircularHead ? BorderRadius.circular(50) : BorderRadius.circular(k4BorderRadius),
              side: BorderSide(color: (buttonColor == cWhiteColor) ? (borderColor ?? cPrimaryColor) : cTransparentColor, width: 1),
            )),
            backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return disableColor?? cPlaceHolderColor;
              }
              return buttonColor!;
            }),
            splashFactory: InkRipple.splashFactory,
          ),
          child: SizedBox(
            height: buttonHeight ?? (isDeviceScreenLarge() ? (kButtonHeight) : (kButtonHeight - 4)),
            width: isCustomButton == true ? null : (buttonWidth ?? width * .5),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isCustomButton != true ? 0.0 : 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: k4Padding),
                      child: Icon(
                        prefixIcon!,
                        color: prefixIconColor ?? cWhiteColor,
                        size: prefixIconSize ?? screenWiseSize(kIconSize16, 4),
                      ),
                    ),
                  Text(label.toString(), textAlign: TextAlign.center, style: textStyle),
                  if (suffixIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(left: k8Padding),
                      child: Icon(
                        suffixIcon!,
                        color: suffixIconColor ?? cWhiteColor,
                        size: screenWiseSize(suffixIcon == BipHip.downArrow ? kIconSize20 : kIconSize16, 4),
                      ),
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
