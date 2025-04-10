import 'package:biphip_messenger/controllers/common/global_controller.dart';
import 'package:biphip_messenger/controllers/messenger/messenger_controller.dart';
import 'package:biphip_messenger/helpers/messenger/messenger_helper.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class GroupCallScreen extends StatelessWidget {
  GroupCallScreen({super.key});
  final MessengerController messengerController = Get.find<MessengerController>();

  @override
  Widget build(BuildContext context) {
    ll(messengerController.joinedParticipants);
    ll(messengerController.isLocalFeedStreaming.value);
    return Container(
      color: cWhiteColor,
      child: SafeArea(
        top: false,
        child: Obx(
          () => SizedBox(
            height: height,
            child: Scaffold(
              backgroundColor: cBackgroundColor,
              body: Padding(
                padding: const EdgeInsets.only(
                  top: kAppBarSize,
                ),
                child: Stack(
                  children: [
                    if (messengerController.joinedParticipants.isEmpty)
                      Stack(
                        children: [
                          if (messengerController.isLocalFeedStreaming.value)
                            RTCVideoView(
                              messengerController.localRenderer,
                              mirror: true,
                              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                            ),
                          Positioned(
                            top: 100,
                            child: SizedBox(
                              width: width,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 200,
                                  ),
                                  Container(
                                    height: isDeviceScreenLarge() ? 150 : (150 - h10),
                                    width: isDeviceScreenLarge() ? 150 : (150 - h10),
                                    decoration: BoxDecoration(
                                      color: cBlackColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: cWhiteColor.withAlpha(500), width: 2),
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        messengerController.callerImage.value.toString(),
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
                                  kH20sizedBox,
                                  Text(messengerController.callerName.value),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (messengerController.joinedParticipants.length == 1)
                      Stack(
                        children: [
                          messengerController.joinedParticipants[0]["isVideoStreaming"]
                              ? RTCVideoView(
                                  messengerController.joinedParticipants[0]["remoteRenderer"],
                                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                )
                              : Container(
                                  width: width,
                                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(k12BorderRadius), color: cLineColor),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: isDeviceScreenLarge() ? 150 : (150 - h10),
                                        width: isDeviceScreenLarge() ? 150 : (150 - h10),
                                        decoration: BoxDecoration(
                                          color: cBlackColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: cWhiteColor.withAlpha(500), width: 2),
                                        ),
                                        child: ClipOval(
                                          child: Image.network(
                                            messengerController.joinedParticipants[0]["userImage"].toString(),
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
                                      kH20sizedBox,
                                      Text(messengerController.joinedParticipants[0]["userName"]),
                                    ],
                                  ),
                                ),
                          if (messengerController.isLocalFeedStreaming.value)
                            Positioned(
                              top: 10,
                              right: 30,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 200,
                                width: 130,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: RTCVideoView(
                                    messengerController.localRenderer,
                                    mirror: true,
                                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    if (messengerController.joinedParticipants.length == 2)
                      SizedBox(
                        height: height,
                        width: width,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: width / 2,
                                    child: messengerController.joinedParticipants[0]["isVideoStreaming"]
                                        ? RTCVideoView(
                                            messengerController.joinedParticipants[0]["remoteRenderer"],
                                            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                          )
                                        : Container(
                                            margin: EdgeInsets.only(left: 10, right: 5, bottom: 5),
                                            decoration: BoxDecoration(color: cLineColor, borderRadius: BorderRadius.circular(k12BorderRadius)),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: isDeviceScreenLarge() ? 130 : (130 - h10),
                                                  width: isDeviceScreenLarge() ? 130 : (130 - h10),
                                                  decoration: BoxDecoration(
                                                    color: cBlackColor,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: cWhiteColor.withAlpha(500), width: 2),
                                                  ),
                                                  child: ClipOval(
                                                    child: Image.network(
                                                      messengerController.joinedParticipants[0]["userImage"].toString(),
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
                                                kH20sizedBox,
                                                Text(messengerController.joinedParticipants[0]["userName"]),
                                              ],
                                            ),
                                          ),
                                  ),
                                  SizedBox(
                                    width: width / 2,
                                    child: messengerController.joinedParticipants[1]["isVideoStreaming"]
                                        ? RTCVideoView(
                                            messengerController.joinedParticipants[1]["remoteRenderer"],
                                            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                          )
                                        : Container(
                                            margin: EdgeInsets.only(left: 5, right: 10, bottom: 5),
                                            decoration: BoxDecoration(color: cLineColor, borderRadius: BorderRadius.circular(k12BorderRadius)),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: isDeviceScreenLarge() ? 130 : (130 - h10),
                                                  width: isDeviceScreenLarge() ? 130 : (130 - h10),
                                                  decoration: BoxDecoration(
                                                    color: cBlackColor,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: cWhiteColor.withAlpha(500), width: 2),
                                                  ),
                                                  child: ClipOval(
                                                    child: Image.network(
                                                      messengerController.joinedParticipants[1]["userImage"].toString(),
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
                                                kH20sizedBox,
                                                Text(messengerController.joinedParticipants[1]["userName"]),
                                              ],
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                width: width,
                                child: messengerController.isLocalFeedStreaming.value
                                    ? RTCVideoView(
                                        messengerController.localRenderer,
                                        mirror: true,
                                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                      )
                                    : Container(
                                        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 5),
                                        decoration: BoxDecoration(color: cLineColor, borderRadius: BorderRadius.circular(k12BorderRadius)),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: isDeviceScreenLarge() ? 150 : (150 - h10),
                                              width: isDeviceScreenLarge() ? 150 : (150 - h10),
                                              decoration: BoxDecoration(
                                                color: cBlackColor,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: cWhiteColor.withAlpha(500), width: 2),
                                              ),
                                              child: ClipOval(
                                                child: Image.network(
                                                  Get.find<GlobalController>().userImage.value.toString(),
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
                                            kH20sizedBox,
                                            Text(Get.find<GlobalController>().userName.value!),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (messengerController.joinedParticipants.length > 2)
                      GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          // mainAxisSpacing: 10,
                          // crossAxisSpacing: 10,
                          crossAxisCount: 2,
                          childAspectRatio: messengerController.joinedParticipants.length == 3 ? width / (height - 40) : 1,
                        ),
                        itemCount: messengerController.joinedParticipants.length + 1,
                        itemBuilder: (context, index) {
                          if (index == messengerController.joinedParticipants.length) {
                            return messengerController.isLocalFeedStreaming.value
                                ? RTCVideoView(
                                    messengerController.localRenderer,
                                    mirror: true,
                                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      margin: EdgeInsets.only(left: index % 2 != 0 ? 5 : 10, right: index % 2 != 0 ? 10 : 5),
                                      decoration: BoxDecoration(color: cLineColor, borderRadius: BorderRadius.circular(k12BorderRadius)),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: isDeviceScreenLarge() ? 130 : (130 - h10),
                                            width: isDeviceScreenLarge() ? 130 : (130 - h10),
                                            decoration: BoxDecoration(
                                              color: cBlackColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: cWhiteColor.withAlpha(500), width: 2),
                                            ),
                                            child: ClipOval(
                                              child: Image.network(
                                                Get.find<GlobalController>().userImage.value.toString(),
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
                                          kH20sizedBox,
                                          Text(Get.find<GlobalController>().userName.value!),
                                        ],
                                      ),
                                    ),
                                  );
                          } else {
                            return messengerController.joinedParticipants[index]["isVideoStreaming"]
                                ? RTCVideoView(
                                    messengerController.joinedParticipants[index]["remoteRenderer"],
                                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        left: index % 2 != 0 ? 5 : 10,
                                        right: index % 2 != 0 ? 10 : 5,
                                      ),
                                      decoration: BoxDecoration(color: cLineColor, borderRadius: BorderRadius.circular(k12BorderRadius)),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: isDeviceScreenLarge() ? 130 : (130 - h10),
                                            width: isDeviceScreenLarge() ? 130 : (130 - h10),
                                            decoration: BoxDecoration(
                                              color: cBlackColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: cWhiteColor.withAlpha(500), width: 2),
                                            ),
                                            child: ClipOval(
                                              child: Image.network(
                                                messengerController.joinedParticipants[index]["userImage"].toString(),
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
                                          kH20sizedBox,
                                          Text(messengerController.joinedParticipants[index]["userName"]),
                                        ],
                                      ),
                                    ),
                                  );
                          }
                        },
                      ),
                    Positioned(
                      bottom: 40,
                      child: SizedBox(
                        width: width,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            mainAxisAlignment: messengerController.joinedParticipants.isNotEmpty ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                            children: [
                              if (messengerController.joinedParticipants.isNotEmpty)
                                InkWell(
                                  onTap: () async {
                                    await messengerController.goToAddMemberToCall(context);
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(color: cBlackColor, shape: BoxShape.circle),
                                    height: 55,
                                    width: 55,
                                    child: const Center(
                                      child: Icon(
                                        Icons.person_add,
                                        color: cWhiteColor,
                                      ),
                                    ),
                                  ),
                                ),
                              if (messengerController.joinedParticipants.isNotEmpty)
                                InkWell(
                                  onTap: () async {
                                    if (messengerController.isAudioCallState.value) {
                                      await messengerController.switchToVideoCall(messengerController.roomID.value);
                                    } else {
                                      await messengerController.switchToAudioCall(messengerController.roomID.value);
                                    }
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(color: cBlackColor, shape: BoxShape.circle),
                                    height: 55,
                                    width: 55,
                                    child: Center(
                                      child: Icon(
                                        messengerController.isAudioCallState.value ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                                        color: cWhiteColor,
                                      ),
                                    ),
                                  ),
                                ),
                              if (messengerController.joinedParticipants.isNotEmpty)
                                InkWell(
                                  onTap: () {
                                    MessengerHelper().switchCamera();
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(color: cBlackColor, shape: BoxShape.circle),
                                    height: 55,
                                    width: 55,
                                    child: const Center(
                                      child: Icon(
                                        Icons.cameraswitch_rounded,
                                        color: cWhiteColor,
                                      ),
                                    ),
                                  ),
                                ),
                              if (messengerController.joinedParticipants.isNotEmpty)
                                InkWell(
                                  onTap: () {
                                    MessengerHelper().toggleMuteAudio();
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(color: cBlackColor, shape: BoxShape.circle),
                                    height: 55,
                                    width: 55,
                                    child: Center(
                                      child: Icon(
                                        messengerController.isMuted.value ? Icons.mic_off_rounded : Icons.mic,
                                        color: cWhiteColor,
                                      ),
                                    ),
                                  ),
                                ),
                              InkWell(
                                onTap: () async {
                                  await messengerController.hangUp(messengerController.roomID.value);
                                },
                                child: Container(
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  height: 55,
                                  width: 55,
                                  child: const Center(
                                    child: Icon(
                                      Icons.call,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
