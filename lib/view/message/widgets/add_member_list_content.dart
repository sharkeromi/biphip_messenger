import 'package:biphip_messenger/controllers/messenger/messenger_controller.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/utils/constants/strings.dart';
import 'package:biphip_messenger/widgets/common/button/custom_filter_chips.dart';
import 'package:biphip_messenger/widgets/common/utils/common_shimmer.dart';
import 'package:biphip_messenger/widgets/common/utils/custom_list_item.dart';

class MemberListContent extends StatelessWidget {
  MemberListContent({
    super.key,
  });
  final MessengerController messengerController = Get.find<MessengerController>();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => messengerController.isUserListLoading.value
              ? const AddMemberShimmer()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: messengerController.memberList.length,
                  itemBuilder: (context, index) {
                    final member = messengerController.memberList[index];
                    return CustomListTile(
                      leading: Container(
                        height: h40,
                        width: h40,
                        decoration: const BoxDecoration(
                          color: cWhiteColor,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            member.profilePicture.toString(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              BipHip.user,
                              size: kIconSize24,
                              color: cIconColor,
                            ),
                          ),
                        ),
                      ),
                      title: member.fullName,
                      trailing: Obx(
                        () => CustomChoiceChips(
                          label: messengerController.inviteMemberList.any((invitedMember) {
                            return member.id == invitedMember.id;
                          })
                              ? ksInvited.tr
                              : ksInvite.tr,
                          isSelected: messengerController.inviteMemberList.any((invitedMember) {
                            return member.id == invitedMember.id;
                          }),
                          onSelected: (value) async {
                            await messengerController.inviteUser(member);
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class AddMemberShimmer extends StatelessWidget {
  const AddMemberShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(k8BorderRadius),
          child: CustomListTile(
            // padding: const EdgeInsets.symmetric(horizontal: k0Padding, vertical: k4Padding),
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
        );
      },
    );
  }
}
