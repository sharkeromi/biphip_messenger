import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/widgets/common/utils/common_shimmer.dart';
import 'package:biphip_messenger/widgets/common/utils/custom_list_item.dart';

class TagFriendShimmer extends StatelessWidget {
  const TagFriendShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: k2Padding, bottom: k8Padding),
          child: ShimmerCommon(
            widget: Container(
              decoration: BoxDecoration(color: cWhiteColor, borderRadius: k16CircularBorderRadius),
              height: h12,
              width: h50,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: k12Padding),
          child: Container(
            color: cWhiteColor,
            height: 40,
            width: width,
            child: ListView.separated(
              separatorBuilder: (context, index) => kW8sizedBox,
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    ShimmerCommon(
                      widget: Container(
                        decoration: const BoxDecoration(color: cWhiteColor, shape: BoxShape.circle),
                        height: h40,
                        width: h40,
                      ),
                    ),
                    Positioned(
                      child: ShimmerCommon(
                        widget: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: cWhiteColor,
                          ),
                          child: const Icon(
                            BipHip.circleCrossNew,
                            size: 12,
                            color: cRedColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: k2Padding),
          child: ShimmerCommon(
            widget: Container(
              decoration: BoxDecoration(color: cWhiteColor, borderRadius: k16CircularBorderRadius),
              height: h14,
              width: 80,
            ),
          ),
        ),
        kH8sizedBox,
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 10,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: k10Padding),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(k8BorderRadius),
                child: CustomListTile(
                  padding: const EdgeInsets.symmetric(horizontal: k0Padding, vertical: k4Padding),
                  leading: ShimmerCommon(
                    widget: Container(
                      decoration: const BoxDecoration(color: cWhiteColor, shape: BoxShape.circle),
                      height: h40,
                      width: h40,
                    ),
                  ),
                  title: ShimmerCommon(
                    widget: Container(
                      decoration: BoxDecoration(color: cWhiteColor, borderRadius: k8CircularBorderRadius),
                      height: 12,
                      width: 80,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
