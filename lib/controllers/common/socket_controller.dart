import 'package:biphip_messenger/controllers/common/global_controller.dart';
import 'package:biphip_messenger/controllers/common/sp_controller.dart';
import 'package:biphip_messenger/controllers/messenger/messenger_controller.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class SocketController {
  final GlobalController globalController = Get.find<GlobalController>();

  // Connect with socket
  void socketInit() async {
    var id = await SpController().getUserId();
    if (id != null) {
      Get.find<GlobalController>().userId.value = id;
    }

    socket.connect();

    socket.on('connect', (_) {
      ll('Socket Connected: ${socket.id}');
      if (Get.find<GlobalController>().userId.value != null) {
        socket.emit('mobile-chat-event', {
          'type': EmitType.status.name,
          'userID': Get.find<GlobalController>().userId.value,
        });
      }
    });

    // Listening to global
    socket.on('mobile-chat-event', (data) async {
      ll('Received ID from Global event: $data');

      if (data['type'] == EmitType.status.name) {
        Get.find<GlobalController>().populatePeerList(data['userID']);
        socket.emit('mobile-chat-peer-exchange-${data['userID']}', {
          'type': EmitType.status.name,
          'userID': Get.find<GlobalController>().userId.value,
        });
      }
    });

    socket.on("mobile-chat-peer-exchange-${Get.find<GlobalController>().userId.value}", (data) async {
      RTCPeerConnection? peerConnection;
      if (data['type'] == EmitType.status.name) {
        Get.find<GlobalController>().populatePeerList(data['userID']);
      } else if (data['type'] == EmitType.offer.name) {
        RTCPeerConnection? peerConnection;
        Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in Get.find<MessengerController>().allRoomMessageList) user['userID']: user};

        ll("GOT NEW OFFER: $data");
        if (allRoomMessageListMap.containsKey(data['userID'])) {
          if (allRoomMessageListMap[data['userID']]!['peerConnection'] != null) {
            peerConnection = allRoomMessageListMap[data['userID']]!['peerConnection'];
          } else {
            peerConnection = await createPeerConnection(Get.find<MessengerController>().configuration);
            ll("CREATED NEW PEER CoNNECTION");
            allRoomMessageListMap[data['userID']]!['peerConnection'] = peerConnection;
            Get.find<MessengerController>().registerPeerConnectionListeners(peerConnection, data);
          }
        }

        ll('Setting remote description');
        RTCSessionDescription description = RTCSessionDescription(data['data']['sdp'], data['data']['type']);
        await peerConnection?.setRemoteDescription(description);
      } else if (data['type'] == EmitType.answer.name) {
        ll("GOT NEW ANSWER: $data");
        Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in Get.find<MessengerController>().allRoomMessageList) user['userID']: user};
        if (allRoomMessageListMap.containsKey(data['userID'])) {
          peerConnection = allRoomMessageListMap[data['userID']]!['peerConnection'];
        }
        var answer = RTCSessionDescription(
          data['data']['sdp'],
          data['data']['type'],
        );
        ll("Setting remote answer description");
        await peerConnection?.setRemoteDescription(answer);
        for (int i = 0; i < globalController.iceCandidateList.length; i++) {
          socket.emit('mobile-chat-peer-exchange-${data['userID']}', {
            'userID': Get.find<GlobalController>().userId.value,
            'type': EmitType.candidate.name,
            'data': {
              'candidate': globalController.iceCandidateList[i].candidate,
              'sdpMid': globalController.iceCandidateList[i].sdpMid,
              'sdpMLineIndex': globalController.iceCandidateList[i].sdpMLineIndex,
            }
          });
        }
      } else if (data['type'] == EmitType.candidate.name) {
        ll("GOT NEW CANDIDATE: $data");
        Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in Get.find<MessengerController>().allRoomMessageList) user['userID']: user};
        ll(allRoomMessageListMap);
         if (allRoomMessageListMap.containsKey(data['userID'])) {
          if (allRoomMessageListMap[data['userID']]!['peerConnection'] != null) {
            ll("PC already created");
            peerConnection = allRoomMessageListMap[data['userID']]!['peerConnection'];
          }
         }
        peerConnection!.addCandidate(
          RTCIceCandidate(
            data['data']['candidate'],
            data['data']['sdpMid'],
            data['data']['sdpMLineIndex'],
          ),
        );
      }
    });
  }
}

enum EmitType {
  status,
  offer,
  answer,
  candidate;

  String toJson() => name;
}
