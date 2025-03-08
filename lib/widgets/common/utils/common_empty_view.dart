



import 'package:biphip_messenger/utils/constants/imports.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.title, this.height, this.titleTextStyle});
  final String title;
  final double? height;
  final TextStyle? titleTextStyle;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Text(
          title,
          style: titleTextStyle ?? semiBold16TextStyle(cPlaceHolderColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
