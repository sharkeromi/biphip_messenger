import 'package:biphip_messenger/controllers/common/global_controller.dart';
import 'package:biphip_messenger/controllers/common/socket_controller.dart';
import 'package:biphip_messenger/controllers/messenger/messenger_controller.dart';
import 'package:biphip_messenger/helpers/messenger/messenger_helper.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class GroupCallScreen extends StatelessWidget {
  GroupCallScreen({super.key});
  final MessengerController messengerController = Get.find<MessengerController>();

  @override
  Widget build(BuildContext context) {
    Map<String?, Map<String, dynamic>> asd = {for (var room in messengerController.allRoomMessageList) room['roomID'].toString(): room};

    ll(asd);
    ll(messengerController.inCallParticipants);
    ll(height);
    ll(width);
    return Container(
      color: cWhiteColor,
      child: SafeArea(
        top: false,
        child: Obx(
          () => SizedBox(
            height: height,
            child: Scaffold(
              body: Stack(
                children: [
                  if (messengerController.inCallParticipants.isEmpty)
                    Stack(
                      children: [
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
                  if (messengerController.inCallParticipants.length == 1)
                    Column(
                      children: [
                        SizedBox(
                          height: kAppBarSize,
                        ),
                        messengerController.inCallParticipants[0]["isVideoStreaming"]
                            ? Expanded(
                                child: RTCVideoView(
                                  messengerController.inCallParticipants[0]["remoteRenderer"],
                                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                ),
                              )
                            : Expanded(
                                child: Container(
                                  width: width,
                                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                                  decoration:
                                      BoxDecoration(border: Border.all(color: cLineColor, width: 2), borderRadius: BorderRadius.circular(k12BorderRadius)),
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
                                            messengerController.inCallParticipants[0]["userImage"].toString(),
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
                                      Text(messengerController.inCallParticipants[0]["userName"]),
                                    ],
                                  ),
                                ),
                              ),
                        messengerController.isLocalFeedStreaming.value
                            ? Expanded(
                                child: RTCVideoView(
                                  messengerController.localRenderer,
                                  mirror: true,
                                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                ),
                              )
                            : Expanded(
                                child: Container(
                                  width: width,
                                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                  decoration:
                                      BoxDecoration(border: Border.all(color: cLineColor, width: 2), borderRadius: BorderRadius.circular(k12BorderRadius)),
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
                      ],
                    ),
                  if (messengerController.inCallParticipants.length == 2)
                    SizedBox(
                      height: height,
                      width: width,
                      child: Column(
                        children: [
                          SizedBox(
                            height: kAppBarSize,
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: width / 2,
                                  child: messengerController.inCallParticipants[0]["isVideoStreaming"]
                                      ? RTCVideoView(
                                          messengerController.inCallParticipants[0]["remoteRenderer"],
                                          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                        )
                                      : Container(
                                          margin: EdgeInsets.only(left: 20, right: 5, bottom: 5),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: cLineColor, width: 2), borderRadius: BorderRadius.circular(k12BorderRadius)),
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
                                                    messengerController.inCallParticipants[0]["userImage"].toString(),
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
                                              Text(messengerController.inCallParticipants[0]["userName"]),
                                            ],
                                          ),
                                        ),
                                ),
                                SizedBox(
                                  width: width / 2,
                                  child: messengerController.inCallParticipants[1]["isVideoStreaming"]
                                      ? RTCVideoView(
                                          messengerController.inCallParticipants[1]["remoteRenderer"],
                                          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                        )
                                      : Container(
                                          margin: EdgeInsets.only(left: 5, right: 20, bottom: 5),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: cLineColor, width: 2), borderRadius: BorderRadius.circular(k12BorderRadius)),
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
                                                    messengerController.inCallParticipants[1]["userImage"].toString(),
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
                                              Text(messengerController.inCallParticipants[1]["userName"]),
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
                                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
                                      decoration:
                                          BoxDecoration(border: Border.all(color: cLineColor, width: 2), borderRadius: BorderRadius.circular(k12BorderRadius)),
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
                  if (messengerController.inCallParticipants.length > 2)
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        // mainAxisSpacing: 10,
                        // crossAxisSpacing: 10,
                        crossAxisCount: 2,
                        childAspectRatio: messengerController.inCallParticipants.length == 3 ? width / height : 1,
                      ),
                      itemCount: messengerController.inCallParticipants.length + 1,
                      itemBuilder: (context, index) {
                        if (index == messengerController.inCallParticipants.length) {
                          return messengerController.isLocalFeedStreaming.value
                              ? RTCVideoView(
                                  messengerController.localRenderer,
                                  mirror: true,
                                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                    margin: EdgeInsets.only(left: index % 2 != 0 ? 5 : 20, right: index % 2 != 0 ? 20 : 5),
                                    decoration:
                                        BoxDecoration(border: Border.all(color: cLineColor, width: 2), borderRadius: BorderRadius.circular(k12BorderRadius)),
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
                          return messengerController.inCallParticipants[index]["isVideoStreaming"]
                              ? RTCVideoView(
                                  messengerController.inCallParticipants[index]["remoteRenderer"],
                                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      left: index % 2 != 0 ? 5 : 20,
                                      right: index % 2 != 0 ? 20 : 5,
                                    ),
                                    decoration:
                                        BoxDecoration(border: Border.all(color: cLineColor, width: 2), borderRadius: BorderRadius.circular(k12BorderRadius)),
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
                                              messengerController.inCallParticipants[index]["userImage"].toString(),
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
                                        Text(messengerController.inCallParticipants[index]["userName"]),
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
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Row(
                          mainAxisAlignment:
                              messengerController.callState.value == CallStatus.inCAll.name ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                          children: [
                            if (messengerController.callState.value == CallStatus.inCAll.name)
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
                                  height: 70,
                                  width: 70,
                                  child: Center(
                                    child: Icon(
                                      messengerController.isAudioCallState.value ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                                      color: cWhiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            if (messengerController.callState.value == CallStatus.inCAll.name)
                              InkWell(
                                onTap: () {
                                  MessengerHelper().switchCamera();
                                },
                                child: Container(
                                  decoration: const BoxDecoration(color: cBlackColor, shape: BoxShape.circle),
                                  height: 70,
                                  width: 70,
                                  child: const Center(
                                    child: Icon(
                                      Icons.cameraswitch_rounded,
                                      color: cWhiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            if (messengerController.callState.value == CallStatus.inCAll.name)
                              InkWell(
                                onTap: () {
                                  MessengerHelper().toggleMuteAudio();
                                },
                                child: Container(
                                  decoration: const BoxDecoration(color: cBlackColor, shape: BoxShape.circle),
                                  height: 70,
                                  width: 70,
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
                                height: 70,
                                width: 70,
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
    );
  }
}
