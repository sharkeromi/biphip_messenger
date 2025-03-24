import 'dart:developer';
import 'package:biphip_messenger/controllers/common/call_audio_service.dart';
import 'package:biphip_messenger/controllers/common/socket_controller.dart';
import 'package:biphip_messenger/controllers/messenger/messenger_controller.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/utils/constants/routes.dart';
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

  Future<void> intiVideoCallSwitcher() async {
    var stream = await webRTC.navigator.mediaDevices.getUserMedia({'video': true, 'audio': true});

    messengerController.localStream = stream;

    messengerController.localRenderer.srcObject = stream;
    messengerController.isLocalFeedStreaming.value = true;
  }

  Future<void> initAudioCallSwitcher() async {
    var stream = await webRTC.navigator.mediaDevices.getUserMedia({'video': false, 'audio': true});

    messengerController.localStream = stream;
  }

  Future<void> hangUp(roomID) async {
    await AudioService().stopAudio();
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

    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in messengerController.allRoomMessageList) room['roomID']: room};
    Map<String, dynamic>? room = allRoomMessageListMap[roomID];
    List<dynamic> peerConnectionList = room!["peerConnectionList"];
    for (var peerConnection in peerConnectionList) {
      if (peerConnection["remoteRenderer"].srcObject != null) {
        List<webRTC.MediaStreamTrack> remoteTracks = peerConnection["remoteRenderer"].srcObject!.getTracks();
        for (var track in remoteTracks) {
          log("remote track stopped");
          track.stop();
        }
      }

      // Stop remoteStream tracks
      if (peerConnection["remoteStream"] != null) {
        peerConnection["remoteStream"].getTracks().forEach((track) async {
          log("Remote stopped");
          await track.stop();
        });
        await peerConnection["remoteStream"].dispose();
        peerConnection["remoteStream"] = null;
      }
    }

    stopForegroundService();
    messengerController.disposeRenderer(roomID);
    messengerController.isInCallState.value = false;
    messengerController.isRemoteFeedStreaming.value = false;
    messengerController.isLocalFeedStreaming.value = false;
    Get.back();
  }

  void stopForegroundService() async {
    await webRTC.Helper.setSpeakerphoneOn(false);
  }

  Future<void> switchCamera() async {
    if (messengerController.localStream != null && messengerController.localStream!.getVideoTracks().isNotEmpty) {
      var videoTrack = messengerController.localStream!.getVideoTracks().first;
      webRTC.Helper.switchCamera(videoTrack);
    } else {
      ll("No local video stream or video tracks available.");
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

  Future<void> goToCreateGroup() async {
    resetCreateGroup();
    Get.toNamed(krCreateGroup);
    await messengerController.getUserList();
  }

  void resetCreateGroup() {
    messengerController.selectedUsers.clear();
    messengerController.canCreateGroup.value = false;
    messengerController.tempUserIndex.clear();
  }

  void checkCanCreateGroup() {
    if (messengerController.selectedUsers.isNotEmpty && messengerController.groupNameTextEditingController.text.trim().isNotEmpty) {
      messengerController.canCreateGroup.value = true;
    } else {
      messengerController.canCreateGroup.value = false;
    }
  }

  void checkCanAddMember() {
    if (messengerController.selectedUsers.isNotEmpty) {
      messengerController.canCreateGroup.value = true;
    } else {
      messengerController.canCreateGroup.value = false;
    }
  }

  void resetAddMember() {
    messengerController.addMemberList.clear();
    messengerController.selectedUsers.clear();
    messengerController.canCreateGroup.value = false;
    messengerController.tempUserIndex.clear();
  }

  Future<void> goToAddMember() async {
    resetAddMember();
    Get.toNamed(krAddMember);
    await messengerController.getUserList();
    messengerController.addMemberList.addAll(messengerController.userList
        .where((user) => !messengerController.selectedRoom.value!.participants!.any((member) => member.userId == user.id))
        .toList());
  }
}
