import 'dart:developer';
import 'package:biphip_messenger/controllers/common/socket_controller.dart';
import 'package:biphip_messenger/controllers/messenger/messenger_controller.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webRTC;

class MessengerHelper {
  final MessengerController messengerController = Get.find<MessengerController>();
  Future<void> openUserMedia(String callType) async {
    var stream = await webRTC.navigator.mediaDevices.getUserMedia({'video': callType == CallType.audio.name ? false : true, 'audio': true});

    messengerController.localStream = stream;
    if (callType == CallType.video.name) {
      messengerController.localRenderer.srcObject = stream;
      messengerController.isLocalFeedStreaming.value = true;
    } else {
      messengerController.isLocalFeedStreaming.value = false;
    }
  }

  Future<void> hangUp() async {
    // Stop localRenderer tracks
    if (messengerController.localRenderer.srcObject != null) {
      List<webRTC.MediaStreamTrack> localTracks = messengerController.localRenderer.srcObject!.getTracks();
      for (var track in localTracks) {
        log("Local track stopped");
        track.stop();
      }
    }

    // Stop localStream tracks
    if (messengerController.localStream != null) {
      messengerController.localStream!.getTracks().forEach((track) async {
        log("Local track stopped 2");
        await track.stop();
      });
      await messengerController.localStream!.dispose();
       messengerController.localStream = null;
    }

    if (messengerController.remoteRenderer.srcObject != null) {
      List<webRTC.MediaStreamTrack> remoteTracks = messengerController.remoteRenderer.srcObject!.getTracks();
      for (var track in remoteTracks) {
        log("remote track stopped");
        track.stop();
      }
    }

    // Stop remoteStream tracks
    if (messengerController.remoteStream != null) {
      messengerController.remoteStream!.getTracks().forEach((track) async {
        log("Remote stopped");
        await track.stop();
      });
      await messengerController.remoteStream!.dispose();
      messengerController.remoteStream = null;
    }

    messengerController.disposeRenderer();
    messengerController.isInCallState.value = false;
    messengerController.isRemoteFeedStreaming.value = false;
    messengerController.isLocalFeedStreaming.value = false;
    Get.back();
  }

  Future<void> switchCamera(userID) async {
    if (messengerController.localStream != null && messengerController.localStream!.getVideoTracks().isNotEmpty) {
      var videoTrack = messengerController.localStream!.getVideoTracks().first;
      webRTC.Helper.switchCamera(videoTrack);
    } else {
      print("No local video stream or video tracks available.");
    }
  }

  Future<void> toggleMuteAudio() async {
    var audioTrack = messengerController.localStream?.getAudioTracks().first;

    if (audioTrack != null) {
      audioTrack.enabled = !audioTrack.enabled;
      if (audioTrack.enabled) {
        messengerController.isMuted.value = false;
      } else {
        messengerController.isMuted.value = true;
      }
    }
  }
}
