import 'package:biphip_messenger/controllers/common/global_controller.dart';
import 'package:biphip_messenger/controllers/common/sp_controller.dart';
import 'package:biphip_messenger/controllers/messenger/messenger_controller.dart';
import 'package:biphip_messenger/models/messenger/message_list_model.dart';
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
            Get.find<MessengerController>().registerPeerConnectionListeners(peerConnection, data['userID']);
          }
        } else {
          peerConnection = await createPeerConnection(Get.find<MessengerController>().configuration);
          ll("CREATED NEW PEER CoNNECTION");
          allRoomMessageListMap[data['userID']]!['peerConnection'] = peerConnection;
          Get.find<MessengerController>().registerPeerConnectionListeners(peerConnection, data['userID']);
        }

        peerConnection?.onDataChannel = (channel) {
          ll("On DATA Channel: ${channel.label}");

          Get.find<MessengerController>().setUpRoomDataChannel(data['userID'], channel);
          channel.onDataChannelState = (RTCDataChannelState state) {
            Get.find<MessengerController>().handleRTCEvents(state);
          };

          channel.onMessage = (RTCDataChannelMessage message) {
            ll('Received message: ${message.text}');
            ll("USER ID: ${data['userID']} DATA CHANNEL: ${channel.label}");
            int index = Get.find<MessengerController>().allRoomMessageList.indexWhere((user) => user['userID'] == data['userID']);
            if (index != -1) {
              ll("here");
              globalController.showSnackBar(
                  title: Get.find<MessengerController>().allRoomMessageList[index]["userName"], message: message.text, color: Colors.green);
              Get.find<MessengerController>().allRoomMessageList[index]["isSeen"] = false.obs;
              Get.find<MessengerController>().allRoomMessageList[index]["messages"].insert(
                    0,
                    MessageData(text: message.text, senderId: data['userID'], messageText: message.text, senderImage: data['userImage']),
                  );
            }
          };
        };

        ll('Setting remote description');
        RTCSessionDescription description = RTCSessionDescription(data['data']['sdp'], data['data']['type']);
        await peerConnection?.setRemoteDescription(description);

        peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
          ll("GENERATED ICE CANDIDATE");
          socket.emit('mobile-chat-peer-exchange-${data['userID']}', {
            'userID': Get.find<GlobalController>().userId.value,
            'type': "candidate",
            'data': {
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            }
          });
        };
      } else if (data['type'] == EmitType.answer.name) {
        ll("GOT NEW ANSWER: $data");
        Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in Get.find<MessengerController>().allRoomMessageList) user['userID']: user};
        peerConnection = allRoomMessageListMap[data['userID']]!['peerConnection'];
        ll("PC null: ${peerConnection == null}");
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
        if (allRoomMessageListMap[data['userID']]!['peerConnection'] != null) {
          ll("PC already created");
          peerConnection = allRoomMessageListMap[data['userID']]!['peerConnection'];
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

    socket.on('mobile-call-${Get.find<GlobalController>().userId.value}', (data) async {
      Get.find<MessengerController>().callState.value = data['callStatus'];
      if (data['callStatus'] == CallStatus.ringing.name) {
        Get.find<MessengerController>().onCallRing(data);
      } else if (data['callStatus'] == CallStatus.decline.name) {
        Get.find<MessengerController>().onDeclineCall();
      } else if (data['callStatus'] == CallStatus.hangUp.name) {
        await Get.find<MessengerController>().onHangUpCall();
      } else if (data['callStatus'] == CallStatus.inCAll.name) {
        if (data["type"] == EmitType.answer.name) {
          Get.find<MessengerController>().onCallStart(data);
        } else if (data["type"] == "callSettings") {
          if (data["data"] == "switchToAudio") {
            Get.find<MessengerController>().onSwitchToAudioCall(data["userID"]);
          } else if (data["data"] == "switchToVideo") {
            if (data['sdp_type'] == "offer") {
              Get.find<MessengerController>().onSwitchToVideoCall(data);
            } else {
              Get.find<MessengerController>().videoCallSwitchSDPSet(data);
            }
          }
        }
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

enum CallStatus {
  ringing,
  inCAll,
  decline,
  hangUp;

  String toJson() => name;
}

enum CallType {
  audio,
  video;

  String toJson() => name;
}
