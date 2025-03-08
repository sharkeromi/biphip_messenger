
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCommon extends StatelessWidget {
  const ShimmerCommon({
    super.key,
    required this.widget,
  });

  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[300]!,
      child: widget,
    );
  }
}
