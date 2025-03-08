

import 'package:biphip_messenger/utils/constants/imports.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    heightWidthKeyboardValue(context);
    return Scaffold(
      backgroundColor: cWhiteColor,
      body: SizedBox(
        height: height,
        width: width,
        child:Text("BipHip \nMessenger"),
      ),
    );
  }
}
