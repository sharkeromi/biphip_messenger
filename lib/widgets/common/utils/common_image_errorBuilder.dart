

import 'package:biphip_messenger/utils/constants/imports.dart';

class CommonImageErrorBuilder extends StatelessWidget {
  const CommonImageErrorBuilder({super.key, required this.icon, required this.iconSize});
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: iconSize,
      color: cIconColor,
    );
  }
}
