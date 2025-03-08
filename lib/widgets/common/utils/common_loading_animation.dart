
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CommonLoadingAnimation extends StatelessWidget {
  const CommonLoadingAnimation({super.key, required this.onWillPop, this.backgroundColor});
  final Future<bool> Function() onWillPop;
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Container(
        color: backgroundColor ?? Colors.black.withOpacity(.3),
        child: const Center(
          child: SpinKitThreeBounce(
            color: cPrimaryColor,
            size: 30,
          ),
        ),
      ),
    );
  }
}
