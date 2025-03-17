import 'package:biphip_messenger/controllers/messenger/messenger_controller.dart';
import 'package:biphip_messenger/helpers/messenger/messenger_helper.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/utils/constants/strings.dart';
import 'package:biphip_messenger/view/message/widgets/room_details_action_button.dart';
import 'package:biphip_messenger/widgets/common/utils/custom_app_bar.dart';

class RoomDetailsScreen extends StatelessWidget {
  RoomDetailsScreen({super.key});
  final MessengerController messengerController = Get.find<MessengerController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        color: cWhiteColor,
        child: SafeArea(
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
                  // title: ksInbox.tr,
                  onBack: () {
                    Get.back();
                  },
                ),
              ),
              body: SizedBox(
                height: height,
                width: width,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      kH16sizedBox,
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: isDeviceScreenLarge() ? 120 : (150 - h10),
                            width: isDeviceScreenLarge() ? 120 : (150 - h10),
                            decoration: BoxDecoration(
                              color: cBlackColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: cWhiteColor.withAlpha(500), width: 2),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                (messengerController.selectedRoomData.value!.roomImage != null &&
                                        messengerController.selectedRoomData.value!.roomImage!.isNotEmpty)
                                    ? messengerController.selectedRoomData.value!.roomImage![0]
                                    : "default_image_url",
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (context, error, stackTrace) => imageErrorBuilderCover(
                                  context,
                                  error,
                                  stackTrace,
                                  Icons.person_2_rounded,
                                  70.0,
                                ),
                                loadingBuilder: imageLoadingBuilder,
                              ),
                            ),
                          ),
                          kH16sizedBox,
                          Text(
                            messengerController.selectedRoomData.value!.roomName ?? "",
                            style: semiBold20TextStyle(cBlackColor),
                          ),
                          kH16sizedBox,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                RoomDetailsActionButton(
                                  icon: BipHip.phoneFill,
                                  onPressed: () {},
                                  buttonText: ksAudio.tr,
                                ),
                                RoomDetailsActionButton(
                                  icon: BipHip.video,
                                  onPressed: () {},
                                  buttonText: ksVideo.tr,
                                ),
                                if (messengerController.selectedRoomData.value!.type == 2)
                                  RoomDetailsActionButton(
                                    icon: Icons.person_add_alt_rounded,
                                    onPressed: () async {
                                      await MessengerHelper().goToAddMember();
                                    },
                                    buttonText: ksAdd.tr,
                                  ),
                                if (messengerController.selectedRoomData.value!.type == 1)
                                  RoomDetailsActionButton(
                                    icon: Icons.person_2_rounded,
                                    onPressed: () {},
                                    buttonText: ksProfile.tr,
                                  ),
                                RoomDetailsActionButton(
                                  icon: Icons.notifications_rounded,
                                  onPressed: () {},
                                  buttonText: ksMute.tr,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
