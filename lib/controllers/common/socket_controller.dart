import 'package:biphip_messenger/controllers/common/global_controller.dart';
import 'package:biphip_messenger/controllers/common/sp_controller.dart';
import 'package:biphip_messenger/controllers/messenger/messenger_controller.dart';
import 'package:biphip_messenger/models/messenger/message_list_model.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class SocketController {
  final GlobalController globalController = Get.find<GlobalController>();
  final MessengerController messengerController = Get.find<MessengerController>();

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
        Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in messengerController.allRoomMessageList) room['roomID']: room};
        Map<String, dynamic>? room = allRoomMessageListMap[data["roomID"]];
      List<dynamic> peerConnectionList = room!["peerConnectionList"];

      Map<String, dynamic>? participant = peerConnectionList.firstWhere(
        (participant) => participant["participantId"] == data["userID"],
        orElse: () => {},
      );

        ll("GOT NEW OFFER: $data");
        if (allRoomMessageListMap.containsKey(data['roomID'])) {
          if (participant!['peerConnection'] != null) {
            peerConnection = participant['peerConnection'];
          } else {
            peerConnection = await createPeerConnection(messengerController.configuration);
            ll("CREATED NEW PEER CoNNECTION");
            participant['peerConnection'] = peerConnection;
            messengerController.registerPeerConnectionListeners(peerConnection, data['userID'], data['roomID']);
          }
        } else {
          peerConnection = await createPeerConnection(messengerController.configuration);
          ll("CREATED NEW PEER CoNNECTION");
          participant!['peerConnection'] = peerConnection;
          messengerController.registerPeerConnectionListeners(peerConnection, data['userID'], data['roomID']);
        }

        peerConnection?.onDataChannel = (channel) {
          ll("On DATA Channel: ${channel.label}");

          messengerController.setUpRoomDataChannel(data['roomID'], data['userID'], channel);
          channel.onDataChannelState = (RTCDataChannelState state) {
            messengerController.handleRTCEvents(state);
          };

          channel.onMessage = (RTCDataChannelMessage message) {
            ll('Received message: ${message.text}');
            ll("USER ID: ${data['userID']} DATA CHANNEL: ${channel.label}");
            int index = messengerController.allRoomMessageList.indexWhere((room) => room['roomID'] == data['roomID']);
            if (index != -1) {
              ll("here");
              globalController.showSnackBar(title: messengerController.allRoomMessageList[index]["userName"], message: message.text, color: Colors.green);
              messengerController.allRoomMessageList[index]["isSeen"] = false.obs;
              messengerController.allRoomMessageList[index]["messages"].insert(
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
            'roomID': data['roomID'],
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
        Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in messengerController.allRoomMessageList) room['roomID']: room};
        Map<String, dynamic>? room = allRoomMessageListMap[data["roomID"]];
      List<dynamic> peerConnectionList = room!["peerConnectionList"];

      Map<String, dynamic>? participant = peerConnectionList.firstWhere(
        (participant) => participant["participantId"] == data["userID"],
        orElse: () => {},
      );
        peerConnection = participant!['peerConnection'];
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
            'roomID': data['roomID'],
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
        Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in messengerController.allRoomMessageList) room['roomID']: room};
         Map<String, dynamic>? room = allRoomMessageListMap[data["roomID"]];
      List<dynamic> peerConnectionList = room!["peerConnectionList"];

      Map<String, dynamic>? participant = peerConnectionList.firstWhere(
        (participant) => participant["participantId"] == data["userID"],
        orElse: () => {},
      );
        if (participant!['peerConnection'] != null) {
          ll("PC already created");
          peerConnection = participant['peerConnection'];
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
      messengerController.callState.value = data['callStatus'];
      if (data['callStatus'] == CallStatus.ringing.name) {
        messengerController.onCallRing(data);
      } else if (data['callStatus'] == CallStatus.decline.name) {
        messengerController.onDeclineCall();
      } else if (data['callStatus'] == CallStatus.hangUp.name) {
        await messengerController.onHangUpCall();
      } else if (data['callStatus'] == CallStatus.inCAll.name) {
        if (data["type"] == EmitType.answer.name) {
          messengerController.onCallStart(data);
        } else if (data["type"] == "callSettings") {
          if (data["data"] == "switchToAudio") {
            messengerController.onSwitchToAudioCall(data["roomID"]);
          } else if (data["data"] == "switchToVideo") {
            if (data['sdp_type'] == "offer") {
              messengerController.onSwitchToVideoCall(data);
            } else {
              messengerController.videoCallSwitchSDPSet(data);
            }
          }
        }
      }
    });

    socket.on('group-chat-${Get.find<GlobalController>().userId.value}', (data) async {
      RTCPeerConnection? peerConnection;
      Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in messengerController.allRoomMessageList) room['roomID']: room};
      Map<String, dynamic>? room = allRoomMessageListMap[data["roomID"]];
      List<dynamic> peerConnectionList = room!["peerConnectionList"];

      Map<String, dynamic>? participant = peerConnectionList.firstWhere(
        (participant) => participant["participantId"] == data["userID"],
        orElse: () => {},
      );
      if (participant!["peerConnection"] == null) {
        peerConnection = await createPeerConnection(messengerController.configuration);
        participant["peerConnection"] = peerConnection;
        messengerController.registerGroupPeerConnectionListeners(peerConnection, data['userID'], data["roomID"]);
      } else {
        peerConnection = participant["peerConnection"];
      }

      if (data['type'] == EmitType.offer.name) {
        peerConnection?.onDataChannel = (channel) {
          ll("On DATA Channel: ${channel.label}");
          messengerController.setUpRoomDataChannel(data['roomID'], data['userID'], channel);
          channel.onDataChannelState = (RTCDataChannelState state) {
            messengerController.handleRTCEvents(state);
          };

          channel.onMessage = (RTCDataChannelMessage message) {
            ll('Received Group message: ${message.text}');
            ll("USER ID: ${data['userID']} DATA CHANNEL: ${channel.label}");
            int index = messengerController.allRoomMessageList.indexWhere((room) => room['roomID'] == data['roomID']);
            if (index != -1) {
              globalController.showSnackBar(title: messengerController.allRoomMessageList[index]["userName"], message: message.text, color: Colors.green);
              messengerController.allRoomMessageList[index]["isSeen"] = false.obs;
              messengerController.allRoomMessageList[index]["messages"].insert(
                0,
                //todo: set user image
                MessageData(text: message.text, senderId: data['userID'], messageText: message.text, senderImage: data['userImage']),
              );
            }
          };
        };
        ll('Setting remote description');
        RTCSessionDescription description = RTCSessionDescription(data['data']['sdp'], data['data']['type']);
        peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
          ll("GENERATED ICE CANDIDATE");
          socket.emit('group-chat-${data['userID']}', {
            'userID': Get.find<GlobalController>().userId.value,
            'roomID': data['roomID'],
            'type': "candidate",
            'data': {
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            }
          });
        };
        await peerConnection?.setRemoteDescription(description);
      } else if (data['type'] == EmitType.answer.name) {
        ll("GOT NEW ANSWER: $data");
        var answer = RTCSessionDescription(
          data['data']['sdp'],
          data['data']['type'],
        );
        ll("Setting remote answer description");
        await peerConnection?.setRemoteDescription(answer);
        setGroupPeerConnection(data['roomID'], data['userID'], peerConnection);
        for (int i = 0; i < globalController.iceCandidateList.length; i++) {
          socket.emit('group-chat-${data['userID']}', {
            'userID': Get.find<GlobalController>().userId.value,
            'roomID': data['roomID'],
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
        await peerConnection!.addCandidate(
          RTCIceCandidate(
            data['data']['candidate'],
            data['data']['sdpMid'],
            data['data']['sdpMLineIndex'],
          ),
        );
        setGroupPeerConnection(data['roomID'], data['userID'], peerConnection);
      }
    });
  }

  void setGroupPeerConnection(roomID, userID, peerConnection) {
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in messengerController.allRoomMessageList) room['roomID']: room};
    for (var peer in allRoomMessageListMap[roomID]!['peerConnectionList']) {
      if (peer['participantId'] == userID) {
        peer['peerConnection'] = peerConnection;
        break;
      }
    }
    messengerController.allRoomMessageList.clear();
    messengerController.allRoomMessageList.addAll(allRoomMessageListMap.values.toList());
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
