import 'dart:async';
import 'dart:io';
import 'package:biphip_messenger/controllers/common/api_controller.dart';
import 'package:biphip_messenger/controllers/common/global_controller.dart';
import 'package:biphip_messenger/controllers/common/sp_controller.dart';
import 'package:biphip_messenger/models/common/common_data_model.dart';
import 'package:biphip_messenger/models/common/common_error_model.dart';
import 'package:biphip_messenger/models/messenger/message_list_model.dart';
import 'package:biphip_messenger/models/messenger/room_list_model.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/utils/constants/strings.dart';
import 'package:biphip_messenger/utils/constants/urls.dart';
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

  @override
  void onClose() {
    super.onClose();
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


  // Send through API
  final RxBool isSendMessageLoading = RxBool(false);

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

  //=====================================================
}
