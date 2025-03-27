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
                        Expanded(
                          child: RTCVideoView(
                            messengerController.inCallParticipants[0]["remoteRenderer"],
                            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          ),
                        ),
                        Expanded(
                          child: RTCVideoView(
                            messengerController.localRenderer,
                            mirror: true,
                            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
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
                          Row(
                            children: [
                              SizedBox(
                                height: height / 2,
                                width: width / 2,
                                child: RTCVideoView(
                                  messengerController.inCallParticipants[0]["remoteRenderer"],
                                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                ),
                              ),
                              SizedBox(
                                height: height / 2,
                                width: width / 2,
                                child: RTCVideoView(
                                  messengerController.inCallParticipants[1]["remoteRenderer"],
                                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: height / 2,
                            width: width,
                            child: RTCVideoView(
                              messengerController.localRenderer,
                              mirror: true,
                              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (messengerController.inCallParticipants.length > 2)
                    GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                        ),
                        itemCount: messengerController.inCallParticipants.length + 1,
                        itemBuilder: (context, index) {
                          if (index == messengerController.inCallParticipants.length) {
                            return RTCVideoView(
                              messengerController.localRenderer,
                              mirror: true,
                              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                            );
                          } else {
                            return RTCVideoView(
                              messengerController.inCallParticipants[index]["remoteRenderer"],
                              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                            );
                          }
                        }),
                  Positioned(
                    bottom: 70,
                    // left: (width / 2) - 35,
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
