import 'package:biphip_messenger/utils/constants/imports.dart';

class RoomDetailsActionButton extends StatelessWidget {
  const RoomDetailsActionButton({super.key, required this.icon, required this.onPressed, required this.buttonText});
  final IconData icon;
  final Function() onPressed;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          child: Container(
            height: h32,
            width: h32,
            decoration: BoxDecoration(
              color: cNeutralColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: h18,
              color: cBlackColor,
            ),
          ),
        ),
        kH4sizedBox,
        Text(
          buttonText,
          style: regular12TextStyle(cBlackColor),
        ),
      ],
    );
  }
}
