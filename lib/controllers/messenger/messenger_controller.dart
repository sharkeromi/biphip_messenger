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
import 'package:biphip_messenger/models/messenger/message_list_model.dart';
import 'package:biphip_messenger/models/messenger/room_list_model.dart';
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
  final Rx<RoomData?> selectedReceiver = Rx<RoomData?>(null);
  final RxInt selectedRoomIndex = RxInt(-1);
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

  Future<void> initializeRenderer() async {
    if (localRenderer.textureId == null) {
      localRenderer = RTCVideoRenderer();
      await localRenderer.initialize();
    }

    if (remoteRenderer.textureId == null) {
      remoteRenderer = RTCVideoRenderer();
      await remoteRenderer.initialize();
    }
  }

  void disposeRenderer() {
    localRenderer.dispose();
    remoteRenderer.dispose();
  }

  @override
  void onClose() {
    super.onClose();
    disposeRenderer();
  }

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

  void sendMessage(String message, RTCDataChannel dataChannel) async {
    if (isInternetConnectionAvailable.value) {
      setMessage(selectedReceiver.value!.id, MessageData(text: message, senderId: globalController.userId.value, messageText: message));

      sendViaDataChannel(message, dataChannel);

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

  void sendViaDataChannel(String message, dataChannel) {
    if (dataChannel.state == RTCDataChannelState.RTCDataChannelOpen) {
      dataChannel.send(RTCDataChannelMessage(message));
    }
  }

  // Send through API
  // Send through API
  final RxBool isSendMessageLoading = RxBool(false);
  Future<void> sendBatchMessages(message) async {
    try {
      isSendMessageLoading.value = true;
      String? token = await spController.getBearerToken();
      Map<String, dynamic> body = {
        'room_id': selectedReceiver.value!.id.toString(),
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
      allRoomMessageList.add({
        "roomID": roomList[i].id,
        "userID": roomList[i].roomUserId,
        "dataChannelLabel": "",
        "dataChannel": null,
        "peerConnection": null,
        "status": false.obs,
        "userName": roomList[i].roomName,
        "userImage": (roomList[i].roomImage != null && roomList[i].roomImage!.isNotEmpty) ? roomList[i].roomImage![0] : "default_image_url",
        "isSeen": true.obs,
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
  void setMessage(userID, messageData) {
    int index = allRoomMessageList.indexWhere((user) => user['roomID'] == userID);
    if (index != -1) {
      allRoomMessageList[index]["messages"].insert(0, messageData);
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
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in allRoomMessageList) user['userID']: user};

    ll("CREATING PEER CONNECTION");
    RTCPeerConnection peerConnection = await createPeerConnection(configuration);

    ll("CREATING DATA CHANNEL");
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
    dataChannelDict.ordered = true;
    String dataChannelName = "room-$roomID";
    RTCDataChannel dataChannel = await peerConnection.createDataChannel(dataChannelName, dataChannelDict);
    setupDataChannelListeners(dataChannel, userID);
    registerPeerConnectionListeners(peerConnection, userID);

    allRoomMessageListMap[userID]!['peerConnection'] = peerConnection;
    allRoomMessageListMap[userID]!['dataChannel'] = dataChannel;

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
        'type': EmitType.candidate.name,
        'data': data,
      });
    };

    setUpRoomDataChannel(userID, dataChannel);
  }

  void registerPeerConnectionListeners(RTCPeerConnection? peerConnection, userID) {
    peerConnection?.onConnectionState = (RTCPeerConnectionState state) async {
      ll('Connection state change: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        await peerConnection.restartIce();
      }
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) async {
      ll('Signaling state change: $state');

      if (state == RTCSignalingState.RTCSignalingStateHaveRemoteOffer) {
        Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in allRoomMessageList) user['userID']: user};
        try {
          var answer = await peerConnection.createAnswer();
          ll('Created Answer $answer');
          await peerConnection.setLocalDescription(answer);
          if (isInCallState.value) {
            socket.emit('mobile-call-$userID', {
              'userID': globalController.userId.value,
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
              'type': EmitType.answer.name,
              'data': {
                'sdp': answer.sdp,
                'type': answer.type,
              }
            });
          }
          allRoomMessageListMap[callerID.value]!['peerConnection'] = peerConnection;

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

  void setupDataChannelListeners(RTCDataChannel dataChannel, userID) {
    dataChannel.onDataChannelState = (RTCDataChannelState state) {
      ll("STATE CHANGED: $state");
    };

    dataChannel.onMessage = (RTCDataChannelMessage message) {
      ll('Received message: ${message.text}');
      ll("USER NAME: $userID DATA CHANNEL: ${dataChannel.label}");
      int index = allRoomMessageList.indexWhere((user) => user['userID'] == userID);
      if (index != -1) {
        globalController.showSnackBar(title: allRoomMessageList[index]["userName"], message: message.text, color: Colors.green);
        allRoomMessageList[index]["isSeen"] = false.obs;
        allRoomMessageList[index]["messages"].insert(
            0,
            MessageData(
                text: message.text,
                senderId: Get.find<MessengerController>().selectedReceiver.value!.roomUserId,
                messageText: message.text,
                senderImage: Get.find<MessengerController>().selectedReceiver.value!.roomImage![0]));
      }
    };
  }

  RTCDataChannel? targetDataChannel;
  void setUpRoomDataChannel(userID, dataChannel) async {
    targetDataChannel = dataChannel;
    ll("Set up room data channel: $targetDataChannel $dataChannel");
    Map<int, Map<String, dynamic>> roomMap = {for (var onlineUser in allRoomMessageList) onlineUser['userID']: onlineUser};

    if (roomMap.containsKey(userID)) {
      roomMap[userID]!['dataChannelLabel'] = dataChannel.label;
      roomMap[userID]!['dataChannel'] = dataChannel;
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
  final RxInt callerID = RxInt(-1);
  final RxBool isInCallState = RxBool(false);

  final RxMap<String, dynamic> callOffer = RxMap<String, dynamic>({});

  //Ring function for Sender
  Future<void> ringUser(userID, String callType) async {
    isUserTypeSender.value = true;
    callerID.value = userID;
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in allRoomMessageList) user['userID']: user};
    callerName.value = allRoomMessageListMap[userID]!['userName'];
    callerImage.value = allRoomMessageListMap[userID]!['userImage'];

    callState.value = CallStatus.ringing.name;
    if (callType == CallType.audio.name) {
      isAudioCallState.value = true;
    } else {
      isAudioCallState.value = false;
    }
    await initializeRenderer();
    await initiateVideoCall(userID, callType);
    Get.toNamed(krCallScreen);
    if (callType == CallType.video.name) {
      await audioService.playAudio(callerTunePath, isSpeaker: true);
    } else {
      await audioService.playAudio(callerTunePath, isSpeaker: false);
    }
  }

  Future<void> initiateVideoCall(userID, String callType) async {
    RTCPeerConnection? peerConnection;
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in Get.find<MessengerController>().allRoomMessageList) user['userID']: user};
    peerConnection = allRoomMessageListMap[userID]!['peerConnection'];
    await MessengerHelper().openUserMedia(callType);

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
    if (callType == CallType.audio.name) {
      Helper.setSpeakerphoneOn(false);
    } else {
      Helper.setSpeakerphoneOn(true);
    }

    await peerConnection.setLocalDescription(offer);
    allRoomMessageListMap[userID]!['peerConnection'] = peerConnection;

    allRoomMessageList.clear();
    allRoomMessageList.addAll(allRoomMessageListMap.values.toList());

    socket.emit('mobile-call-$userID', {
      'userID': Get.find<GlobalController>().userId.value,
      'callStatus': CallStatus.ringing.name,
      'callType': callType,
      'type': "offer",
      'data': {
        'sdp': offer.sdp,
        'type': offer.type,
      },
    });

    // todo: may need to store the peer connection
  }

  //Ring function for Receiver
  void onCallRing(data) {
    isInCallState.value = true;
    isUserTypeSender.value = false;
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in allRoomMessageList) user['userID']: user};
    callerName.value = allRoomMessageListMap[data['userID']]!['userName'];
    callerImage.value = allRoomMessageListMap[data['userID']]!['userImage'];
    callerID.value = data['userID'];
    callOffer.value = data['data'];
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
  Future<void> onHangUpCall() async {
    await audioService.stopAudio();
    await MessengerHelper().hangUp();
  }

  //Accept call from receiver
  void onAcceptCall(userID) async {
    try {
      await initializeRenderer();
      await MessengerHelper().openUserMedia(isAudioCallState.value ? CallType.audio.name : CallType.video.name);
      RTCPeerConnection? peerConnection;
      Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in allRoomMessageList) user['userID']: user};

      if (allRoomMessageListMap[userID]!['peerConnection'] != null) {
        peerConnection = allRoomMessageListMap[userID]!['peerConnection'];
      }
      localStream?.getTracks().forEach((track) async {
        ll("ON ANSWER VIDEO CALL GETTING LOCAL TRACK: $track");
        await peerConnection!.addTrack(track, localStream!);
      });
      if (isAudioCallState.value) {
        Helper.setSpeakerphoneOn(false);
      } else {
        Helper.setSpeakerphoneOn(true);
      }
      ll('Setting remote description for video call');
      RTCSessionDescription description = RTCSessionDescription(callOffer['sdp'], callOffer['type']);
      try {
        await peerConnection?.setRemoteDescription(description);
        ll("Remote description set successfully.: ${description.sdp}");
      } catch (e) {
        ll("Error setting remote description: $e");
        return;
      }
      callState.value = CallStatus.inCAll.name;
      await audioService.stopAudio();
      Get.offAndToNamed(krCallScreen);
    } catch (e) {
      ll("EXCEPTION: $e");
    }
  }

  Future<void> onCallStart(data) async {
    RTCPeerConnection? peerConnection;
    ll('Got new remote answer for video call: ${jsonEncode(data)}');
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in Get.find<MessengerController>().allRoomMessageList) user['userID']: user};

    peerConnection = allRoomMessageListMap[data['userID']]!['peerConnection'];

    ll('Got Answer: ${jsonEncode(data)}');
    var answer = RTCSessionDescription(
      data['data']['sdp'],
      data['data']['type'],
    );

    ll("Call Started");
    await audioService.stopAudio();
    await peerConnection?.setRemoteDescription(answer);
  }

  Future<void> switchToAudioCall(userID) async {
    RTCPeerConnection? peerConnection;
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in Get.find<MessengerController>().allRoomMessageList) user['userID']: user};

    peerConnection = allRoomMessageListMap[userID]!['peerConnection'];
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

    socket.emit('mobile-call-$userID',
        {'userID': globalController.userId.value, 'callStatus': CallStatus.inCAll.name, 'type': "callSettings", 'data': "switchToAudio"});
    isAudioCallState.value = true;
    isLocalFeedStreaming.value = false;
    if (!isRemoteFeedStreaming.value) {
      Helper.setSpeakerphoneOn(false);
    }
  }

  Future<void> onSwitchToAudioCall(userID) async {
    RTCPeerConnection? peerConnection;
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in Get.find<MessengerController>().allRoomMessageList) user['userID']: user};

    peerConnection = allRoomMessageListMap[userID]!['peerConnection'];
    if (remoteStream == null) {
      ll("Remote stream is not initialized.");
      return;
    }
    await MessengerHelper().initAudioCallSwitcher();
    List<MediaStreamTrack> videoTracks = remoteStream!.getVideoTracks();
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
    isRemoteFeedStreaming.value = false;
    if (!isLocalFeedStreaming.value) {
      Helper.setSpeakerphoneOn(false);
    }
  }

  Future<void> switchToVideoCall(userID) async {
    RTCPeerConnection? peerConnection;
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in Get.find<MessengerController>().allRoomMessageList) user['userID']: user};

    peerConnection = allRoomMessageListMap[userID]!['peerConnection'];
    if (localStream == null) {
      ll("Local stream is not initialized.");
      return;
    }
    await MessengerHelper().intiVideoCallSwitcher();

    localStream?.getTracks().forEach((track) {
      ll("ON VIDEO CALL START GETTING LOCAL TRACK: $track");
      if (track.kind == 'video') {
        track.enabled = true;
        peerConnection?.addTrack(track, localStream!);
      }
    });

    final offer = await peerConnection!.createOffer();
    await peerConnection.setLocalDescription(offer);
    socket.emit('mobile-call-$userID', {
      'userID': globalController.userId.value,
      'callStatus': CallStatus.inCAll.name,
      'type': "callSettings",
      'data': "switchToVideo",
      'sdp': offer.sdp,
      'sdp_type': offer.type
    });
    isAudioCallState.value = false;
    isLocalFeedStreaming.value = true;
    Helper.setSpeakerphoneOn(true);
  }

  Future<void> onSwitchToVideoCall(data) async {
    RTCPeerConnection? peerConnection;
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in Get.find<MessengerController>().allRoomMessageList) user['userID']: user};

    peerConnection = allRoomMessageListMap[data["userID"]]!['peerConnection'];
    await peerConnection!.setRemoteDescription(RTCSessionDescription(data['sdp'], data['sdp_type']));
    Helper.setSpeakerphoneOn(true);
  }

  void videoCallSwitchSDPSet(data) async {
    RTCPeerConnection? peerConnection;
    Map<int, Map<String, dynamic>> allRoomMessageListMap = {for (var user in Get.find<MessengerController>().allRoomMessageList) user['userID']: user};

    peerConnection = allRoomMessageListMap[data["userID"]]!['peerConnection'];
    await peerConnection!.setRemoteDescription(RTCSessionDescription(data['sdp'], data['sdp_type']));
  }
}
