import 'package:biphip_messenger/controllers/messenger/messenger_controller.dart';
import 'package:biphip_messenger/helpers/messenger/messenger_helper.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/utils/constants/strings.dart';
import 'package:biphip_messenger/utils/constants/urls.dart';
import 'package:biphip_messenger/view/message/widgets/tagger_friend_shimmer.dart';
import 'package:biphip_messenger/widgets/common/button/custom_text_button.dart';
import 'package:biphip_messenger/widgets/common/textfields/custom_textfield.dart';
import 'package:biphip_messenger/widgets/common/utils/common_loading_animation.dart';
import 'package:biphip_messenger/widgets/common/utils/custom_app_bar.dart';
import 'package:biphip_messenger/widgets/common/utils/custom_list_item.dart';

class CreateGroupScreen extends StatelessWidget {
  CreateGroupScreen({super.key});
  final MessengerController messengerController = Get.find<MessengerController>();
  final MessengerHelper messengerHelper = MessengerHelper();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cWhiteColor,
      child: Obx(
        () => Stack(
          children: [
            SafeArea(
              top: false,
              child: SizedBox(
                height: height,
                child: Scaffold(
                  backgroundColor: cWhiteColor,
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(kAppBarSize),
                    //* info:: appBar
                    child: CustomAppBar(
                      hasBackButton: true,
                      isCenterTitle: true,
                      title: ksCreateGroup.tr,
                      onBack: () {
                        Get.back();
                      },
                      action: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: CustomTextButton(
                              onPressed: messengerController.canCreateGroup.value
                                  ? () async {
                                      await messengerController.createGroup();
                                    }
                                  : null,
                              text: ksOk.tr,
                              textStyle: semiBold16TextStyle(messengerController.canCreateGroup.value ? cPrimaryColor : cIconColor)),
                        )
                      ],
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kHorizontalPadding),
                    child: SingleChildScrollView(
                      child: Obx(() => messengerController.isUserListLoading.value
                          ? const TagFriendShimmer()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomModifiedTextField(
                                  controller: messengerController.groupNameTextEditingController,
                                  hint: ksGroupName.tr,
                                  onChanged: (value) {
                                    messengerHelper.checkCanCreateGroup();
                                  },
                                ),
                                kH12sizedBox,
                                if (messengerController.selectedUsers.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: k2Padding, bottom: k8Padding),
                                    child: Text(
                                      ksSelected.tr,
                                      style: semiBold14TextStyle(cBlackColor),
                                    ),
                                  ),
                                if (messengerController.selectedUsers.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: k12Padding),
                                    child: Container(
                                      color: cWhiteColor,
                                      height: 40,
                                      width: width,
                                      child: ListView.separated(
                                        separatorBuilder: (context, index) => kW8sizedBox,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: messengerController.selectedUsers.length,
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            alignment: AlignmentDirectional.topEnd,
                                            children: [
                                              Container(
                                                height: h40,
                                                width: h40,
                                                decoration: const BoxDecoration(
                                                  color: cWhiteColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: ClipOval(
                                                  child: Image.network(
                                                    messengerController.selectedUsers[index].profilePicture.toString(),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Image.asset(kiProfileDefaultImageUrl);
                                                    },
                                                    loadingBuilder: imageLoadingBuilder,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                child: InkWell(
                                                  onTap: () {
                                                    ll(messengerController.userList.length);
                                                    ll(messengerController.tempUserIndex[index]);
                                                    if (messengerController.tempUserIndex[index] > messengerController.userList.length) {
                                                      messengerController.userList.add(messengerController.selectedUsers[index]);
                                                    } else {
                                                      messengerController.userList
                                                          .insert(messengerController.tempUserIndex[index], messengerController.selectedUsers[index]);
                                                    }
                                                    messengerController.tempUserIndex.removeAt(index);
                                                    messengerController.selectedUsers.removeAt(index);
                                                    messengerHelper.checkCanCreateGroup();
                                                  },
                                                  child: Container(
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
                                  child: Text(
                                    ksSuggestionAllCap.tr,
                                    style: regular14TextStyle(cSmallBodyTextColor),
                                  ),
                                ),
                                kH8sizedBox,
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: messengerController.userList.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: k10Padding),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(k8BorderRadius),
                                        child: TextButton(
                                          style: kTextButtonStyle,
                                          onPressed: () {
                                            messengerController.selectedUsers.add(messengerController.userList[index]);
                                            messengerController.tempUserIndex.add(index);
                                            messengerController.userList.removeAt(index);
                                            messengerHelper.checkCanCreateGroup();
                                          },
                                          child: CustomListTile(
                                            padding: const EdgeInsets.symmetric(horizontal: k0Padding, vertical: k4Padding),
                                            leading: Container(
                                              height: h40,
                                              width: h40,
                                              decoration: const BoxDecoration(
                                                color: cWhiteColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: ClipOval(
                                                child: Image.network(
                                                  messengerController.userList[index].profilePicture.toString(),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Image.asset(kiProfileDefaultImageUrl);
                                                  },
                                                  loadingBuilder: imageLoadingBuilder,
                                                ),
                                              ),
                                            ),
                                            title: messengerController.userList[index].fullName,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            )),
                    ),
                  ),
                ),
              ),
            ),
            if (messengerController.isCreateGroupLoading.value == true)
              Positioned(
                child: CommonLoadingAnimation(
                  onWillPop: () async {
                    if (messengerController.isCreateGroupLoading.value) {
                      return false;
                    }
                    return true;
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
