
import 'package:biphip_messenger/utils/constants/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class CustomLoadingAnimation extends StatelessWidget {
  const CustomLoadingAnimation({
    this.isTextVisible = true,
  
    Key? key, this.radius,
  }) : super(key: key);

  final bool isTextVisible;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           CupertinoActivityIndicator(radius: radius??20),
          if (isTextVisible) Text('${ksLoading.tr}...'),
        ],
      ),
    );
  }
}
