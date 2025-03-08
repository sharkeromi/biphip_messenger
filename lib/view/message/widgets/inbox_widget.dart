import 'package:biphip_messenger/controllers/messenger/messenger_controller.dart';
import 'package:biphip_messenger/models/messenger/room_list_model.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/utils/constants/routes.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:intl/intl.dart';

class InboxContainer extends StatelessWidget {
  InboxContainer({
    super.key,
    required this.userName,
    required this.userImage,
    required this.message,
    required this.isActive,
    required this.isSeen,
    required this.isMute,
    required this.isLastMessageSelf,
    required this.userID,
    required this.lastMessageTime,
    required this.roomID,
    required this.index,
    required this.dataChannel,
    this.peerConnection,
    required this.receiverData,
  });
  final String userName, userImage;
  final RxString message;
  final bool isMute, isLastMessageSelf;
  final RxBool isActive, isSeen;
  final int userID, roomID, index;
  final DateTime lastMessageTime;
  final RTCDataChannel? dataChannel;
  final RoomData receiverData;
  final RTCPeerConnection? peerConnection;
  final MessengerController messengerController = Get.find<MessengerController>();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        messengerController.selectedReceiver.value = receiverData;
        messengerController.selectedRoomIndex.value = index;
        await messengerController.connectUser(userID);
        Get.toNamed(krMessages);
        //* GET MESSAGE API CALL
        await messengerController.getMessageList(roomID);
        //*
      },
      child: Container(
        color: cWhiteColor,
        width: width,
        height: h50,
        child: Row(
          children: [
            Stack(
              children: [
                ClipOval(
                  child: Container(
                    height: h50,
                    width: h50,
                    decoration: const BoxDecoration(
                      color: cBlackColor,
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(
                      userImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        BipHip.user,
                        size: kIconSize24,
                        color: cIconColor,
                      ),
                    ),
                  ),
                ),
                if (isActive.value)
                  Positioned(
                    bottom: 3,
                    right: 0,
                    child: Container(
                      height: h14,
                      width: h14,
                      decoration: const BoxDecoration(color: cWhiteColor, shape: BoxShape.circle),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          height: h12,
                          width: h12,
                          decoration: const BoxDecoration(color: cGreenColor, shape: BoxShape.circle),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              height: 4,
                              width: 4,
                              decoration: const BoxDecoration(color: cWhiteColor, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
            kW12sizedBox,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: k4Padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: isSeen.value ? regular16TextStyle(cBlackColor) : semiBold16TextStyle(cBlackColor),
                  ),
                  SizedBox(
                    width: width - 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "${isLastMessageSelf ? "You:" : ""} ${message.value}",
                            style: isSeen.value ? regular14TextStyle(cSmallBodyTextColor) : semiBold14TextStyle(cBlackColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "  • ${DateFormat('h:mm a').format(lastMessageTime)}",
                          style: isSeen.value ? regular14TextStyle(cSmallBodyTextColor) : semiBold14TextStyle(cBlackColor),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (isMute)
              const Icon(
                Icons.notifications_off_rounded,
                color: cIconColor,
                size: kIconSize14,
              ),
            if (isSeen.value)
              ClipOval(
                child: Container(
                  height: h14,
                  width: h14,
                  decoration: const BoxDecoration(
                    color: cBlackColor,
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    userImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      BipHip.user,
                      size: kIconSize14,
                      color: cIconColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
