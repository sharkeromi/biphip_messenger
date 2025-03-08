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
      if (data['type'] == EmitType.status.name) {
        Get.find<GlobalController>().populatePeerList(data['userID']);
      } else if (data['type'] == EmitType.offer.name) {
        ll("GOT NEW OFFER: $data");
        RTCPeerConnection? peerConnection = await createPeerConnection(Get.find<MessengerController>().configuration);
        Get.find<MessengerController>().registerPeerConnectionListeners(peerConnection, data);
        ll('Setting remote description');
        RTCSessionDescription description = RTCSessionDescription(data['data']['sdp'], data['data']['type']);
        await peerConnection.setRemoteDescription(description);
      } else if (data['type'] == EmitType.answer.name) {
        ll("GOT NEW ANSWER: $data");
      } else if (data['type'] == EmitType.candidate.name) {
        ll("GOT NEW CANDIDATE: $data");
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
