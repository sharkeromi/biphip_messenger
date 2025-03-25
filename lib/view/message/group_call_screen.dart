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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      Map<int?, Map<String, dynamic>> allRoomMessageListMap = {for (var room in messengerController.allRoomMessageList) room['roomID']: room};
                      // Find the room
                      Map<String, dynamic>? room = allRoomMessageListMap[messengerController.roomID.value];
                      List<dynamic> peerConnectionList = room!["peerConnectionList"];
                      List<dynamic> inCallParticipants = [];
                      for (var participant in peerConnectionList) {
                        if (participant['remoteStream'] != null) {
                          inCallParticipants.add(participant);
                        }
                      }
                      ll(inCallParticipants.length);
                      if (inCallParticipants.length == 1) {
                        return Column(
                          children: [
                            Expanded(
                              child: RTCVideoView(
                                inCallParticipants[0]["remoteRenderer"],
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
                        );
                      } else if (inCallParticipants.length == 2) {
                        return SizedBox(
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
                                      inCallParticipants[0]["remoteRenderer"],
                                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                    ),
                                  ),
                                  SizedBox(
                                    height: height / 2,
                                    width: width / 2,
                                    child: RTCVideoView(
                                      inCallParticipants[1]["remoteRenderer"],
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
                        );
                      } else {
                        return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1,
                            ),
                            itemCount: inCallParticipants.length + 1,
                            itemBuilder: (context, index) {
                              if (index == inCallParticipants.length) {
                                return RTCVideoView(
                                  messengerController.localRenderer,
                                  mirror: true,
                                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                );
                              } else {
                                return RTCVideoView(
                                  inCallParticipants[index]["remoteRenderer"],
                                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                );
                              }
                            });
                      }
                    },
                  ),
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
                                socket.emit('mobile-call-${messengerController.callerID.value}', {
                                  'userID': Get.find<GlobalController>().userId.value,
                                  'roomID': messengerController.roomID.value,
                                  'callStatus': CallStatus.hangUp.name,
                                });
                                await MessengerHelper().hangUp(messengerController.roomID.value);
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
