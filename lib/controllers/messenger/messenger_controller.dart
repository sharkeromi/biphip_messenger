import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:biphip_messenger/controllers/common/api_controller.dart';
import 'package:biphip_messenger/controllers/common/call_audio_service.dart';
import 'package:biphip_messenger/controllers/common/global_controller.dart';
import 'package:biphip_messenger/controllers/common/socket_controller.dart';
import 'package:biphip_messenger/controllers/common/sp_controller.dart';
import 'package:biphip_messenger/helpers/messenger/messenger_helper.dart';
import 'package:biphip_messenger/models/common/common_data_model.dart';
import 'package:biphip_messenger/models/common/common_error_model.dart';
import 'package:biphip_messenger/models/common/common_user_model.dart';
import 'package:biphip_messenger/models/messenger/message_list_model.dart';
import 'package:biphip_messenger/models/messenger/room_list_model.dart';
import 'package:biphip_messenger/models/messenger/user_list_model.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/utils/constants/routes.dart';
import 'package:biphip_messenger/utils/constants/strings.dart';
import 'package:biphip_messenger/utils/constants/urls.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class MessengerController extends GetxController {
  final GlobalController globalController = Get.find<GlobalController>();
  final SpController spController = SpController();
  final ApiController apiController = ApiController();
  final TextEditingController messageTextEditingController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();
  final RxBool isMessageTextFieldFocused = RxBool(false);
  final RxBool isSendEnabled = RxBool(false);
  final Rx<RoomData?> selectedRoom = Rx<RoomData?>(null);
  final RxInt selectedRoomInde = RxInt(-1);
  final AudioService audioService = AudioService();

  @override
  void onInit() async {
    checkInternetConnectivity();
    messageFocusNode.addListener(() {
      if (messageFocusNode.hasFocus) {
        isMessageTextFieldFocused.value = true;
      } else {
        isMessageTextFieldFocused.value = false;
      }
    });

    super.onInit();
  }

  Future<void> initializeRenderer(roomID) async {
    inCallParticipants.clear();
    ll("HERE");
    if (localRenderer.textureId == null) {
      ll("HERE Initializing localRenderer");
      localRenderer = RTCVideoRenderer();
      await localRenderer.initialize();
    }

    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
    for (var participant in allRoomMessageListMap[roomID]!["peerConnectionList"]) {
      var remoteRenderer = RTCVideoRenderer();
      await remoteRenderer.initialize();
      participant["remoteRenderer"] = remoteRenderer;
      // inCallParticipants
      //     .add({'userID': participant['participantId'], 'remoteStream': participant['remoteStream'], 'remoteRenderer': participant["remoteRenderer"]});
      allRoomMessageList.clear();
      allRoomMessageList.addAll(allRoomMessageListMap.values.toList());
    }
  }

  void disposeRenderer(roomID) {
    localRenderer.dispose();
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
    Map<String, dynamic>? room = allRoomMessageListMap[roomID];
    List<dynamic> peerConnectionList = room!["peerConnectionList"];
    for (var participants in peerConnectionList) {
      if (participants["remoteRenderer"] != null) {
        participants["remoteRenderer"].srcObject = null;
        participants["remoteRenderer"].dispose();
      }
    }
  }

  // @override
  // void onClose() {
  //   super.onClose();
  //   // disposeRenderer();
  // }

  //=====================================================
  //!          Check for internet connection
  //=====================================================

  //=====================================================

  void checkCanSendMessage() {
    if (messageTextEditingController.text.trim() == "") {
      isSendEnabled.value = false;
    } else {
      isSendEnabled.value = true;
    }
  }

  //============================================
  //!         Send Message Data Persistency
  //============================================

  List<String> messageQueue = [];
  int batchSize = 1;

  void sendMessage(String message, roomID) async {
    if (isInternetConnectionAvailable.value) {
      setMessage(selectedRoom.value!.id, MessageData(text: message, senderId: globalController.userId.value, messageText: message));

      sendViaDataChannel(message, roomID);

      messageQueue.add(message);

      if (messageQueue.length >= batchSize && isInternetConnectionAvailable.value) {
        for (int i = 0; i < messageQueue.length; i++) {
          sendBatchMessages(messageQueue[i]);
        }
        messageQueue.clear();
      }
      messageTextEditingController.clear();
    }
  }

  void sendViaDataChannel(String message, roomID) {
    Map<int, Map<String, dynamic>> roomMap = {for (var room in allRoomMessageList) room['roomID']: room};
    Map<String, dynamic>? room = roomMap[roomID];
    List<dynamic> peerConnectionList = room!["peerConnectionList"];

    for (var participant in peerConnectionList) {
      if (participant["dataChannel"].state == RTCDataChannelState.RTCDataChannelOpen) {
        participant["dataChannel"].send(RTCDataChannelMessage(message));
      }
    }
  }

  // Send through API
  final RxBool isSendMessageLoading = RxBool(false);
  Future<void> sendBatchMessages(message) async {
    try {
      isSendMessageLoading.value = true;
      String? token = await spController.getBearerToken();
      Map<String, dynamic> body = {
        'room_id': selectedRoom.value!.id.toString(),
        'message': message.toString(),
      };
      var response = await apiController.commonApiCall(
        requestMethod: kPost,
        url: kuSendMessage,
        body: body,
        token: token,
      ) as CommonDM;
      if (response.success == true) {
      } else {
        isSendMessageLoading.value = false;
        ErrorModel errorModel = ErrorModel.fromJson(response.data);
        if (errorModel.errors.isEmpty) {
          globalController.showSnackBar(title: ksError.tr, message: response.message, color: cRedColor);
        } else {
          globalController.showSnackBar(title: ksError.tr, message: errorModel.errors[0].message, color: cRedColor);
        }
      }
    } catch (e) {
      isSendMessageLoading.value = false;
      ll('sendBatchMessages error: $e');
    }
  }

  // Get Messages
  RxList<Map<String, dynamic>> allRoomMessageList = RxList<Map<String, dynamic>>([]);
  void geAllRoomMessages() {
    for (int i = 0; i < roomList.length; i++) {
      List peerConnectionList = [];
      for (var participants in roomList[i].participants!) {
        if (participants.userId != globalController.userId.value) {
          peerConnectionList.add({
            "participantId": participants.userId,
            "participantName": participants.userNickname,
            "participantImage": participants.userImage,
            "peerConnection": null,
            "dataChannel": null,
            "dataChannelLabel": "",
            "remoteStream": null,
            "remoteRenderer": null,
          });
        }
      }
      allRoomMessageList.add({
        "roomData": roomList[i],
        "roomID": roomList[i].id,
        "userID": roomList[i].roomUserId,
        "dataChannelLabel": "",
        "dataChannel": null,
        "peerConnection": null,
        "peerConnectionList": peerConnectionList,
        "participants": roomList[i].participants,
        "status": false.obs,
        "userName": roomList[i].roomName,
        "userImage": (roomList[i].roomImage != null && roomList[i].roomImage!.isNotEmpty) ? roomList[i].roomImage! : ["default_image_url"],
        "isSeen": true.obs,
        "lastMessageTime": roomList[i].updatedAt,
        "messages": RxList([]),
      });
    }
    if (globalController.allOnlineUsers.isNotEmpty) {
      updateRoomListWithOnlineUsers();
    }
  }

  void updateRoomListWithOnlineUsers() {
    Map<int, Map<String, dynamic>> onlineUserMap = {for (var onlineUser in globalController.allOnlineUsers) onlineUser['userID']: onlineUser};

    for (var room in allRoomMessageList) {
      if (onlineUserMap.containsKey(room['userID'])) {
        room['status'] = true.obs;
      }
    }
    RxList<Map<String, dynamic>> temporaryAllRoomMessageList = RxList<Map<String, dynamic>>([]);
    temporaryAllRoomMessageList.addAll(allRoomMessageList);
    allRoomMessageList.clear();
    allRoomMessageList.addAll(temporaryAllRoomMessageList);
  }

  // Set Messages
  void setMessage(roomID, messageData) {
    int index = allRoomMessageList.indexWhere((room) => room['roomID'] == roomID);
    if (index != -1) {
      allRoomMessageList[index]["messages"].insert(0, messageData);
      var roomData = allRoomMessageList[index];
      allRoomMessageList.remove(allRoomMessageList[index]);
      allRoomMessageList.insert(0, roomData);
      // selectedRoomIndex.value = 0;
    }
  }

  //==============================================
  //!           API Implementations
  //==============================================

  final RxBool isInboxLoading = RxBool(false);
  final RxBool roomListScrolled = RxBool(false);
  final Rx<RoomListModel?> roomListData = Rx<RoomListModel?>(null);
  final RxList<RoomData> roomList = RxList<RoomData>([]);
  Future<void> getRoomList() async {
    // try {
    isInboxLoading.value = true;
    String suffixUrl = '?take=15';
    String? token = await spController.getBearerToken();
    var response = await apiController.commonApiCall(
      requestMethod: kGet,
      token: token,
      url: kuGetRoomList + suffixUrl,
    ) as CommonDM;
    if (response.success == true) {
      roomList.clear();
      allRoomMessageList.clear();
      roomListScrolled.value = false;
      roomListData.value = RoomListModel.fromJson(response.data);
      roomList.addAll(roomListData.value!.rooms!.data!);
      geAllRoomMessages();
      isInboxLoading.value = false;
    } else {
      isInboxLoading.value = true;
      ErrorModel errorModel = ErrorModel.fromJson(response.data);
      if (errorModel.errors.isEmpty) {
        globalController.showSnackBar(title: ksError.tr, message: response.message, color: cRedColor);
      } else {
        globalController.showSnackBar(title: ksError.tr, message: errorModel.errors[0].message, color: cRedColor);
      }
    }
    // } catch (e) {
    //   isInboxLoading.value = true;
    //   ll('getRoomList error: $e');
    // }
  }

  final RxBool isMessageListLoading = RxBool(false);
  final RxBool messageListScrolled = RxBool(false);
  final Rx<MessageListModel?> messageListData = Rx<MessageListModel?>(null);
  final RxList<MessageData> messageList = RxList<MessageData>([]);
  Future<void> getMessageList(roomID) async {
    // try {
    isMessageListLoading.value = true;
    String suffixUrl = '?take=15';
    String? token = await spController.getBearerToken();
    var response = await apiController.commonApiCall(
      requestMethod: kGet,
      token: token,
      url: "$kuGetMessageList?room_id=$roomID$suffixUrl&page=1&message_id=",
    ) as CommonDM;
    if (response.success == true) {
      messageList.clear();
      roomListScrolled.value = false;
      messageListData.value = MessageListModel.fromJson(response.data);
      messageList.addAll(messageListData.value!.messages!.data!);
      populateRoomMessageList(roomID, messageList);
      isMessageListLoading.value = false;
    } else {
      isMessageListLoading.value = true;
      ErrorModel errorModel = ErrorModel.fromJson(response.data);
      if (errorModel.errors.isEmpty) {
        globalController.showSnackBar(title: ksError.tr, message: response.message, color: cRedColor);
      } else {
        globalController.showSnackBar(title: ksError.tr, message: errorModel.errors[0].message, color: cRedColor);
      }
    }
    // } catch (e) {
    //   isMessageListLoading.value = true;
    //   ll('getMessageList error: $e');
    // }
  }

  void populateRoomMessageList(roomID, messageList) {
    int index = allRoomMessageList.indexWhere((user) => user['roomID'] == roomID);
    if (index != -1) {
      allRoomMessageList[index]["messages"].clear();
      allRoomMessageList[index]["messages"].addAll(messageList);
    }
  }

  //=====================================================
  //!          Check for internet connection
  //=====================================================

  final RxBool isInternetConnectionAvailable = RxBool(false);
  late StreamSubscription<InternetConnectionStatus> internetConnectivitySubscription;
  Future<void> initConnectivity() async {
    try {
      bool internetConnectivityResult = await InternetConnectionChecker.createInstance().hasConnection;
      if (internetConnectivityResult != true) {
        isInternetConnectionAvailable.value = false;
      } else {
        isInternetConnectionAvailable.value = true;
      }
    } on SocketException catch (e) {
      ll('Connectivity status error: $e');
      isInternetConnectionAvailable.value = false;
    } on PlatformException catch (e) {
      ll('Connectivity status error: $e');
      isInternetConnectionAvailable.value = false;
    }
  }

  Future<void> checkInternetConnectivity() async {
    await initConnectivity();
    internetConnectivitySubscription = InternetConnectionChecker.createInstance().onStatusChange.listen(
      (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            isInternetConnectionAvailable.value = true;
            break;
          case InternetConnectionStatus.disconnected:
            isInternetConnectionAvailable.value = false;
            break;
          case InternetConnectionStatus.slow:
            throw UnimplementedError();
        }
      },
    );
  }

  //*===================== WEB RTC FUNCTIONS ===============================*//
  final Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': "stun:stun.l.google.com:19302"},
      {
        "urls": [
          "turn:54.91.252.241:3478",
        ],
        "username": "user1",
        "credential": "123456",
      },
    ],
  };

  Future<void> connectUser(userID, roomID) async {
    Map<int?, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
    // Find the room
    Map<String, dynamic>? room = allRoomMessageListMap[roomID];
    List<dynamic> peerConnectionList = room!["peerConnectionList"];
    ll("CREATING PEER CONNECTION");
    RTCPeerConnection peerConnection = await createPeerConnection(configuration);

    ll("CREATING DATA CHANNEL");
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
    dataChannelDict.ordered = true;
    String dataChannelName = "room-$roomID";
    RTCDataChannel dataChannel = await peerConnection.createDataChannel(dataChannelName, dataChannelDict);
    setupDataChannelListeners(dataChannel, roomID);
    registerPeerConnectionListeners(peerConnection, userID, roomID);

    for (var participant in peerConnectionList) {
      participant["peerConnection"] = peerConnection;
      participant["dataChannel"] = dataChannel;
      participant["dataChannelLabel"] = dataChannel.label;
    }

    allRoomMessageList.clear();
    allRoomMessageList.addAll(allRoomMessageListMap.values.toList());

    ll("Creating offer");
    RTCSessionDescription offer = await peerConnection.createOffer();
    globalController.iceCandidateList.clear();
    ll("Setting local description");
    await peerConnection.setLocalDescription(offer);

    ll("Sending offer");
    socket.emit('mobile-chat-peer-exchange-$userID', {
      'userID': Get.find<GlobalController>().userId.value,
      'roomID': roomID,
      'type': EmitType.offer.name,
      'data': {
        'sdp': offer.sdp,
        'type': offer.type,
      }
    });

    peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      globalController.iceCandidateList.add(candidate);
      Map<String, dynamic> data = {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      };
      ll("CREATING ICE CANDIDATE $data");
      socket.emit('mobile-chat-peer-ice-candidate-$userID', {
        'userID': Get.find<GlobalController>().userId.value,
        'roomID': roomID,
        'type': EmitType.candidate.name,
        'data': data,
      });
    };

    setUpRoomDataChannel(roomID, userID, dataChannel);
  }

  void registerPeerConnectionListeners(RTCPeerConnection? peerConnection, userID, roomID) {
    peerConnection?.onConnectionState = (RTCPeerConnectionState state) async {
      ll('Connection state change: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        await peerConnection.restartIce();
      }
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) async {
      ll('Signaling state change: $state');

      if (state == RTCSignalingState.RTCSignalingStateHaveRemoteOffer) {
        Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
        try {
          var answer = await peerConnection.createAnswer();
          ll('Created Answer $answer');
          await peerConnection.setLocalDescription(answer);
          if (isInCallState.value) {
            socket.emit('mobile-call-$userID', {
              'userID': globalController.userId.value,
              'roomID': roomID,
              'callStatus': CallStatus.inCAll.name,
              'type': EmitType.answer.name,
              'data': {
                'sdp': answer.sdp,
                'type': answer.type,
              }
            });
          } else {
            socket.emit('mobile-chat-peer-exchange-$userID', {
              'userID': Get.find<GlobalController>().userId.value,
              'roomID': roomID,
              'type': EmitType.answer.name,
              'data': {
                'sdp': answer.sdp,
                'type': answer.type,
              }
            });
          }

          List<dynamic> peerConnectionList = allRoomMessageListMap[roomID]!["peerConnectionList"];
          for (var participant in peerConnectionList) {
            if (participant["participantId"] == userID) {
              participant["peerConnection"] = peerConnection;
            }
          }

          allRoomMessageList.clear();
          allRoomMessageList.addAll(allRoomMessageListMap.values.toList());
        } catch (e) {
          ll("EXCEPTION: $e");
        }
      }
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      ll('ICE connection state change: $state');
    };

    peerConnection?.onRenegotiationNeeded = () {
      ll("RE NEGOTIATION NEEDED");
      if (isNegotiating.value) {
        ll("Skipping renegotiation to prevent collision.");
        return;
      }
      isNegotiating.value = true;
      // renegotiate(peerConnection, userID);
      isNegotiating.value = false;
    };

    peerConnection?.onTrack = (RTCTrackEvent event) async {
      ll('Got remote track sc: ${event.streams[0]}');
      if (remoteStream == null) {
        ll('Initializing remoteStream');
        remoteStream = await createLocalMediaStream('remoteStream');
      } else {
        ll('remoteStream already initialized');
      }

      event.streams[0].getTracks().forEach((track) {
        ll('Add a track to the remoteStream: $track');
        remoteStream?.addTrack(track);
        remoteRenderer.srcObject = remoteStream;
        if (track.kind == 'video') {
          isRemoteFeedStreaming.value = true;
        }
      });
    };

    peerConnection?.onAddTrack = (MediaStream stream, MediaStreamTrack track) async {
      ll("GETTING REMOTE TRACK SC: $track ${stream.id}");
      if (remoteStream == null) {
        ll('Initializing remoteStream');
        remoteStream = await createLocalMediaStream('remoteStream');
      } else {
        ll('remoteStream already initialized');
      }
      remoteRenderer.srcObject = stream;
      remoteStream = stream;
      if (track.kind == 'video') {
        isRemoteFeedStreaming.value = true;
      }
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      ll("Getting remote stream");
    };
  }

  RxBool isNegotiating = RxBool(false);

  Future<void> renegotiate(RTCPeerConnection peerConnection, userID) async {
    if (peerConnection.signalingState == RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
      ll("Skipping renegotiation: Already have a local offer");
      return;
    }
    if (peerConnection.signalingState == RTCSignalingState.RTCSignalingStateStable) {
      ll("Creating new offer for renegotiation");

      RTCSessionDescription? offer;
      try {
        offer = await peerConnection.createOffer();
        if (offer.sdp == null || offer.sdp!.isEmpty) {
          ll("Error: Offer SDP is null or empty");
          return;
        }
      } catch (e) {
        ll("Error creating offer: $e");
        return;
      }
      RTCSessionDescription sanitizedOffer = sanitizeSDP(offer);

      try {
        ll("Setting new local description");
        await peerConnection.setLocalDescription(sanitizedOffer);
      } catch (e) {
        ll("Error setting local description: $e");
        return;
      }

      socket.emit('mobile-chat-peer-exchange-$userID', {
        'userID': Get.find<GlobalController>().userId.value,
        'type': EmitType.offer.name,
        'data': {
          'sdp': sanitizedOffer.sdp,
          'type': sanitizedOffer.type,
        }
      });
    } else {
      ll("Skipping renegotiation: Signaling state is ${peerConnection.signalingState}");
    }
  }

// Ensures media order consistency
  RTCSessionDescription sanitizeSDP(RTCSessionDescription sessionDescription) {
    String sdp = sessionDescription.sdp!;

    List<String> lines = sdp.split("\n");
    lines.sort((a, b) {
      if (a.startsWith("m=video")) return -1;
      if (b.startsWith("m=video")) return 1;
      if (a.startsWith("m=audio")) return -1;
      if (b.startsWith("m=audio")) return 1;
      return 0;
    });
    var offer = RTCSessionDescription(lines.join("\n"), sessionDescription.type);
    ll("SDP: ${offer.sdp}");
    ll("TYPE: ${offer.type}");
    return offer;
  }

  void handleRTCEvents(RTCDataChannelState state) {
    switch (state) {
      case RTCDataChannelState.RTCDataChannelOpen:
        ll('dc connection success');

        break;

      case RTCDataChannelState.RTCDataChannelClosed:
        ll(' dc closed ');

        break;
      case RTCDataChannelState.RTCDataChannelConnecting:
        break;
      case RTCDataChannelState.RTCDataChannelClosing:
        break;
    }
  }

  void setupDataChannelListeners(RTCDataChannel dataChannel, roomID) {
    dataChannel.onDataChannelState = (RTCDataChannelState state) {
      ll("STATE CHANGED: $state");
    };

    dataChannel.onMessage = (RTCDataChannelMessage message) {
      ll('Received message: ${message.text}');
      ll("ROOM NAME: $roomID DATA CHANNEL: ${dataChannel.label}");
      int index = allRoomMessageList.indexWhere((room) => room["roomID"] == roomID);
      if (index != -1) {
        // globalController.showSnackBar(title: allRoomMessageList[index]["userName"], message: message.text, color: Colors.green);
        allRoomMessageList[index]["isSeen"] = false.obs;
        allRoomMessageList[index]["messages"].insert(
            0,
            //todo one to one set image
            MessageData(text: message.text, senderId: selectedRoom.value!.roomUserId, messageText: message.text, senderImage: ""));
        var roomData = allRoomMessageList[index];
        allRoomMessageList.remove(allRoomMessageList[index]);
        allRoomMessageList.insert(0, roomData);
      }
    };
  }

  void setUpRoomDataChannel(roomID, userID, dataChannel) async {
    Map<int, Map<String, dynamic>> roomMap = {for (var room in allRoomMessageList) room['roomID']: room};
    Map<String, dynamic>? room = roomMap[roomID];
    List<dynamic> peerConnectionList = room!["peerConnectionList"];

    for (var participant in peerConnectionList) {
      if (participant["participantId"] == userID) {
        participant["dataChannel"] = dataChannel;
        participant["dataChannelLabel"] = dataChannel.label;
      }
    }
    allRoomMessageList.clear();
    allRoomMessageList.addAll(roomMap.values.toList());
  }

  //*--------Audio Video Call Functions--------*//
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  MediaStream? localStream;
  MediaStream? remoteStream;

  final RxBool isAudioCallState = RxBool(false);
  final RxBool isUserTypeSender = RxBool(false);
  final RxBool isLocalFeedStreaming = RxBool(false);
  final RxBool isRemoteFeedStreaming = RxBool(false);
  final RxBool isMuted = RxBool(false);

  final RxString callState = RxString("");
  final RxString callerName = RxString("");
  final RxString callerImage = RxString("");
  final RxInt roomID = RxInt(-1);
  final RxInt callerID = RxInt(-1);
  final RxBool isInCallState = RxBool(false);

  final RxList<Map<String, dynamic>> callOfferList = RxList([]);
  final RxList<Map<String, dynamic>> inCallParticipants = RxList([]);

  //Ring function for Sender
  Future<void> ringUser(roomId, String callType, roomType) async {
    isUserTypeSender.value = true;
    roomID.value = selectedRoom.value!.id!;
    callerID.value = selectedRoom.value!.roomUserId ?? 0;
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
    callerName.value = allRoomMessageListMap[roomId]!['userName'];
    callerImage.value = allRoomMessageListMap[roomId]!['userImage'][0];

    callState.value = CallStatus.ringing.name;
    if (callType == CallType.audio.name) {
      isAudioCallState.value = true;
    } else {
      isAudioCallState.value = false;
    }
    await initializeRenderer(roomID);
    await initiateVideoCall(roomId, callType, roomType);
    if (roomType == 1) {
      Get.toNamed(krCallScreen);
    } else {
      Get.toNamed(krGroupCallScreen);
    }
    if (callType == CallType.video.name) {
      await audioService.playAudio(callerTunePath, isSpeaker: true);
    } else {
      await audioService.playAudio(callerTunePath, isSpeaker: false);
    }
  }

  Future<void> initiateVideoCall(roomID, String callType, roomType) async {
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};

    await MessengerHelper().openUserMedia(callType);

    for (var participant in allRoomMessageListMap[roomID]!["peerConnectionList"]) {
      RTCPeerConnection? peerConnection;
      peerConnection = participant!['peerConnection'];
      localStream?.getTracks().forEach((track) {
        ll("ON VIDEO CALL START GETTING LOCAL TRACK: $track");
        peerConnection?.addTrack(track, localStream!);
      });

      RTCSessionDescription? offer;

      if (callType == CallType.audio.name) {
        offer = await peerConnection!.createOffer({
          'offerToReceiveAudio': true,
          'offerToReceiveVideo': false,
        });
      } else {
        offer = await peerConnection!.createOffer();
      }

      await peerConnection.setLocalDescription(offer);
      participant['peerConnection'] = peerConnection;
      allRoomMessageList.clear();
      allRoomMessageList.addAll(allRoomMessageListMap.values.toList());
      socket.emit('mobile-call-${participant['participantId']}', {
        'userID': Get.find<GlobalController>().userId.value,
        'roomID': roomID,
        'roomType': roomType,
        'callStatus': CallStatus.ringing.name,
        'callType': callType,
      });
      socket.emit('mobile-call-${participant['participantId']}', {
        'userID': Get.find<GlobalController>().userId.value,
        'roomID': roomID,
        'type': "offer",
        'data': {
          'sdp': offer.sdp,
          'type': offer.type,
        },
      });
    }

    if (callType == CallType.audio.name) {
      Helper.setSpeakerphoneOn(false);
    } else {
      Helper.setSpeakerphoneOn(true);
    }
    // todo: may need to store the peer connection
  }

  void saveOffers(data) {
    ll("SAVED OFFER: ${data['userID']}");
    callOfferList.add({"userID": data['userID'], 'sdp': data['data']['sdp'], 'type': data['data']['type']});
  }

  //Ring function for Receiver
  final RxInt roomType = RxInt(-1);
  void onCallRing(data) {
    isInCallState.value = true;
    isUserTypeSender.value = false;
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
    callerName.value = allRoomMessageListMap[data['roomID']]!['userName'];
    callerImage.value = allRoomMessageListMap[data['roomID']]!['userImage'][0];
    roomID.value = data['roomID'];
    callerID.value = data['userID'];
    roomType.value = data['roomType'];
    if (data['callType'] == CallType.audio.name) {
      isAudioCallState.value = true;
    } else {
      isAudioCallState.value = false;
    }
    audioService.playAudio(ringtonePath, isSpeaker: true);
    Get.toNamed(krRingingScreen);
  }

  //Decline from receiver
  void onDeclineCall() {
    audioService.stopAudio();
    Get.back();
    globalController.showSnackBar(title: "Call declined!", message: "${callerName.value} declined the call", color: Colors.red, duration: 1000);
  }

  //Hangup from both sides
  Future<void> onHangUpCall(data) async {
    await audioService.stopAudio();
    await MessengerHelper().onHangUp(data);
  }

  Future<void> hangUp(roomID) async {
    inCallParticipants.clear();
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
    for (var participant in allRoomMessageListMap[roomID]!["peerConnectionList"]) {
      socket.emit('mobile-call-${participant['participantId']}', {
        'userID': Get.find<GlobalController>().userId.value,
        'roomID': roomID,
        'callStatus': CallStatus.hangUp.name,
      });
    }
    await MessengerHelper().hangUp(roomID);
  }

  //Accept call from receiver
  void onAcceptCall(roomID, callType) async {
    // try {
    await initializeRenderer(roomID);
    await MessengerHelper().openUserMedia(isAudioCallState.value ? CallType.audio.name : CallType.video.name);

    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
    for (var participant in allRoomMessageListMap[roomID]!["peerConnectionList"]) {
      RTCPeerConnection? peerConnection;
      if (participant!['peerConnection'] == null) {
        peerConnection = await createPeerConnection(configuration);
        if (roomType.value == 1) {
          registerPeerConnectionListeners(peerConnection, participant['participantId'], roomID);
        } else {
          registerGroupPeerConnectionListeners(peerConnection, participant["participantId"], roomID);
        }
      } else {
        peerConnection = participant!['peerConnection'];
      }
      localStream?.getTracks().forEach((track) async {
        ll("ON ANSWER VIDEO CALL GETTING LOCAL TRACK: $track");
        await peerConnection!.addTrack(track, localStream!);
      });

      Map<int, Map<String, dynamic>> offerListMap = {for (var callOffer in callOfferList) callOffer['userID']: callOffer};
      if (participant!['participantId'] == callerID.value || offerListMap.containsKey(participant['participantId'])) {
        ll('Setting remote description for video call');
        Map<int, Map<String, dynamic>> offerListMap = {for (var callOffer in callOfferList) callOffer['userID']: callOffer};
        if (offerListMap.containsKey(participant['participantId'])) {
          RTCSessionDescription description =
              RTCSessionDescription(offerListMap[participant['participantId']]!['sdp'], offerListMap[participant['participantId']]!['type']);
          try {
            await peerConnection?.setRemoteDescription(description);
            ll("Remote description set successfully.: ${description.sdp}");
          } catch (e) {
            ll("Error setting remote description: $e");
            return;
          }
        }
      } else {
        RTCSessionDescription? offer;
        if (isAudioCallState.value) {
          offer = await peerConnection!.createOffer({
            'offerToReceiveAudio': true,
            'offerToReceiveVideo': false,
          });
        } else {
          offer = await peerConnection!.createOffer();
        }
        await peerConnection.setLocalDescription(offer);
        socket.emit('mobile-call-${participant['participantId']}', {
          'userID': Get.find<GlobalController>().userId.value,
          'roomID': roomID,
          'type': "offer",
          'data': {
            'sdp': offer.sdp,
            'type': offer.type,
          },
        });
        peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
          ll("GENERATED ICE CANDIDATE");
          socket.emit('group-chat-${participant['participantId']}', {
            'userID': Get.find<GlobalController>().userId.value,
            'roomID': roomID,
            'type': "candidate",
            'data': {
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            }
          });
        };
      }
      participant['peerConnection'] = peerConnection;
      allRoomMessageList.clear();
      allRoomMessageList.addAll(allRoomMessageListMap.values.toList());
    }
    if (isAudioCallState.value) {
      Helper.setSpeakerphoneOn(false);
    } else {
      Helper.setSpeakerphoneOn(true);
    }

    callState.value = CallStatus.inCAll.name;
    await audioService.stopAudio();
    if (callType == 1) {
      Get.offAndToNamed(krCallScreen);
    } else {
      Get.offAndToNamed(krGroupCallScreen);
    }
    // } catch (e) {
    //   ll("EXCEPTION: $e");
    // }
  }

  Future<void> onCallStart(data) async {
    ll('Got new remote answer for video call: ${jsonEncode(data)}');
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
    for (var participant in allRoomMessageListMap[data["roomID"]]!["peerConnectionList"]) {
      if (participant!['participantId'] == data['userID']) {
        RTCPeerConnection? peerConnection;
        peerConnection = participant!['peerConnection'];
        ll('Got Answer: ${jsonEncode(data)}');
        var answer = RTCSessionDescription(
          data['data']['sdp'],
          data['data']['type'],
        );
        await peerConnection?.setRemoteDescription(answer);
        participant!['peerConnection'] = peerConnection;
        allRoomMessageList.clear();
        allRoomMessageList.addAll(allRoomMessageListMap.values.toList());
      }
    }
    ll("Call Started");
    await audioService.stopAudio();
  }

  Future<void> switchToAudioCall(roomID) async {
    RTCPeerConnection? peerConnection;
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
    for (var participant in allRoomMessageListMap[roomID]!["peerConnectionList"]) {
      peerConnection = participant!['peerConnection'];
      if (localStream == null) {
        ll("Local stream is not initialized.");
        return;
      }

      List<MediaStreamTrack> videoTracks = List.from(localStream!.getVideoTracks());
      List<RTCRtpSender> senders = List.from(await peerConnection!.getSenders());

      for (var track in videoTracks) {
        localStream!.removeTrack(track);
        RTCRtpSender? sender = senders.firstWhere(
          (s) => s.track?.id == track.id,
        );
        await peerConnection.removeTrack(sender);
        track.enabled = false;
        track.stop();
      }

      socket.emit('mobile-call-${participant['participantId']}', {
        'userID': globalController.userId.value,
        'roomID': roomID,
        'callStatus': CallStatus.inCAll.name,
        'type': "callSettings",
        'data': "switchToAudio",
      });
    }
    await MessengerHelper().initAudioCallSwitcher();
    isAudioCallState.value = true;
    isLocalFeedStreaming.value = false;
    bool allVideoStreamOff = inCallParticipants.every((item) => item["isVideoStreaming"] == false);

    if (allVideoStreamOff) {
      Helper.setSpeakerphoneOn(false);
    }
  }

  Future<void> onSwitchToAudioCall(data) async {
    RTCPeerConnection? peerConnection;
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
    for (var participant in allRoomMessageListMap[data['roomID']]!["peerConnectionList"]) {
      if (participant!['participantId'] == data['userID']) {
        peerConnection = participant!['peerConnection'];
        if (participant!['remoteStream'] == null) {
          ll("Remote stream is not initialized.");
          return;
        }
        //  await MessengerHelper().initAudioCallSwitcher();
        List<MediaStreamTrack> videoTracks = participant!['remoteStream'].getVideoTracks();
        List<RTCRtpSender> senders = List.from(await peerConnection!.getSenders());

        for (var track in videoTracks) {
          for (var sender in senders) {
            if (sender.track?.id == track.id) {
              await peerConnection.removeTrack(sender);
              break;
            }
          }
          track.enabled = false;
          track.stop();
        }
        participant['remoteRenderer'].dispose();
        participant["remoteRenderer"] = null;
        int index = inCallParticipants.indexWhere((p) => p['userID'] == participant['participantId']);

        if (index != -1) {
          inCallParticipants[index]['remoteStream'] = participant['remoteStream'];
          inCallParticipants[index]['remoteRenderer'] = null;
          inCallParticipants[index]['isVideoStreaming'] = false;
        }
        RxList<Map<String, dynamic>> temporaryInCallParticipants = RxList([]);
        temporaryInCallParticipants.addAll(inCallParticipants);
        inCallParticipants.clear();
        inCallParticipants.addAll(temporaryInCallParticipants);
      }
      isRemoteFeedStreaming.value = false;
    }

    bool allVideoStreamOff = inCallParticipants.every((item) => item["isVideoStreaming"] == false);

    if (allVideoStreamOff) {
      Helper.setSpeakerphoneOn(false);
    }
  }

  Future<void> switchToVideoCall(roomID) async {
    RTCPeerConnection? peerConnection;
    await MessengerHelper().intiVideoCallSwitcher();
    await MessengerHelper().openUserMedia(CallType.video.name);
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
    for (var participant in allRoomMessageListMap[roomID]!["peerConnectionList"]) {
      peerConnection = participant!['peerConnection'];
      if (localStream == null) {
        ll("Local stream is not initialized.");
        return;
      }
      localStream?.getTracks().forEach((track) {
        ll("ON VIDEO CALL START GETTING LOCAL TRACK: $track");
        if (track.kind == 'video') {
          track.enabled = true;
          peerConnection?.addTrack(track, localStream!);
        }
      });

      final offer = await peerConnection!.createOffer();
      await peerConnection.setLocalDescription(offer);
      socket.emit('mobile-call-${participant['participantId']}', {
        'userID': globalController.userId.value,
        'roomID': roomID,
        'callStatus': CallStatus.inCAll.name,
        'type': "callSettings",
        'data': "switchToVideo",
        'sdp': offer.sdp,
        'sdp_type': offer.type
      });
    }
    isAudioCallState.value = false;
    isLocalFeedStreaming.value = true;
    Helper.setSpeakerphoneOn(true);
  }

  Future<void> onSwitchToVideoCall(data) async {
    RTCPeerConnection? peerConnection;
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
    for (var participant in allRoomMessageListMap[data["roomID"]]!["peerConnectionList"]) {
      if (participant!['participantId'] == data['userID']) {
        peerConnection = participant!['peerConnection'];
        await peerConnection!.setRemoteDescription(RTCSessionDescription(data['sdp'], data['sdp_type']));
        Helper.setSpeakerphoneOn(true);
        int index = inCallParticipants.indexWhere((p) => p['userID'] == participant['participantId']);

        if (index != -1) {
          inCallParticipants[index]['remoteStream'] = participant['remoteStream'];
          inCallParticipants[index]['remoteRenderer'] = participant['remoteRenderer'];
          inCallParticipants[index]['isVideoStreaming'] = true;
        }
        RxList<Map<String, dynamic>> temporaryInCallParticipants = RxList([]);
        temporaryInCallParticipants.addAll(inCallParticipants);
        inCallParticipants.clear();
        inCallParticipants.addAll(temporaryInCallParticipants);
      }
    }
  }

  void videoCallSwitchSDPSet(data) async {
    RTCPeerConnection? peerConnection;
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
    Map<String, dynamic>? room = allRoomMessageListMap[data["roomID"]];
    List<dynamic> peerConnectionList = room!["peerConnectionList"];

    Map<String, dynamic>? participant = peerConnectionList.firstWhere(
      (participant) => participant["participantId"] == callerID.value,
      orElse: () => {},
    );
    peerConnection = participant!['peerConnection'];
    await peerConnection!.setRemoteDescription(RTCSessionDescription(data['sdp'], data['sdp_type']));
  }

  // Get user list
  final RxBool isUserListLoading = RxBool(false);
  final RxBool isUserListScroller = RxBool(false);
  final RxList<User> userList = RxList<User>([]);
  final Rx<UserListModel?> userListData = Rx<UserListModel?>(null);
  final RxList<User> selectedUsers = RxList<User>([]);
  final RxList tempUserIndex = RxList([]);
  final RxBool canCreateGroup = RxBool(false);
  final TextEditingController groupNameTextEditingController = TextEditingController();
  Future<void> getUserList() async {
    try {
      isUserListLoading.value = true;
      String suffixUrl = '?take=15';
      String? token = await spController.getBearerToken();
      var response = await apiController.commonApiCall(
        requestMethod: kGet,
        token: token,
        url: kuGetUserList + suffixUrl,
      ) as CommonDM;
      if (response.success == true) {
        userList.clear();
        isUserListScroller.value = false;
        userListData.value = UserListModel.fromJson(response.data);
        userList.addAll(userListData.value!.users!.data!);
        isUserListLoading.value = false;
      } else {
        isUserListLoading.value = false;
        ErrorModel errorModel = ErrorModel.fromJson(response.data);
        if (errorModel.errors.isEmpty) {
          globalController.showSnackBar(title: ksError.tr, message: response.message, color: cRedColor);
        } else {
          globalController.showSnackBar(title: ksError.tr, message: errorModel.errors[0].message, color: cRedColor);
        }
      }
    } catch (e) {
      isUserListLoading.value = true;
      ll('getUserList error: $e');
    }
  }

  final RxBool isCreateGroupLoading = RxBool(false);
  final Rx<GroupData?> groupData = Rx<GroupData?>(null);
  Future<void> createGroup() async {
    List users = [];
    users.add(globalController.userId.value);
    for (int i = 0; i < selectedUsers.length; i++) {
      users.add(selectedUsers[i].id);
    }
    try {
      isCreateGroupLoading.value = true;
      String? token = await spController.getBearerToken();
      Map<String, dynamic> body = {
        'name': groupNameTextEditingController.text.trim(),
        'participant_ids': users.join(','),
      };
      var response = await apiController.commonApiCall(
        requestMethod: kPost,
        url: kuCreateGroup,
        body: body,
        token: token,
      ) as CommonDM;
      if (response.success == true) {
        groupData.value = GroupData.fromJson(response.data);
        roomList.insert(0, groupData.value!.room!);
        isCreateGroupLoading.value = false;
        Get.back();
        globalController.showSnackBar(title: ksSuccess.tr, message: response.message, color: cGreenColor);
      } else {
        isCreateGroupLoading.value = false;
        ErrorModel errorModel = ErrorModel.fromJson(response.data);
        if (errorModel.errors.isEmpty) {
          globalController.showSnackBar(title: ksError.tr, message: response.message, color: cRedColor);
        } else {
          globalController.showSnackBar(title: ksError.tr, message: errorModel.errors[0].message, color: cRedColor);
        }
      }
    } catch (e) {
      isCreateGroupLoading.value = false;
      ll('createGroup error: $e');
    }
  }

  final Rx<RoomData?> selectedRoomDat = Rx<RoomData?>(null);
  final RxBool canAddMember = RxBool(false);
  final RxList<User> addMemberList = RxList<User>([]);
  final RxBool isAddMemberLoading = RxBool(false);

  Future<void> addMember() async {
    List users = [];
    for (int i = 0; i < selectedUsers.length; i++) {
      users.add(selectedUsers[i].id);
    }
    try {
      isAddMemberLoading.value = true;
      String? token = await spController.getBearerToken();
      Map<String, dynamic> body = {
        'room_id': selectedRoom.value!.id.toString(),
        'participant_ids': users.join(','),
      };
      var response = await apiController.commonApiCall(
        requestMethod: kPost,
        url: kuAddMember,
        body: body,
        token: token,
      ) as CommonDM;
      if (response.success == true) {
        // groupData.value = GroupData.fromJson(response.data);
        // roomList.insert(0, groupData.value!.room!);
        isAddMemberLoading.value = false;
        Get.back();
        globalController.showSnackBar(title: ksSuccess.tr, message: response.message, color: cGreenColor);
      } else {
        isAddMemberLoading.value = false;
        ErrorModel errorModel = ErrorModel.fromJson(response.data);
        if (errorModel.errors.isEmpty) {
          globalController.showSnackBar(title: ksError.tr, message: response.message, color: cRedColor);
        } else {
          globalController.showSnackBar(title: ksError.tr, message: errorModel.errors[0].message, color: cRedColor);
        }
      }
    } catch (e) {
      isAddMemberLoading.value = false;
      ll('addMember error: $e');
    }
  }

  Future<void> connectGroupUser(roomID) async {
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};

    // Find the room
    Map<String, dynamic>? room = allRoomMessageListMap[roomID];

    List<dynamic> peerConnectionList = room!["peerConnectionList"];

    for (var participant in peerConnectionList) {
      // var existingConnection = peerConnectionList.firstWhere((pc) => pc["participantId"] == participant.userId, orElse: () => {});

      if (participant["peerConnection"] == null) {
        RTCPeerConnection peerConnection = await createPeerConnection(configuration);
        RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
        dataChannelDict.ordered = true;
        String dataChannelName = "room-$roomID";
        RTCDataChannel dataChannel = await peerConnection.createDataChannel(dataChannelName, dataChannelDict);
        setupGroupDataChannelListeners(dataChannel, roomID, participant["participantId"]);
        registerGroupPeerConnectionListeners(peerConnection, participant["participantId"], roomID);
        participant["peerConnection"] = peerConnection;
        participant["dataChannel"] = dataChannel;
        participant["dataChannelLabel"] = dataChannel.label;

        RTCSessionDescription offer = await peerConnection.createOffer();
        await peerConnection.setLocalDescription(offer);

        ll("Sending offer");
        socket.emit('group-chat-${participant["participantId"]}', {
          'userID': Get.find<GlobalController>().userId.value,
          'roomID': roomID,
          'type': EmitType.offer.name,
          'data': {
            'sdp': offer.sdp,
            'type': offer.type,
          }
        });

        peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
          globalController.iceCandidateList.add(candidate);
          Map<String, dynamic> data = {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          };
          ll("CREATING ICE CANDIDATE $data");
          // socket.emit('group-chat-${participant["participantId"]}', {
          //   'userID': Get.find<GlobalController>().userId.value,
          //   'roomID': roomID,
          //   'type': EmitType.candidate.name,
          //   'data': data,
          // });
        };
      }
    }
  }

  void setupGroupDataChannelListeners(RTCDataChannel dataChannel, roomID, userID) {
    dataChannel.onDataChannelState = (RTCDataChannelState state) {
      ll("STATE CHANGED: $state");
    };

    dataChannel.onMessage = (RTCDataChannelMessage message) {
      ll('Received message: ${message.text}');
      ll("ROOM NAME: $roomID DATA CHANNEL: ${dataChannel.label}");
      int index = allRoomMessageList.indexWhere((room) => room['roomID'] == roomID);
      if (index != -1) {
        // globalController.showSnackBar(title: allRoomMessageList[index]["userName"], message: message.text, color: Colors.green);
        allRoomMessageList[index]["isSeen"] = false.obs;
        allRoomMessageList[index]["messages"].insert(
            0,
            //todo set up image
            MessageData(text: message.text, senderId: userID, messageText: message.text, senderImage: ""));
        var roomData = allRoomMessageList[index];
        allRoomMessageList.remove(allRoomMessageList[index]);
        allRoomMessageList.insert(0, roomData);
      }
    };
  }

  void registerGroupPeerConnectionListeners(RTCPeerConnection? peerConnection, userID, roomID) {
    peerConnection?.onConnectionState = (RTCPeerConnectionState state) async {
      ll('Connection state change: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        await peerConnection.restartIce();
      }
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) async {
      ll('Signaling state change: $state for $userID');
      if (state == RTCSignalingState.RTCSignalingStateHaveRemoteOffer) {
        Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
        try {
          var answer = await peerConnection.createAnswer();
          ll('Created Answer $answer');
          await peerConnection.setLocalDescription(answer);
          if (isInCallState.value) {
            ll("IN CALL STATE WITH $userID");
            socket.emit('mobile-call-$userID', {
              'userID': globalController.userId.value,
              'roomID': roomID,
              'callStatus': CallStatus.inCAll.name,
              'type': EmitType.answer.name,
              'data': {
                'sdp': answer.sdp,
                'type': answer.type,
              }
            });
            if (userID != callerID.value) {
              peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
                ll("GENERATED ICE CANDIDATE");
                socket.emit('group-chat-$userID', {
                  'userID': Get.find<GlobalController>().userId.value,
                  'roomID': roomID,
                  'type': "candidate",
                  'data': {
                    'candidate': candidate.candidate,
                    'sdpMid': candidate.sdpMid,
                    'sdpMLineIndex': candidate.sdpMLineIndex,
                  }
                });
              };
            }
          } else {
            socket.emit('group-chat-$userID', {
              'userID': Get.find<GlobalController>().userId.value,
              'roomID': roomID,
              'type': EmitType.answer.name,
              'data': {
                'sdp': answer.sdp,
                'type': answer.type,
              }
            });
          }
          for (var peer in allRoomMessageListMap[roomID]!['peerConnectionList']) {
            if (peer['participantId'] == userID) {
              peer['peerConnection'] = peerConnection;
              break;
            }
          }
          allRoomMessageList.clear();
          allRoomMessageList.addAll(allRoomMessageListMap.values.toList());
        } catch (e) {
          ll("EXCEPTION Registering: $e");
        }
      }
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      ll('ICE connection state change: $state');
    };

    peerConnection?.onRenegotiationNeeded = () {
      ll("RE NEGOTIATION NEEDED");
      if (isNegotiating.value) {
        ll("Skipping renegotiation to prevent collision.");
        return;
      }
    };

    peerConnection?.onTrack = (RTCTrackEvent event) async {
      MediaStream? remoteGroupStream;
      Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
      ll('Got remote track sc: ${event.streams[0]}');

      ll('Initializing remoteStream for $userID');
      for (var participant in allRoomMessageListMap[roomID]!["peerConnectionList"]) {
        if (participant['participantId'] == userID) {
          remoteGroupStream = await createLocalMediaStream('remoteStream');
          event.streams[0].getTracks().forEach((track) {
            ll('Add a track to the remoteStream: $track');
            remoteGroupStream?.addTrack(track);
            participant['remoteRenderer'].srcObject = remoteGroupStream;
            if (track.kind == 'video') {
              isRemoteFeedStreaming.value = true;
            }
          });
          participant['remoteStream'] = remoteGroupStream;
          int index = inCallParticipants.indexWhere((p) => p['userID'] == participant['participantId']);

          var hasVideo = event.streams[0].getVideoTracks().isNotEmpty;
          if (index != -1) {
            inCallParticipants[index]['remoteStream'] = participant['remoteStream'];
            inCallParticipants[index]['remoteRenderer'] = participant['remoteRenderer'];
            inCallParticipants[index]['isVideoStreaming'] = hasVideo;
          } else {
            ll("Track kind 1: ${event.track.kind}");
            inCallParticipants.add({
              'userID': participant['participantId'],
              'userName': participant['participantName'],
              'userImage': participant['participantImage'],
              'remoteStream': participant['remoteStream'],
              'remoteRenderer': participant['remoteRenderer'],
              'isVideoStreaming': hasVideo,
            });
          }
          allRoomMessageList.clear();
          allRoomMessageList.addAll(allRoomMessageListMap.values.toList());
          break;
        }
      }
    };

    peerConnection?.onAddTrack = (MediaStream stream, MediaStreamTrack track) async {
      MediaStream? remoteGroupStream;
      ll("GETTING REMOTE TRACK SC: $track ${stream.id}");
      ll("Getting remote track from $userID");
      Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var room in allRoomMessageList) room['roomID']: room};
      ll('Initializing remoteStream');
      for (var participant in allRoomMessageListMap[roomID]!["peerConnectionList"]) {
        if (participant['participantId'] == userID) {
          remoteGroupStream = await createLocalMediaStream('remoteStream');
          participant['remoteRenderer'].srcObject = stream;
          remoteGroupStream = stream;
          participant['remoteStream'] = remoteGroupStream;
          if (track.kind == 'video') {
            isRemoteFeedStreaming.value = true;
          }
          allRoomMessageList.clear();
          allRoomMessageList.addAll(allRoomMessageListMap.values.toList());
          break;
        }
      }
    };
  }
}
