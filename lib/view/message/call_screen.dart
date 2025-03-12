import 'package:biphip_messenger/controllers/common/global_controller.dart';
import 'package:biphip_messenger/controllers/common/socket_controller.dart';
import 'package:biphip_messenger/controllers/messenger/messenger_controller.dart';
import 'package:biphip_messenger/helpers/messenger/messenger_helper.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallScreen extends StatelessWidget {
  CallScreen({super.key});

  final MessengerController messengerController = Get.find<MessengerController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cWhiteColor,
      child: SafeArea(
        top: false,
        child: Obx(
          () => SizedBox(
            height: height,
            child: Scaffold(
              backgroundColor: cWhiteColor,
              body: Stack(
                children: [
                  if (messengerController.callState.value == CallStatus.inCAll.name && !messengerController.isAudioCallState.value)
                    messengerController.isRemoteFeedStreaming.value
                        ? (messengerController.callState.value == CallStatus.ringing.name
                            ? RTCVideoView(messengerController.localRenderer, mirror: true)
                            : RTCVideoView(
                                messengerController.remoteRenderer,
                                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                              ))
                        : const SizedBox(),
                  if (messengerController.callState.value == CallStatus.ringing.name ||
                      (messengerController.callState.value == CallStatus.inCAll.name && messengerController.isAudioCallState.value))
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
                        )),
                  Positioned(
                      bottom: 70,
                      // left: (width / 2) - 35,
                      child: SizedBox(
                        width: width,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (!messengerController.isAudioCallState.value)
                                InkWell(
                                  onTap: () {
                                    MessengerHelper().switchCamera(messengerController.callerID.value);
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
                              InkWell(
                                onTap: () async {
                                  socket.emit('mobile-call-${messengerController.callerID.value}', {
                                    'userID': Get.find<GlobalController>().userId.value,
                                    'callStatus': CallStatus.hangUp.name,
                                  });
                                  await MessengerHelper().hangUp();
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
                                      messengerController.isMuted.value ? Icons.mic : Icons.mic_off_rounded,
                                      color: cWhiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  if (messengerController.callState.value == CallStatus.inCAll.name && !messengerController.isAudioCallState.value)
                    Positioned(
                      top: 50,
                      right: 20,
                      child: SizedBox(
                        height: 200,
                        width: 150,
                        child:
                            messengerController.isLocalFeedStreaming.value ? RTCVideoView(messengerController.localRenderer, mirror: true) : const SizedBox(),
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
